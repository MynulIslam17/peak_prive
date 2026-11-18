import 'package:get/get.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../data/api/peak_api.dart';

/// What happened when the provider tried to delete a listing.
enum DeleteOutcome { deleted, hasOpenBookings, failed }

/// "My services": the provider's own listings (active and inactive) for
/// their `providerType`, with show/hide and delete. Shared by all five
/// provider types.
class MyListingsController extends GetxController {
  MyListingsController({ServiceKind? kind}) : _kind = kind;

  final ServiceKind? _kind;

  ListingApi get _api => Get.find<PeakApi>().listings;

  /// The logged-in provider's service, or null for an unknown type.
  ServiceKind? get kind {
    if (_kind != null) return _kind;
    if (!Get.isRegistered<AuthController>()) return null;
    return ServiceKind.parse(Get.find<AuthController>().userModel?.providerType);
  }

  List<ListingCard> listings = const [];
  bool isLoading = false;
  String? errorMessage;

  /// Listings with a status change or delete in flight.
  final Set<String> busyIds = {};

  /// Last delete/toggle failure, for a toast.
  String? actionError;

  int get activeCount => listings.where((l) => l.isActive).length;

  Future<void> load({bool showLoader = true}) async {
    final k = kind;
    if (k == null) {
      errorMessage = "Your account has no service type. Contact support.";
      listings = const [];
      update();
      return;
    }
    // The skeleton is only for a first load; a loaded list stays visible
    // while it refreshes (and is kept if the refresh fails).
    isLoading = showLoader && !_fetched;
    errorMessage = null;
    update();
    final r = await _api.allMine(k);
    if (r.isSuccess) {
      // Keep a just-saved listing the server's list doesn't show yet.
      final ids = r.data!.map((l) => l.id).toSet();
      listings = [
        for (final l in listings)
          if (_pendingIds.contains(l.id) && !ids.contains(l.id)) l,
        ...r.data!,
      ];
      _pendingIds.removeWhere(ids.contains);
      _fetched = true;
    } else {
      errorMessage = r.errorMessage;
    }
    isLoading = false;
    update();
  }

  bool _fetched = false;

  /// Saved listings not yet seen in a reload of the server list.
  final Set<String> _pendingIds = {};

  /// Puts a just-created or just-edited listing into the list at once
  /// (new ones on top); a quiet reload syncs the rest.
  void upsert(ListingCard card) {
    final exists = listings.any((l) => l.id == card.id);
    listings = exists ? [for (final l in listings) l.id == card.id ? card : l] : [card, ...listings];
    if (!exists) _pendingIds.add(card.id);
    update();
  }

  /// Shows or hides [card] in browse. Optimistic; reverts on failure.
  /// Returns null on success or a message.
  Future<String?> setActive(ListingCard card, bool active) async {
    if (busyIds.contains(card.id) || card.isActive == active) return null;
    busyIds.add(card.id);
    _replace(card.id, _withActive(card, active));
    final r = await _api.setActive(card.kind, card.id, active);
    busyIds.remove(card.id);
    if (r.isSuccess) {
      _replace(card.id, _withActive(card, r.data ?? active));
      return null;
    }
    _replace(card.id, card);
    actionError = r.errorMessage;
    update();
    return r.errorMessage;
  }

  /// Deletes [card]. A 409 means it still has open bookings: offer
  /// "Set inactive instead" ([setActive] with false).
  Future<DeleteOutcome> delete(ListingCard card) async {
    if (busyIds.contains(card.id)) return DeleteOutcome.failed;
    busyIds.add(card.id);
    actionError = null;
    // Optimistic: the card leaves at once and comes back if refused.
    final before = listings;
    listings = [for (final l in listings) if (l.id != card.id) l];
    update();
    final r = await _api.delete(card.kind, card.id);
    busyIds.remove(card.id);
    if (r.isSuccess || r.failure!.isNotFound) {
      // 404: already gone (deleted on another device).
      update();
      return DeleteOutcome.deleted;
    }
    listings = [
      for (final l in before)
        if (l.id == card.id || listings.any((x) => x.id == l.id)) l,
    ];
    actionError = r.errorMessage;
    update();
    return r.failure!.isConflict ? DeleteOutcome.hasOpenBookings : DeleteOutcome.failed;
  }

  void _replace(String id, ListingCard next) {
    listings = [for (final l in listings) l.id == id ? next : l];
    update();
  }

  static ListingCard _withActive(ListingCard c, bool active) => ListingCard(
        id: c.id,
        kind: c.kind,
        title: c.title,
        price: c.price,
        rating: c.rating,
        isActive: active,
        subCategory: c.subCategory,
        thumbnail: c.thumbnail,
        serviceArea: c.serviceArea,
        provider: c.provider,
        passType: c.passType,
      );
}

/// Card price label: "€45 / person", "from €25 / day", "No price yet".
String listingPriceLabel(ListingCard c) {
  if (c.price.amount <= 0) return 'No price yet';
  final unit = c.price.unitLabel;
  final from = c.kind == ServiceKind.skiHire ||
      c.kind == ServiceKind.restaurant ||
      c.kind == ServiceKind.massage;
  return '${from ? 'from ' : ''}${euroLabel(c.price.amount)}${unit.isEmpty ? '' : ' / $unit'}';
}
