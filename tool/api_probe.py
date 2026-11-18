#!/usr/bin/env python3
"""Live API integration probe.

Logs in as the client and each provider account, walks every endpoint the app
calls, and records the exact response shape so it can be diffed against what
the Dart models expect. Read-only by default; pass --write to exercise the
booking create flow.

Usage:
    python3 tool/api_probe.py            # read-only sweep
    python3 tool/api_probe.py --write    # also create a booking
"""

import json
import sys
import urllib.error
import urllib.request

BASE = "https://api.peakprivee.com/api/v1"

ACCOUNTS = {
    "client": ("user@demo.com", "12345678"),
    "provider_transport": ("sushilhemrom264@gmail.com", "12345678"),
    "provider_massage": ("sushilhemrom263@gmail.com", "12345678"),
    "provider_restaurant": ("sushilhemrom261@gmail.com", "12345678"),
    "provider_hire": ("sushilhemrom260@gmail.com", "12345678"),
    "provider_other": ("sushil500530@gmail.com", "12345678"),
    "billgates": ("billgates@demo.com", "12345678"),
}


def call(method, url, token=None, body=None, timeout=30):
    """Returns (http_status, parsed_body_or_raw_text)."""
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode(errors="replace")
            status = resp.status
    except urllib.error.HTTPError as e:
        raw = e.read().decode(errors="replace")
        status = e.code
    except Exception as e:  # network-level failure
        return -1, {"_transport_error": str(e)}
    try:
        return status, json.loads(raw)
    except Exception:
        return status, raw


def shape(value, depth=0, max_depth=3):
    """Compact type signature of a JSON value, for model diffing."""
    if depth > max_depth:
        return "..."
    if isinstance(value, dict):
        return {k: shape(v, depth + 1, max_depth) for k, v in value.items()}
    if isinstance(value, list):
        if not value:
            return ["<empty>"]
        return [shape(value[0], depth + 1, max_depth)]
    if value is None:
        return "null"
    return type(value).__name__


def login(email, password):
    status, body = call("POST", f"{BASE}/auth/login", body={"email": email, "password": password})
    if isinstance(body, dict):
        data = body.get("data") or {}
        tokens = data.get("tokens") or {}
        user = data.get("user") or {}
        token = tokens.get("accessToken")
        if token:
            return {
                "token": token,
                "id": user.get("_id"),
                "role": user.get("role"),
                "providerType": user.get("providerType"),
                "name": user.get("fullName"),
            }
    return {"error": body if not isinstance(body, dict) else body.get("message"), "status": status}


