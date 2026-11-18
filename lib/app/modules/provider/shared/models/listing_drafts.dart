import 'dart:io';

import 'package:flutter/material.dart' show TimeOfDay;

import '../../../../data/api/peak_api.dart';

/// What the provider typed on a listing form, per service, and how it turns
/// into a [ListingForm]: everything on create, only what changed on edit.
///
/// Pure Dart (no widgets), so the "send only changed fields" rules are unit
/// tested in test/provider_listings/.

String _t(String? s) => (s ?? '').trim();

/// Value to send: always on create, otherwise only when it differs.
T? _ifChanged<T extends Object>(bool create, T? now, T? before) =>
    create || now != before ? now : null;

String? _textIfChanged(bool create, String now, String? before) =>
    _ifChanged(create, _t(now), _t(before));

num? _numIfChanged(bool create, num? now, num? before) {
  if (now == null) return null;
  if (create) return now;
  return (before == null || now != before) ? now : null;
}

/// "12", "12.5", "12,5" → number; blank or junk → null.
num? parseAmount(String? text) {
  final s = _t(text).replaceAll(',', '.');
  if (s.isEmpty) return null;
  final n = num.tryParse(s);
  return (n == null || !n.isFinite) ? null : n;
}

int? parseCount(String? text) {
  final n = parseAmount(text);
  if (n == null || n != n.roundToDouble()) return null;
  return n.toInt();
}

/// "7:00 PM" (the format the backend stores).
String formatClock(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period.name.toUpperCase()}';
}

/// Reads "7:00 PM", "07:00 pm", "19:00", "7 PM". Null if unreadable.
TimeOfDay? parseClock(String? text) {
  final s = _t(text).toUpperCase();
  final m = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?$').firstMatch(s);
  if (m == null) return null;
  var h = int.parse(m[1]!);
  final min = int.parse(m[2] ?? '0');
  final p = m[3];
  if (min > 59) return null;
  if (p != null) {
    if (h < 1 || h > 12) return null;
    if (p == 'AM' && h == 12) h = 0;
    if (p == 'PM' && h != 12) h += 12;
  } else if (h > 23) {
    return null;
  }
  return TimeOfDay(hour: h, minute: min);
}

int _mins(TimeOfDay t) => t.hour * 60 + t.minute;

/// Restaurant slot rules: ≤ 6 h, end after start, inside opening hours.
/// Opening hours may cross midnight (e.g. 6:00 PM – 2:00 AM). Returns a
/// message for the provider, or null when the slot is fine.
String? checkSlot({
  required String start,
  required String end,
  required String? openTime,
  required String? closeTime,
}) {
  final s = parseClock(start), e = parseClock(end);
  if (s == null || e == null) return 'Pick a start and end time.';
  var len = _mins(e) - _mins(s);
  if (len <= 0) len += 24 * 60; // ends after midnight
  if (len == 24 * 60) return 'A slot can’t start and end at the same time.';
  if (len > 6 * 60) return 'A slot can be at most 6 hours.';
  final o = parseClock(openTime), c = parseClock(closeTime);
  if (o == null || c == null) return null; // hours not set yet
  var openLen = _mins(c) - _mins(o);
  if (openLen <= 0) openLen += 24 * 60;
  var startOffset = _mins(s) - _mins(o);
  if (startOffset < 0) startOffset += 24 * 60;
  if (startOffset + len > openLen) {
    return 'Slots must be inside the opening hours ($openTime – $closeTime).';
  }
  return null;
}

// ─────────────────────────────── Ski pass ───────────────────────────────

class SkiPassDraft {
  SkiPassDraft({
    this.title = '',
    this.passType,
    this.price = '',
    List<PassService>? services,
    this.serviceArea = '',
    this.description = '',
    this.thumbnail,
  }) : services = services ?? [];

  factory SkiPassDraft.from(SkiPassDetail d) => SkiPassDraft(
        title: d.title,
        passType: d.passType,
        price: _plain(d.price.amount),
        services: List.of(d.services),
        serviceArea: d.serviceArea ?? '',
        description: d.description ?? '',
      );

