# Backend issues — Massage, Restaurant and Ski Pass

Last updated: **18 Nov 2026, 09:00 Bangladesh time** (03:00 UTC).
Server: `https://sushil5000.ssh.bd/api/v1` · Customer `user@demo.com`

## Open issues

None.

## Waiting for a decision (product, not a bug)

### Q1. Multi-day ski passes (e.g. "6-Day 3 Valleys Pass")

Backend confirmed: a pass covers only the chosen day; "6-Day" is only part of the name (no `days`
field). Decide: keep it as a label, or make real multi-day passes (`days` on the pass, `endAt` =
day + days − 1, shown as "Fri 20 – Wed 25 Nov"). If it becomes real, the app will show the range
on the checkout, ticket, booking and itinerary.

### Q2. Massage: people per booking limit (6)

Backend confirmed the group rules work: `capacity` is sent, bookings above it are refused before
payment, and overlapping guests are counted. The only gap: the app caps one massage booking at
**6 people**, but the server only checks `capacity` (1–50), so another client could book more.
Decide: leave it (the app is the only client), or add a fixed massage limit on the server (like
`SKI_PASS_MAX_PEOPLE`) and send it as `maxPeoplePerBooking` on the massage listing. The app
already reads `maxPeoplePerBooking` for massage when present (falls back to 6), so no app change
is needed if the backend adds it.

## Fixed, to check on the next completed booking

- **M4:** the "You can now leave a review" sentence is now sent only when the customer can still
  review, and `booking.completed` carries `data.canReview`. The app shows a "Leave a review"
  button on the notification when it is true (opens the booking with the review). All completion
  notifications on the server so far were sent before the fix, so this is not yet seen live.

## Ski Pass (provider `sushilhemrom262@gmail.com`)

Checked on 17 Nov after the S1/S2 changes; everything works on both sides:

- Booking: confirmed straight away with a ticket number; price per person (€79 × 2 = €158).
- People limit: 11 refused at the payment step with "A ski pass booking is for up to 10 people…",
  10 accepted, 0 refused. The app now reads `maxPeoplePerBooking` from the pass ("Up to 10 per
  booking").
- Notifications name the pass and day: customer "3 Valleys Day Pass on Sat 21 Nov is confirmed.
  Ticket TKT-404441.", provider "Azaan booked 3 Valleys Day Pass on Sat 21 Nov.", both with
  `startAt` and `ticketNumber`.
- Cancel more than 24 h before: 100%; less than 24 h: 90%; same day: refused.
- App, customer: booking with Stripe, ticket screen, ticket PDF, My Bookings, details, cancel with
  full refund, review hidden once given.
- App, provider: home figures, bookings list, details (guest, ticket, payout pending), ticket.

## Massage

M1, M2 and M3 are fixed and checked. The booking that was never accepted was cancelled by the system
(100% refund) and its time became free again.

Auto-complete checked: the accepted 12:00 PM session (ends 11:45 UTC) was completed by the system
at 11:45:00 UTC, provider wallet €316 → €380 (+€64), earning `{gross 80, platformFee 16, net 64}`,
"Booking completed" notification sent.

## Restaurant (Le Chalet Gourmand, provider `sushilhemrom261@gmail.com`)

All checked, no issues: seats and price, free seats per slot, overbooking refused, accept, reject
with reason, cancel and refunds, notifications, listing create/edit/delete, Mark as done, and the
customer review.

Service fee to the platform (new rule) checked on today's €65 lunch: wallet €297.60 → €345.60
(+€48), earning `{gross 65, serviceFee 5, platformFee 17, net 48}`. The app shows Service fee
(platform) €5 and Commission €12 in the provider's breakdown.

## Itinerary

Working: shows active and upcoming bookings of every service grouped by day, matching
`/booking/my`; bookings open from it; it updates live. No backend issues.
