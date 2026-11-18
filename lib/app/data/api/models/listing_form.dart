import 'dart:convert';
import 'dart:io';

import 'listing.dart';
import 'service_kind.dart';

/// Hire item in a create/update form. Send [id] to change an existing item.
class HireItemInput {
  const HireItemInput({this.id, required this.name, required this.price, required this.quantity, this.photo});
  final String? id;
  final String name;
  final num price;
  final int quantity;

  /// New photo; null keeps the old one.
  final File? photo;

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'name': name.trim(),
        'price': price,
        'quantity': quantity,
      };
}

/// Restaurant seat type in a form. Send [id] to change an existing seat.
class SeatInput {
  const SeatInput({this.id, required this.type, required this.price, required this.quantity, this.description, this.photo, this.photoUrl});
  final String? id;

  /// `VIP` or `Normal`.
  final String type;
  final num price;
  final int quantity;
  final String? description;
  final File? photo;

  /// Existing photo URL (kept when no new [photo]).
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'type': type,
        'price': price,
        'quantity': quantity,
        if (description != null) 'description': description!.trim(),
        if (photo == null && photoUrl != null && photoUrl!.isNotEmpty) 'photo': photoUrl,
      };
}

/// Restaurant slot in a form ("7:00 PM"). Send [id] to edit an existing slot.
class SlotInput {
  const SlotInput({this.id, required this.startTime, required this.endTime});
  final String? id;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'startTime': startTime,
        'endTime': endTime,
      };
}

/// Massage duration in a form, e.g. `"60 min"` or `"1h 30"`.
class DurationInput {
  const DurationInput({this.id, required this.duration, required this.price});
  final String? id;
  final String duration;
  final num price;

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'duration': duration.trim(),
        'price': price,
      };
}

/// Multipart body for `POST /<service>` (create) and `PATCH /<service>/:id`.
///
/// Null arguments are left out, so an update sends only what changed.
/// [validateForCreate] lists what the server would reject on create.
class ListingForm {
  ListingForm._(this.kind, this.fields, this.files, this._isComplete);

  factory ListingForm.skiPass({
    String? title,
    PassType? passType,
    num? price,
    List<PassService>? services,
    String? serviceArea,
    String? description,
    File? thumbnail,
  }) {
    final f = <String, String>{};
    _put(f, 'title', title);
    _put(f, 'passType', passType?.apiValue);
    _put(f, 'price', price?.toString());
    if (services != null) {
      f['services'] = jsonEncode(services.where((s) => s.title.trim().isNotEmpty).map((s) => s.toJson()).toList());
    }
    _put(f, 'serviceArea', serviceArea);
    _put(f, 'description', description);
    return ListingForm._(
      ServiceKind.skiPass,
      f,
      {if (thumbnail != null) 'file': thumbnail},
      () => [
        if (!f.containsKey('title')) 'Add a title.',
        if (!f.containsKey('passType')) 'Choose a pass type.',
        if ((price ?? 0) <= 0) 'Enter a price above 0.',
        if (services == null || !services.any((s) => s.title.trim().isNotEmpty)) 'Add at least one service.',
        if (!f.containsKey('serviceArea')) 'Add the service area.',
        if (!f.containsKey('description')) 'Add a description.',
        if (thumbnail == null) 'Add a photo.',
      ],
    );
  }

