import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';
import '../../shared/controllers/listing_detail_controller.dart';

/// Restaurant listing (`GET /restaurant/:id`) + reviews + the seat type picked
/// on the details screen (passed to checkout as `'seatId'`).
class RestaurantDetailsController extends ListingDetailController<RestaurantDetail> {
  RestaurantDetailsController() : super(ServiceKind.restaurant);

  /// Seat type id picked on the details screen.
  String? selectedItemId;

  SeatType? get selectedItem => selectedItemId == null
      ? null
      : listing?.seats.firstWhereOrNull((s) => s.id == selectedItemId);

  /// A seat type can be picked when it has seats and a price. Free seats for a
  /// date and slot come from `/booking/availability` at checkout.
  static bool isSelectable(SeatType s) => s.quantity > 0 && s.price > 0;

  /// Bookable: active, with a selectable seat type and at least one slot.
  bool get isBookable {
    final r = listing;
    return canBook && r != null && r.slots.isNotEmpty && r.seats.any(isSelectable);
  }

  /// Cheapest seat price.
  num? get fromPrice {
    final prices = (listing?.seats ?? const <SeatType>[]).map((s) => s.price).where((p) => p > 0);
    return prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
  }

  void selectItem(String? itemId) {
    selectedItemId = itemId;
    update();
  }

  @override
  void onListingChanged() => selectedItemId = null;

  @override
  void onListingLoaded(RestaurantDetail listing) {
    final s = selectedItem;
    if (s == null || !isSelectable(s) || !listing.isActive) selectedItemId = null;
  }

  /// Back-compat names.
  RestaurantDetail? get restaurantDetails => listing;
  Future<bool> fetchRestaurantDetails(String id) => fetch(id);
}