  String title;
  PassType? passType;
  String price;
  List<PassService> services;
  String serviceArea;
  String description;
  File? thumbnail;

  List<PassService> get _cleanServices => [
        for (final s in services)
          if (_t(s.title).isNotEmpty)
            PassService(title: _t(s.title), description: _t(s.description)),
      ];

  ListingForm toForm([SkiPassDetail? original]) {
    final create = original == null;
    final now = _cleanServices;
    final servicesChanged = create || !_sameServices(now, original.services);
    return ListingForm.skiPass(
      title: _textIfChanged(create, title, original?.title),
      passType: _ifChanged(create, passType, original?.passType),
      price: _numIfChanged(create, parseAmount(price), original?.price.amount),
      services: servicesChanged ? now : null,
      serviceArea: _textIfChanged(create, serviceArea, original?.serviceArea),
      description: _textIfChanged(create, description, original?.description),
      thumbnail: thumbnail,
    );
  }

  static bool _sameServices(List<PassService> a, List<PassService> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_t(a[i].title) != _t(b[i].title) ||
          _t(a[i].description) != _t(b[i].description)) {
        return false;
      }
    }
    return true;
  }
}

// ─────────────────────────────── Ski hire ───────────────────────────────

class HireItemDraft {
  HireItemDraft({this.id, this.name = '', this.price = '', this.quantity = '', this.photo, this.photoUrl});

  factory HireItemDraft.from(HireItem i) => HireItemDraft(
        id: i.id.isEmpty ? null : i.id,
        name: i.name,
        price: _plain(i.price),
        quantity: '${i.quantity}',
        photoUrl: i.photo,
      );

  /// Set for items already saved.
  final String? id;
  String name;
  String price;
  String quantity;
  File? photo;
  String? photoUrl;

  HireItemInput toInput() => HireItemInput(
        id: id,
        name: _t(name),
        price: parseAmount(price) ?? 0,
        quantity: parseCount(quantity) ?? 0,
        photo: photo,
      );
}

const hirePriceUnits = ['per_day', 'per_hour', 'per_rental'];

class SkiHireDraft {
  SkiHireDraft({
    this.categoryId,
    this.title = '',
    this.serviceArea = '',
    this.description = '',
    this.priceUnit = 'per_day',
    this.lateFee = '',
    List<HireItemDraft>? items,
    this.thumbnail,
  }) : items = items ?? [HireItemDraft()];

  factory SkiHireDraft.from(SkiHireDetail d) => SkiHireDraft(
        categoryId: d.subCategory?.id,
        title: d.title,
        serviceArea: d.serviceArea ?? '',
        description: d.description ?? '',
        priceUnit: hirePriceUnits.contains(d.priceUnit) ? d.priceUnit : 'per_day',
        lateFee: _plain(d.extraChargePerHour),
        items: d.items.isEmpty ? null : d.items.map(HireItemDraft.from).toList(),
      );

  String? categoryId;
  String title;
  String serviceArea;
  String description;
  String priceUnit;
  String lateFee;
  List<HireItemDraft> items;
  File? thumbnail;

  /// Saved items the provider deleted on this form.
  List<String> removedItemIds([SkiHireDetail? original]) {
    if (original == null) return const [];
    final kept = items.map((i) => i.id).whereType<String>().toSet();
    return [
      for (final i in original.items)
        if (i.id.isNotEmpty && !kept.contains(i.id)) i.id,
    ];
  }

