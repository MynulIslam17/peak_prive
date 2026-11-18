import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../data/api/peak_api.dart';
import '../../../../../routes/app_routes.dart';
import '../../controllers/listing_browse_controller.dart';

/// The services a user can browse on the home screen.
enum HomeServiceType {
  skiPass('ski_pass', 'Ski Pass', 'Top ski passes', ServiceKind.skiPass),
  skiHire('ski_hire', 'Ski Hire', 'Top ski hire', ServiceKind.skiHire),
  transport('transport', 'Transport', 'Top cars in town', ServiceKind.transport),
  massage('massage', 'Massage', 'Top massage providers', ServiceKind.massage),
  restaurant('restaurant', 'Restaurants', 'Popular restaurants', ServiceKind.restaurant);

  const HomeServiceType(this.key, this.label, this.listTitle, this.kind);

  /// Backend service.
  final ServiceKind kind;

  /// Value stored in [NavController] (e.g. `"ski_pass"`).
  final String key;
  final String label;
  final String listTitle;

  static HomeServiceType? fromKey(String key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    return null;
  }
}

/// UI-facing summary of a single service listing, independent of the API model.
@immutable
class HomeListing {
  const HomeListing({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.price,
    this.priceIsFrom = false,
    this.priceUnit = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.location = '',
    this.badge,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// `null` when the service has no single price (e.g. restaurants).
  final num? price;

  /// True when [price] is the cheapest option ("from €20").
  final bool priceIsFrom;

  /// Shown after the price, e.g. "/day".
  final String priceUnit;
  final double rating;
  final int reviewCount;
  final String location;

  /// Small label shown over the image (e.g. the ski pass type).
  final String? badge;
}

/// Adapts the service's [ListingBrowseController] to what the home screen
/// needs, so the screen never branches on the service type.
class HomeServiceSource {
  HomeServiceSource(this.type);

  final HomeServiceType type;

  ListingBrowseController get controller => ListingBrowseController.of(type.kind);

  /// Route opened when a listing is tapped; receives `{'id': listing.id}`.
  String get detailsRoute => switch (type) {
        HomeServiceType.skiPass => Routes.passCardDetails,
        HomeServiceType.skiHire => Routes.hireDetails,
        HomeServiceType.transport => Routes.transportDetails,
        HomeServiceType.massage => Routes.massageDetails,
        HomeServiceType.restaurant => Routes.restaurantDetails,
      };

  bool get supportsCategories => type.kind.hasSubCategories;

  bool get isLoading => controller.isLoading;
  bool get isMoreLoading => controller.isMoreLoading;
  bool get hasMore => controller.hasMore;
  String? get errorMessage => controller.errorMessage;
  bool get isCategoryLoading => controller.isCategoryLoading;
  List<CategoryOption> get categories => controller.categories;

  List<HomeListing> get listings => [for (final l in controller.listings) toHomeListing(l)];

  /// Fresh load from page 1. [category] is a sub-category id; null = "All".
  Future<void> load({String? category, String? search}) =>
      controller.load(subCategory: category, search: search);

  /// Next page, keeping the current filters.
  Future<void> loadMore({String? category, String? search}) => controller.loadMore();

  /// Debounced search.
  void search(String query, {String? category}) =>
      controller.searchDebounced(query, subCategory: category);

  /// Rebuilds [builder] whenever the controller calls `update()`.
  Widget observe(WidgetBuilder builder) => GetBuilder<ListingBrowseController>(
        tag: type.kind.name,
        builder: (_) => Builder(builder: builder),
      );

  static HomeServiceSource? forKey(String key) {
    final type = HomeServiceType.fromKey(key);
    return type == null ? null : HomeServiceSource(type);
  }
}

/// Card → home tile. Hire, restaurant and massage cards carry the cheapest
/// option, so they read "from €15 / day".
HomeListing toHomeListing(ListingCard l) {
  final unit = l.price.unitLabel;
  final isFrom = l.kind == ServiceKind.skiHire ||
      l.kind == ServiceKind.restaurant ||
      l.kind == ServiceKind.massage;
  return HomeListing(
    id: l.id,
    title: l.title,
    imageUrl: l.thumbnail ?? '',
    price: l.price.amount > 0 ? l.price.amount : null,
    priceIsFrom: isFrom,
    priceUnit: unit.isEmpty ? '' : ' / $unit',
    rating: l.rating.average,
    reviewCount: l.rating.count,
    location: l.serviceArea ?? '',
    badge: l.passType?.label,
  );
}