def main():
    do_write = "--write" in sys.argv
    report = {"logins": {}, "endpoints": {}, "write": {}}

    # ---------- 1. LOGIN EVERY ACCOUNT ----------
    print("=" * 70)
    print("1. LOGIN")
    print("=" * 70)
    sessions = {}
    for label, (email, password) in ACCOUNTS.items():
        info = login(email, password)
        if "token" in info:
            sessions[label] = info
            print(f"  OK   {label:22s} role={info['role']:<10s} "
                  f"providerType={str(info['providerType']):<12s} name={info['name']}")
            report["logins"][label] = {k: v for k, v in info.items() if k != "token"}
        else:
            print(f"  FAIL {label:22s} status={info.get('status')} msg={info.get('error')}")
            report["logins"][label] = info

    if "client" not in sessions:
        print("\nCannot continue without a client session.")
        json.dump(report, open("/tmp/hbg_api_report.json", "w"), indent=2)
        return

    client = sessions["client"]
    ct = client["token"]

    # ---------- 2. CLIENT-SIDE CATALOGUE ----------
    print()
    print("=" * 70)
    print("2. CLIENT CATALOGUE (listings + categories)")
    print("=" * 70)
    catalogue = {
        "ski_pass_all": f"{BASE}/ski-pass/all",
        "ski_hire_all": f"{BASE}/ski-hire/all",
        "transport_all": f"{BASE}/transport/all",
        "massage_all": f"{BASE}/massage/all",
        "restaurant_all": f"{BASE}/restaurant/all",
        "cat_ski_hire": f"{BASE}/common/category/ski-hire",
        "cat_transport": f"{BASE}/common/category/transport",
        "cat_massage": f"{BASE}/common/category/massage",
        "cat_restaurant": f"{BASE}/common/category/restaurant",
        "profile": f"{BASE}/users/profile/me",
        "itinerary": f"{BASE}/booking/itinerary",
        "notifications": f"{BASE}/notifications/all",
        "wallet_balance": f"{BASE}/wallet/get-balance",
        "wallet_accounts": f"{BASE}/wallet/get-my-account",
        "chat_users": f"{BASE}/chat/chat-users",
    }
    first_ids = {}
    for name, url in catalogue.items():
        status, body = call("GET", url, ct)
        ok = isinstance(body, dict) and body.get("success") is True
        count = ""
        if isinstance(body, dict):
            d = body.get("data")
            if isinstance(d, dict) and isinstance(d.get("result"), list):
                count = f" result={len(d['result'])}"
                if d["result"]:
                    first_ids[name] = d["result"][0].get("_id")
            elif isinstance(d, list):
                count = f" list={len(d)}"
                if d:
                    first_ids[name] = d[0].get("_id") if isinstance(d[0], dict) else None
        msg = "" if ok else f"  msg={body.get('message') if isinstance(body, dict) else str(body)[:80]}"
        print(f"  [{status}] {'OK  ' if ok else 'FAIL'} {name:18s}{count}{msg}")
        report["endpoints"][name] = {
            "status": status, "success": ok,
            "message": body.get("message") if isinstance(body, dict) else None,
            "shape": shape(body),
        }

    # ---------- 3. DETAIL ENDPOINTS ----------
    print()
    print("=" * 70)
    print("3. CLIENT DETAIL PAGES (single item fetch)")
    print("=" * 70)
    detail_map = {
        "ski_pass_all": f"{BASE}/ski-pass/{{}}",
        "ski_hire_all": f"{BASE}/ski-hire/{{}}",
        "transport_all": f"{BASE}/transport/{{}}",
        "massage_all": f"{BASE}/massage/{{}}",
        "restaurant_all": f"{BASE}/restaurant/{{}}",
    }
    for listing, tmpl in detail_map.items():
        item_id = first_ids.get(listing)
        if not item_id:
            print(f"  SKIP {listing:18s} (no items in listing)")
            continue
        status, body = call("GET", tmpl.format(item_id), ct)
        ok = isinstance(body, dict) and body.get("success") is True
        print(f"  [{status}] {'OK  ' if ok else 'FAIL'} {listing:18s} id={item_id}")
        report["endpoints"][f"{listing}_detail"] = {
            "status": status, "success": ok, "id": item_id, "shape": shape(body),
        }

    # ---------- 4. CLIENT BOOKINGS PER CATEGORY ----------
    print()
    print("=" * 70)
    print("4. CLIENT BOOKINGS (my-booking per category)")
    print("=" * 70)
    categories = ["ski-pass", "ski-hire", "transport", "massage", "restaurant"]
    client_bookings = {}
    for cat in categories:
        status, body = call("GET", f"{BASE}/booking/my-booking?category={cat}", ct)
        ok = isinstance(body, dict) and body.get("success") is True
        items = []
        if isinstance(body, dict):
            d = body.get("data")
            if isinstance(d, dict) and isinstance(d.get("result"), list):
                items = d["result"]
            elif isinstance(d, list):
                items = d
        client_bookings[cat] = items
        print(f"  [{status}] {'OK  ' if ok else 'FAIL'} {cat:12s} bookings={len(items)}")
        report["endpoints"][f"my_booking_{cat}"] = {
            "status": status, "success": ok, "count": len(items), "shape": shape(body),
        }

    # ---------- 5. PROVIDER SIDE ----------
    print()
    print("=" * 70)
    print("5. PROVIDER SIDE (dashboard, own services, incoming bookings)")
    print("=" * 70)
    provider_endpoints = {
        "home": f"{BASE}/dashboard/meta/provider",
        "bookings_all": f"{BASE}/booking/all",
        "my_pass": f"{BASE}/ski-pass/my-all",
        "my_hire": f"{BASE}/ski-hire/my-all",
        "my_transport": f"{BASE}/transport/my-all",
        "my_massage": f"{BASE}/massage/my-all",
        "my_restaurant": f"{BASE}/restaurant/my-all",
    }
    provider_bookings = {}
    for label, sess in sessions.items():
        if label == "client":
            continue
        print(f"\n  --- {label} (role={sess['role']}, type={sess['providerType']}) ---")
        for name, url in provider_endpoints.items():
            status, body = call("GET", url, sess["token"])
            ok = isinstance(body, dict) and body.get("success") is True
            count = ""
            if isinstance(body, dict):
                d = body.get("data")
                if isinstance(d, dict) and isinstance(d.get("result"), list):
                    count = f" result={len(d['result'])}"
                    if name == "bookings_all":
                        provider_bookings[label] = d["result"]
                elif isinstance(d, list):
                    count = f" list={len(d)}"
                    if name == "bookings_all":
                        provider_bookings[label] = d
            msg = "" if ok else f"  msg={body.get('message') if isinstance(body, dict) else str(body)[:60]}"
            print(f"    [{status}] {'OK  ' if ok else 'FAIL'} {name:14s}{count}{msg}")
            report["endpoints"][f"{label}.{name}"] = {
                "status": status, "success": ok, "shape": shape(body),
            }

    # ---------- 6. CROSS-CHECK ----------
    print()
    print("=" * 70)
    print("6. CROSS-CHECK: do client bookings appear on the provider side?")
    print("=" * 70)
    client_ids = {}
    for cat, items in client_bookings.items():
        for b in items:
            if isinstance(b, dict) and b.get("_id"):
                client_ids[b["_id"]] = cat
    print(f"  client holds {len(client_ids)} booking(s) across all categories")

    all_provider_ids = {}
    for label, items in provider_bookings.items():
        for b in items or []:
            if isinstance(b, dict) and b.get("_id"):
                all_provider_ids.setdefault(b["_id"], []).append(label)
    print(f"  providers collectively see {len(all_provider_ids)} booking(s)")

    matched, unmatched = [], []
    for bid, cat in client_ids.items():
        if bid in all_provider_ids:
            matched.append((bid, cat, all_provider_ids[bid]))
        else:
            unmatched.append((bid, cat))

    for bid, cat, who in matched:
        print(f"    MATCH    {cat:12s} {bid} -> visible to {who}")
    for bid, cat in unmatched:
        print(f"    MISSING  {cat:12s} {bid} -> NOT visible to any provider account")

    report["cross_check"] = {
        "client_booking_count": len(client_ids),
        "provider_visible_count": len(all_provider_ids),
        "matched": [{"id": b, "category": c, "providers": w} for b, c, w in matched],
        "missing": [{"id": b, "category": c} for b, c in unmatched],
    }

    # ---------- 7. OPTIONAL WRITE ----------
    if do_write:
        print()
        print("=" * 70)
        print("7. WRITE TEST (booking create)")
        print("=" * 70)
        pass_id = first_ids.get("ski_pass_all")
        if pass_id:
            body = {
                "userId": client["id"],
                "productId": pass_id,
                "category": "ski-pass",
                "personCount": 1,
                "transactionId": "probe_integration_test",
            }
            status, resp = call("POST", f"{BASE}/booking/create", ct, body=body)
            print(f"  [{status}] booking/create -> "
                  f"{resp.get('message') if isinstance(resp, dict) else str(resp)[:200]}")
            report["write"]["booking_create"] = {"status": status, "response": resp}

    json.dump(report, open("/tmp/hbg_api_report.json", "w"), indent=2)
    print()
    print("Full shapes written to /tmp/hbg_api_report.json")


if __name__ == "__main__":
    main()