  ListingForm toForm([SkiHireDetail? original]) {
    final create = original == null;
    final byId = {for (final i in original?.items ?? const <HireItem>[]) i.id: i};
    final sent = <HireItemInput>[];
    for (final d in items) {
      final input = d.toInput();
      final before = d.id == null ? null : byId[d.id];
      final changed = create ||
          before == null ||
          d.photo != null ||
          input.name != before.name ||
          input.price != before.price ||
          input.quantity != before.quantity;
      if (changed) sent.add(input);
    }
    final removed = removedItemIds(original);
    return ListingForm.skiHire(
      categoryId: _ifChanged(create, categoryId, original?.subCategory?.id),
      title: _textIfChanged(create, title, original?.title),
      serviceArea: _textIfChanged(create, serviceArea, original?.serviceArea),
      description: create
          ? (_t(description).isEmpty ? null : _t(description))
          : _textIfChanged(false, description, original.description),
      priceUnit: _ifChanged(create, priceUnit, original?.priceUnit),
      extraChargePerHour: _numIfChanged(create, parseAmount(lateFee) ?? (create ? 0 : null), original?.extraChargePerHour),
      items: sent.isEmpty && !create ? null : sent,
      removeItemIds: removed,
      thumbnail: thumbnail,
    );
  }
}

// ─────────────────────────────── Transport ───────────────────────────────

class TransportDraft {
  TransportDraft({
    this.categoryId,
    this.title = '',
    this.serviceArea = '',
    this.amount = '',
    this.seats = '',
    this.mileage = '',
    this.power = '',
    this.lateFee = '',
    this.description = '',
    this.thumbnail,
  });

  factory TransportDraft.from(TransportDetail d) => TransportDraft(
        categoryId: d.subCategory?.id,
        title: d.title,
        serviceArea: d.serviceArea ?? '',
        amount: _plain(d.price.amount),
        seats: d.seats?.toString() ?? '',
        mileage: d.mileage ?? '',
        power: d.power ?? '',
        lateFee: _plainOrEmpty(d.extraChargePerHour),
        description: d.description ?? '',
      );

  String? categoryId;
  String title;
  String serviceArea;
  String amount;
  String seats;
  String mileage;
  String power;
  String lateFee;
  String description;
  File? thumbnail;

  ListingForm toForm([TransportDetail? original]) {
    final create = original == null;
    final seatCount = parseCount(seats);
    return ListingForm.transport(
      categoryId: _ifChanged(create, categoryId, original?.subCategory?.id),
      title: _textIfChanged(create, title, original?.title),
      serviceArea: _textIfChanged(create, serviceArea, original?.serviceArea),
      amount: _numIfChanged(create, parseAmount(amount), original?.price.amount),
      seats: seatCount == null ? null : (create || seatCount != original.seats ? seatCount : null),
      mileage: _textIfChanged(create, mileage, original?.mileage),
      power: create ? (_t(power).isEmpty ? null : _t(power)) : _textIfChanged(false, power, original.power),
      extraChargePerHour: _numIfChanged(create, parseAmount(lateFee), original?.extraChargePerHour),
      // The trip price is all-inclusive; no separate insurance or maintenance
      // fee. The server still requires both on create, so send 0 until it
      // drops them (docs/backend_issues.md, T2).
      insuranceFee: create ? 0 : null,
      maintenanceFee: create ? 0 : null,
      description: create
          ? (_t(description).isEmpty ? null : _t(description))
          : _textIfChanged(false, description, original.description),
      thumbnail: thumbnail,
    );
  }
}

// ─────────────────────────────── Restaurant ───────────────────────────────

const seatTypes = ['VIP', 'Normal'];

class SeatDraft {
  SeatDraft({this.id, required this.type, this.price = '', this.quantity = '', this.description = '', this.photo, this.photoUrl});

  factory SeatDraft.from(SeatType s) => SeatDraft(
        id: s.id.isEmpty ? null : s.id,
        type: s.type,
        price: _plain(s.price),
        quantity: '${s.quantity}',
        description: s.description ?? '',
        photoUrl: s.photo,
      );

  final String? id;
  String type;
  String price;
  String quantity;
  String description;
  File? photo;
  String? photoUrl;

  bool get hasPhoto => photo != null || _t(photoUrl).isNotEmpty;

  SeatInput toInput() => SeatInput(
        id: id,
        type: type,
        price: parseAmount(price) ?? 0,
        quantity: parseCount(quantity) ?? -1,
        description: _t(description),
        photo: photo,
        photoUrl: photoUrl,
      );
}