  factory ListingForm.skiHire({
    String? categoryId,
    String? title,
    String? serviceArea,
    String? description,
    String? priceUnit,
    num? extraChargePerHour,
    List<HireItemInput>? items,
    List<String>? removeItemIds,
    File? thumbnail,
  }) {
    final f = <String, String>{};
    _put(f, 'category', categoryId);
    _put(f, 'title', title);
    _put(f, 'serviceArea', serviceArea);
    if (description != null) f['description'] = description.trim();
    _put(f, 'priceUnit', priceUnit);
    _put(f, 'extraChargePerHour', extraChargePerHour?.toString());
    final files = <String, File>{if (thumbnail != null) 'thumbnail': thumbnail};
    if (items != null) {
      f['items'] = jsonEncode(items.map((i) => i.toJson()).toList());
      for (var i = 0; i < items.length; i++) {
        final p = items[i].photo;
        if (p != null) files['itemPhoto_$i'] = p;
      }
    }
    if (removeItemIds != null && removeItemIds.isNotEmpty) {
      f['removeItemIds'] = jsonEncode(removeItemIds);
    }
    return ListingForm._(
      ServiceKind.skiHire,
      f,
      files,
      () => [
        if (!f.containsKey('category')) 'Choose a category.',
        if (!f.containsKey('title')) 'Add a title.',
        if (!f.containsKey('serviceArea')) 'Add the service area.',
        if (items == null || items.isEmpty) 'Add at least one item.',
        ..._hireItemErrors(items ?? const []),
        if ((extraChargePerHour ?? 0) < 0) 'The late fee can’t be negative.',
        if (thumbnail == null) 'Add a photo.',
      ],
    );
  }

  factory ListingForm.transport({
    String? categoryId,
    String? title,
    String? serviceArea,
    num? amount,
    int? seats,
    String? mileage,
    String? power,
    num? extraChargePerHour,
    num? insuranceFee,
    num? maintenanceFee,
    String? description,
    File? thumbnail,
  }) {
    final f = <String, String>{};
    _put(f, 'category', categoryId);
    _put(f, 'title', title);
    _put(f, 'serviceArea', serviceArea);
    _put(f, 'amount', amount?.toString());
    _put(f, 'seats', seats?.toString());
    _put(f, 'mileage', mileage);
    if (power != null) f['power'] = power.trim();
    _put(f, 'extraChargePerHour', extraChargePerHour?.toString());
    _put(f, 'insuranceFee', insuranceFee?.toString());
    _put(f, 'maintenanceFee', maintenanceFee?.toString());
    if (description != null) f['description'] = description.trim();
    return ListingForm._(
      ServiceKind.transport,
      f,
      {if (thumbnail != null) 'file': thumbnail},
      () => [
        if (!f.containsKey('category')) 'Choose a category.',
        if (!f.containsKey('title')) 'Add a title.',
        if (!f.containsKey('serviceArea')) 'Add the service area.',
        if ((amount ?? 0) <= 0) 'Enter a price above 0.',
        if ((seats ?? 0) < 1) 'Enter at least 1 seat.',
        if (!f.containsKey('mileage')) 'Add the mileage.',
        if (extraChargePerHour == null || extraChargePerHour < 0) 'Enter the late fee per hour (0 or more).',
        if (thumbnail == null) 'Add a photo.',
      ],
    );
  }

  factory ListingForm.restaurant({
    String? categoryId,
    String? title,
    String? serviceArea,
    String? openTime,
    String? closeTime,
    String? description,
    String? foodType,
    List<SeatInput>? seats,
    List<SlotInput>? slots,
    List<String>? removeSeatIds,
    List<String>? removeSlotIds,
    File? thumbnail,
  }) {
    final f = <String, String>{};
    _put(f, 'category', categoryId);
    _put(f, 'title', title);
    _put(f, 'serviceArea', serviceArea);
    _put(f, 'openTime', openTime);
    _put(f, 'closeTime', closeTime);
    if (description != null) f['description'] = description.trim();
    if (foodType != null) f['foodType'] = foodType.trim();
    final files = <String, File>{if (thumbnail != null) 'thumbnail': thumbnail};
    if (seats != null) {
      f['seats'] = jsonEncode(seats.map((s) => s.toJson()).toList());
      for (var i = 0; i < seats.length; i++) {
        final p = seats[i].photo;
        if (p != null) files['files[$i]'] = p;
      }
    }
    if (slots != null) f['slots'] = jsonEncode(slots.map((s) => s.toJson()).toList());
    if (removeSeatIds != null && removeSeatIds.isNotEmpty) f['removeSeatIds'] = jsonEncode(removeSeatIds);
    if (removeSlotIds != null && removeSlotIds.isNotEmpty) f['removeSlotIds'] = jsonEncode(removeSlotIds);
    return ListingForm._(
      ServiceKind.restaurant,
      f,
      files,
      () {
        final s = seats ?? const <SeatInput>[];
        final types = s.map((e) => e.type.toLowerCase()).toList();
        return [
          if (!f.containsKey('title')) 'Add a title.',
          if (!f.containsKey('category')) 'Choose a category.',
          if (!f.containsKey('serviceArea')) 'Add the service area.',
          if (!f.containsKey('openTime') || !f.containsKey('closeTime')) 'Set the opening hours.',
          if (s.isEmpty || s.length > 2) 'Add one or two seat types.',
          if (types.toSet().length != types.length) 'Each seat type can be added once.',
          if (s.any((e) => e.price < 1)) 'Seat prices must be at least 1.',
          if (s.any((e) => e.quantity < 0)) 'Seat counts can’t be negative.',
          if (s.any((e) => e.photo == null && (e.photoUrl ?? '').isEmpty)) 'Add a photo for each seat type.',
          if (slots == null || slots.isEmpty) 'Add at least one time slot.',
          if (thumbnail == null) 'Add a photo.',
        ];
      },
    );
  }

