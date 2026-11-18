import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';

/// Browse one service's listings (`GET /<service>`) with search, a
/// sub-category filter, paging and the sub-category list.
///
/// One instance per service, registered with `tag: kind.name`
/// (see [ListingBrowseController.register] / [ListingBrowseController.of]).
class ListingBrowseController extends GetxController {
  ListingBrowseController(this.kind, {this.pageSize = 10, this.debounce = const Duration(milliseconds: 500)});

  final ServiceKind kind;
  final int pageSize;
  final Duration debounce;

  static ListingBrowseController register(ServiceKind kind) =>
      Get.put(ListingBrowseController(kind), tag: kind.name);

  static ListingBrowseController of(ServiceKind kind) =>
      Get.isRegistered<ListingBrowseController>(tag: kind.name)
          ? Get.find<ListingBrowseController>(tag: kind.name)
          : register(kind);

  PeakApi get _api => Get.find<PeakApi>();

  final List<ListingCard> listings = [];
  List<CategoryOption> categories = const [];

  bool isLoading = false;
  bool isMoreLoading = false;
  bool isCategoryLoading = false;
  bool hasMore = false;

  /// Set when the last fresh load failed (shown instead of "Nothing found").
  String? errorMessage;

  /// Set when loading the next page failed (list stays visible).
  String? loadMoreError;

  /// Active filters (null = none).
  String? subCategory;
  String? search;

  int _page = 0;
  int _request = 0;
  Timer? _debounceTimer;

  /// Fresh load from page 1 with the given filters.
  Future<void> load({String? subCategory, String? search}) async {
    _debounceTimer?.cancel();
    final sub = _clean(subCategory), q = _clean(search);
    // Same filters with a list on screen: refresh quietly (no skeleton) and
    // swap the list when the new page arrives. New filters start empty.
    final quiet = _page > 0 && sub == this.subCategory && q == this.search;
    this.subCategory = sub;
    this.search = q;
    final request = ++_request;

    isLoading = !quiet;
    isMoreLoading = false;
    errorMessage = null;
    loadMoreError = null;
    if (!quiet) {
      listings.clear();
      _page = 0;
      hasMore = false;
    }
    final needCategories = kind.hasSubCategories && categories.isEmpty;
    if (needCategories) isCategoryLoading = true;
    update();

    final pageFuture = _api.listings.browse(
      kind,
      search: this.search,
      subCategory: this.subCategory,
      page: 1,
      limit: pageSize,
    );
    final catFuture = needCategories ? _api.listings.categories(kind) : null;

    final result = await pageFuture;
    if (request != _request) return; // a newer search/filter won
    if (result.isSuccess) {
      listings
        ..clear()
        ..addAll(result.data!.items);
      _page = 1;
      hasMore = result.data!.hasMore;
    } else if (!quiet) {
      errorMessage = result.errorMessage;
    }
    isLoading = false;
    update();

    if (catFuture != null) {
      final cats = await catFuture;
      if (cats.isSuccess) categories = cats.data!;
      isCategoryLoading = false;
      update();
    }
  }

  /// Next page with the current filters.
  Future<void> loadMore() async {
    if (isLoading || isMoreLoading || !hasMore) return;
    final request = _request;
    isMoreLoading = true;
    loadMoreError = null;
    update();

    final result = await _api.listings.browse(
      kind,
      search: search,
      subCategory: subCategory,
      page: _page + 1,
      limit: pageSize,
    );
    if (request != _request) return;
    if (result.isSuccess) {
      final known = listings.map((l) => l.id).toSet();
      listings.addAll(result.data!.items.where((l) => !known.contains(l.id)));
      _page += 1;
      hasMore = result.data!.hasMore && result.data!.items.isNotEmpty;
    } else {
      loadMoreError = result.errorMessage;
    }
    isMoreLoading = false;
    update();
  }

  /// Debounced search, keeping the sub-category filter.
  void searchDebounced(String query, {String? subCategory}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => load(subCategory: subCategory, search: query));
  }

  static String? _clean(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