class SlotDraft {
  SlotDraft({this.id, required this.startTime, required this.endTime});
  factory SlotDraft.from(TimeSlot s) =>
      SlotDraft(id: s.id.isEmpty ? null : s.id, startTime: s.startTime, endTime: s.endTime);

  final String? id;
  String startTime;
  String endTime;

  String get label => '$startTime – $endTime';
}

class RestaurantDraft {
  RestaurantDraft({
    this.categoryId,
    this.title = '',
    this.serviceArea = '',
    this.openTime,
    this.closeTime,
    this.foodType = '',
    this.description = '',
    List<SeatDraft>? seats,
    List<SlotDraft>? slots,
    this.thumbnail,
  })  : seats = seats ?? [],
        slots = slots ?? [];

  factory RestaurantDraft.from(RestaurantDetail d) => RestaurantDraft(
        categoryId: d.subCategory?.id,
        title: d.title,
        serviceArea: d.serviceArea ?? '',
        openTime: d.openTime,
        closeTime: d.closeTime,
        foodType: d.foodType ?? '',
        description: d.description ?? '',
        seats: d.seats.map(SeatDraft.from).toList(),
        slots: d.slots.map(SlotDraft.from).toList(),
      );

  String? categoryId;
  String title;
  String serviceArea;
  String? openTime;
  String? closeTime;
  String foodType;
  String description;
  List<SeatDraft> seats;
  List<SlotDraft> slots;
  File? thumbnail;

  /// First slot problem, or null.
  String? slotProblem() {
    for (final s in slots) {
      final p = checkSlot(start: s.startTime, end: s.endTime, openTime: openTime, closeTime: closeTime);
      if (p != null) return '${s.label}: $p';
    }
    return null;
  }

  ListingForm toForm([RestaurantDetail? original]) {
    final create = original == null;
    final seatsById = {for (final s in original?.seats ?? const <SeatType>[]) s.id: s};
    final sentSeats = <SeatInput>[];
    for (final d in seats) {
      final input = d.toInput();
      final before = d.id == null ? null : seatsById[d.id];
      final changed = create ||
          before == null ||
          d.photo != null ||
          input.type != before.type ||
          input.price != before.price ||
          input.quantity != before.quantity ||
          (input.description ?? '') != (before.description ?? '');
      if (changed) sentSeats.add(input);
    }
    final slotsById = {for (final s in original?.slots ?? const <TimeSlot>[]) s.id: s};
    final sentSlots = <SlotInput>[];
    for (final d in slots) {
      final before = d.id == null ? null : slotsById[d.id];
      if (create || before == null || before.startTime != d.startTime || before.endTime != d.endTime) {
        sentSlots.add(SlotInput(id: d.id, startTime: d.startTime, endTime: d.endTime));
      }
    }
    final keptSeats = seats.map((s) => s.id).whereType<String>().toSet();
    final keptSlots = slots.map((s) => s.id).whereType<String>().toSet();
    return ListingForm.restaurant(
      categoryId: _ifChanged(create, categoryId, original?.subCategory?.id),
      title: _textIfChanged(create, title, original?.title),
      serviceArea: _textIfChanged(create, serviceArea, original?.serviceArea),
      openTime: _ifChanged(create, openTime, original?.openTime),
      closeTime: _ifChanged(create, closeTime, original?.closeTime),
      foodType: create ? (_t(foodType).isEmpty ? null : _t(foodType)) : _textIfChanged(false, foodType, original.foodType),
      description: create
          ? (_t(description).isEmpty ? null : _t(description))
          : _textIfChanged(false, description, original.description),
      seats: sentSeats.isEmpty && !create ? null : sentSeats,
      slots: sentSlots.isEmpty && !create ? null : sentSlots,
      removeSeatIds: [
        for (final s in original?.seats ?? const <SeatType>[])
          if (s.id.isNotEmpty && !keptSeats.contains(s.id)) s.id,
      ],
      removeSlotIds: [
        for (final s in original?.slots ?? const <TimeSlot>[])
          if (s.id.isNotEmpty && !keptSlots.contains(s.id)) s.id,
      ],
      thumbnail: thumbnail,
    );
  }
}