  factory ListingForm.massage({
    String? categoryId,
    String? title,
    String? openTime,
    String? closeTime,
    List<DurationInput>? durations,
    String? serviceArea,
    String? benefits,
    String? recommendations,
    String? description,
    File? thumbnail,
    int? capacity,
  }) {
    final f = <String, String>{};
    _put(f, 'category', categoryId);
    _put(f, 'title', title);
    if (capacity != null) f['capacity'] = '$capacity';
    _put(f, 'openTime', openTime);
    _put(f, 'closeTime', closeTime);
    if (durations != null) f['durations'] = jsonEncode(durations.map((d) => d.toJson()).toList());
    _put(f, 'serviceArea', serviceArea);
    _put(f, 'benefits', benefits);
    _put(f, 'recommendations', recommendations);
    if (description != null) f['description'] = description.trim();
    return ListingForm._(
      ServiceKind.massage,
      f,
      {if (thumbnail != null) 'file': thumbnail},
      () {
        final d = durations ?? const <DurationInput>[];
        final keys = d.map((e) => e.duration.trim().toLowerCase()).toList();
        return [
          if (!f.containsKey('category')) 'Choose a category.',
          if (!f.containsKey('title')) 'Add a title.',
          if (!f.containsKey('openTime') || !f.containsKey('closeTime')) 'Set the opening hours.',
          if (d.isEmpty) 'Add at least one duration.',
          if (d.length > 20) 'Use at most 20 durations.',
          if (capacity != null && (capacity < 1 || capacity > 50)) 'Guests at the same time: 1 to 50.',
          if (keys.toSet().length != keys.length) 'Each duration can be added once.',
          if (d.any((e) => e.price <= 0)) 'Duration prices must be above 0.',
          if (d.any((e) => e.duration.trim().isEmpty)) 'Every price needs a duration.',
          if (!f.containsKey('serviceArea')) 'Add the service area.',
          if (!f.containsKey('benefits')) 'Add the benefits.',
          if (!f.containsKey('recommendations')) 'Add recommendations.',
          if (thumbnail == null) 'Add a photo.',
        ];
      },
    );
  }

  final ServiceKind kind;
  final Map<String, String> fields;
  final Map<String, File> files;
  final List<String> Function() _isComplete;

  /// Problems that would make a create fail (empty = OK).
  List<String> validateForCreate() => _isComplete();

  bool get isEmpty => fields.isEmpty && files.isEmpty;

  static void _put(Map<String, String> f, String key, String? value) {
    final v = value?.trim();
    if (v != null && v.isNotEmpty) f[key] = v;
  }

  static List<String> _hireItemErrors(List<HireItemInput> items) {
    final out = <String>[];
    for (final i in items) {
      final n = i.name.trim();
      if (n.length < 2 || !RegExp(r'[A-Za-z]').hasMatch(n)) {
        out.add('Item names need at least 2 characters, with letters.');
        break;
      }
    }
    if (items.any((i) => i.price <= 0)) out.add('Item prices must be above 0.');
    if (items.any((i) => i.quantity < 1)) out.add('Item quantities must be at least 1.');
    return out;
  }
}
