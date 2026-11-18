import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';
import '../../shared/controllers/listing_detail_controller.dart';
import '../models/hire_price_unit.dart';

/// Ski hire listing + the equipment the user is choosing.
///
/// The selection is also passed to checkout as `'selection'` (itemId → qty).
class HireDetailsController extends ListingDetailController<SkiHireDetail> {
  HireDetailsController() : super(ServiceKind.skiHire);

  /// itemId → quantity (only items with quantity > 0).
  final Map<String, int> selectedItems = {};

  List<HireItem> get items => listing?.items ?? const [];

  HireItem? itemById(String id) => items.firstWhereOrNull((i) => i.id == id);

  int getQuantity(String itemId) => selectedItems[itemId] ?? 0;

  /// Total stock. Free units for the chosen dates are checked at checkout
  /// (`/booking/availability`).
  int maxQuantity(HireItem item) => item.quantity < 0 ? 0 : item.quantity;

  bool canAdd(HireItem item) => canBook && getQuantity(item.id) < maxQuantity(item);

  void addItem(String itemId) {
    final item = itemById(itemId);
    if (item == null || !canAdd(item)) return;
    selectedItems[itemId] = getQuantity(itemId) + 1;
    update();
  }

  void removeItem(String itemId) {
    final qty = getQuantity(itemId);
    if (qty <= 1) {
      selectedItems.remove(itemId);
    } else {
      selectedItems[itemId] = qty - 1;
    }
    update();
  }

  void clearSelection() {
    if (selectedItems.isEmpty) return;
    selectedItems.clear();
    update();
  }

  /// Selected items with their quantity, in listing order.
  List<(HireItem, int)> get selectedLines => [
        for (final item in items)
          if (getQuantity(item.id) > 0) (item, getQuantity(item.id)),
      ];

  int get selectedCount => selectedItems.values.fold(0, (sum, q) => sum + q);

  HirePriceUnit get priceUnit => HirePriceUnit.parse(listing?.priceUnit);

  /// Sum of price × quantity for one price unit, rounded to cents.
  double get totalSelectedPrice {
    final total = selectedLines.fold<double>(0, (s, l) => s + l.$1.price * l.$2);
    return double.parse(total.toStringAsFixed(2));
  }

  /// Estimate for [start]–[end] (same formula as `/booking/intent`; the
  /// server's amount is what gets charged).
  double totalFor(DateTime start, DateTime end) =>
      double.parse((totalSelectedPrice * priceUnit.unitsFor(start, end)).toStringAsFixed(2));

  @override
  void onListingChanged() => selectedItems.clear();

  @override
  void onListingLoaded(SkiHireDetail listing) {
    // Drop selections no longer valid (item removed / stock went down).
    selectedItems.removeWhere((id, qty) {
      final item = itemById(id);
      return item == null || qty > maxQuantity(item);
    });
    if (!listing.isActive) selectedItems.clear();
  }

  /// Back-compat name used by older call sites.
  Future<bool> fetchHireDetails(String id) => fetch(id);
}