// ─────────────────────────────── Massage ───────────────────────────────

class DurationDraft {
  DurationDraft({this.id, this.minutes, this.raw = '', this.price = ''}) : _savedMinutes = minutes;

  factory DurationDraft.from(MassageDuration d) => DurationDraft(
        id: d.id.isEmpty ? null : d.id,
        minutes: d.minutes,
        raw: d.duration,
        price: _plain(d.price),
      );

  final int? _savedMinutes;

  final String? id;

  /// Picked length; null keeps [raw] (a legacy value).
  int? minutes;
  String raw;
  String price;

  /// The saved text while the length is unchanged (e.g. "11 hr 22 min"),
  /// otherwise "<minutes> min".
  String get duration {
    if (_t(raw).isNotEmpty && minutes == _savedMinutes) return _t(raw);
    return minutes != null && minutes! > 0 ? '$minutes min' : _t(raw);
  }

  String get label {
    final m = minutes;
    if (m == null || m <= 0) return _t(raw).isEmpty ? 'Choose' : _t(raw);
    final h = m ~/ 60, r = m % 60;
    if (h == 0) return '$r min';
    return r == 0 ? '$h h' : '$h h $r min';
  }
}

class MassageDraft {
  MassageDraft({
    this.categoryId,
    this.title = '',
    this.openTime,
    this.closeTime,
    List<DurationDraft>? durations,
    this.serviceArea = '',
    this.benefits = '',
    this.recommendations = '',
    this.description = '',
    this.thumbnail,
    this.capacity = 1,
  }) : durations = durations ?? [DurationDraft()];

  factory MassageDraft.from(MassageDetail d) => MassageDraft(
        categoryId: d.subCategory?.id,
        title: d.title,
        openTime: d.openTime,
        closeTime: d.closeTime,
        durations: d.durations.isEmpty ? null : d.durations.map(DurationDraft.from).toList(),
        serviceArea: d.serviceArea ?? '',
        benefits: d.benefits ?? '',
        recommendations: d.recommendations ?? '',
        description: d.description ?? '',
        capacity: d.capacity,
      );

  String? categoryId;
  String title;
  String? openTime;
  String? closeTime;
  List<DurationDraft> durations;
  String serviceArea;
  String benefits;
  String recommendations;
  String description;
  File? thumbnail;

  /// Guests at the same time (therapists), 1–50.
  int capacity;

  List<DurationInput> get _inputs => [
        for (final d in durations)
          DurationInput(id: d.id, duration: d.duration, price: parseAmount(d.price) ?? 0),
      ];

  ListingForm toForm([MassageDetail? original]) {
    final create = original == null;
    final now = _inputs;
    // The server replaces the whole list, so send all of it when anything changed.
    var changed = create || now.length != original.durations.length;
    if (!changed) {
      for (var i = 0; i < now.length; i++) {
        final b = original.durations[i];
        if (now[i].id != b.id || now[i].duration != b.duration || now[i].price != b.price) {
          changed = true;
          break;
        }
      }
    }
    return ListingForm.massage(
      categoryId: _ifChanged(create, categoryId, original?.subCategory?.id),
      title: _textIfChanged(create, title, original?.title),
      openTime: _ifChanged(create, openTime, original?.openTime),
      closeTime: _ifChanged(create, closeTime, original?.closeTime),
      durations: changed ? now : null,
      serviceArea: _textIfChanged(create, serviceArea, original?.serviceArea),
      benefits: _textIfChanged(create, benefits, original?.benefits),
      recommendations: _textIfChanged(create, recommendations, original?.recommendations),
      description: create
          ? (_t(description).isEmpty ? null : _t(description))
          : _textIfChanged(false, description, original.description),
      thumbnail: thumbnail,
      capacity: create || capacity != original.capacity ? capacity : null,
    );
  }
}

String _plain(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
String _plainOrEmpty(num? v) => v == null ? '' : _plain(v);
