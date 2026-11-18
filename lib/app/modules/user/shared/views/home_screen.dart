import 'package:harry_service_app/app/core/widgets/floating_nav_bar.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../routes/app_routes.dart';
import 'home/home_service_source.dart';
import 'home/widgets/home_category_bar.dart';
import 'home/widgets/home_header.dart';
import 'home/widgets/listing_card.dart';
import 'package:harry_service_app/app/core/widgets/draggable_orb_fab.dart';

/// User home: browse, search and filter listings for the selected service.
///
/// All per-service differences live in [HomeServiceSource], so this screen
/// only deals with layout and user interaction.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _maxContentWidth = 1100;
  static const double _loadMoreThreshold = 300;

  final _auth = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late final HomeServiceSource? _source = HomeServiceSource.forKey(Get.find<NavController>().getServiceType);

  /// `null` means "All".
  String? _selectedCategory;

  String? get _query {
    final text = _searchController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _source?.load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────── Actions ───────────────────────────────

  void _onScroll() {
    final source = _source;
    if (source == null || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final nearBottom = position.pixels >= position.maxScrollExtent - _loadMoreThreshold;
    if (nearBottom && source.hasMore && !source.isMoreLoading && !source.isLoading) {
      source.loadMore(category: _selectedCategory, search: _query);
    }
  }

  Future<void> _refresh() async => _source?.load(category: _selectedCategory, search: _query);

  void _onSearchChanged(String value) => _source?.search(value.trim(), category: _selectedCategory);

  void _onSearchCleared() {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    _source?.load(category: _selectedCategory);
  }

  void _onCategorySelected(String? category) {
    if (category == _selectedCategory) return;
    setState(() => _selectedCategory = category);
    _source?.load(category: category, search: _query);
  }

  void _openListing(HomeListing listing) {
    // Otherwise the search box takes focus again (keyboard up) on return.
    FocusManager.instance.primaryFocus?.unfocus();
    final route = _source?.detailsRoute;
    if (route == null || listing.id.isEmpty) return;
    Get.toNamed(route, arguments: {'id': listing.id});
  }

  void _switchService() => Get.offAllNamed(Routes.service);

  // ─────────────────────────────── Build ───────────────────────────────

  @override
  Widget build(BuildContext context) {
    final source = _source;

    return Scaffold(
      backgroundColor: Colors.white,
      // Quick way back to the service picker (ski pass, hire, transport…):
      // a floating orb that can be dragged anywhere or tucked into the side.
      body: DraggableOrbFab(
        semanticLabel: 'Switch service',
        onTap: _switchService,
        icon: Image.asset('assets/icons/fav.png', color: Colors.black87, width: 22, height: 22),
        // Above the floating nav bar, which the content scrolls under.
        bottomInset: FloatingNavBar.clearance,
        storageKey: 'home_switch_orb',
        hintText: 'Tap to switch service. Drag me anywhere, or to the side to hide.',
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = _horizontalPadding(constraints.maxWidth);
              return RefreshIndicator(
                color: AppColors.primary_1,
                // From the top of the screen, over the header.
                edgeOffset: 0,
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    HomeHeader(
                      userName: _auth.userModel?.fullName ?? 'there',
                      avatarUrl: _auth.userModel?.profilePic ?? '',
                      serviceLabel: source?.type.label ?? 'Choose a service',
                      searchController: _searchController,
                      searchHint: source == null ? 'Search...' : 'Search ${source.type.label.toLowerCase()}...',
                      onSearchChanged: _onSearchChanged,
                      onSearchCleared: _onSearchCleared,
                      onSwitchService: _switchService,
                      onNotifications: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Get.toNamed(Routes.notification);
                      },
                      horizontalPadding: padding,
                    ),
                    if (source == null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _StatusMessage(
                          icon: Icons.explore_outlined,
                          title: 'No service selected',
                          message: 'Pick a service to start browsing.',
                          actionLabel: 'Choose service',
                          onAction: _switchService,
                        ),
                      )
                    else
                      ..._buildFeed(source, padding),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeed(HomeServiceSource source, double padding) {
    return [
      if (source.supportsCategories)
        SliverToBoxAdapter(
          child: source.observe(
            (_) => _CategorySection(
              source: source,
              selected: _selectedCategory,
              onSelected: _onCategorySelected,
              horizontalPadding: padding,
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(padding, source.supportsCategories ? 24 : 8, padding, 14),
        sliver: SliverToBoxAdapter(child: _SectionHeader(title: source.type.listTitle)),
      ),
      source.observe((_) => _buildListings(source, padding)),
      SliverToBoxAdapter(
        child: source.observe(
          (_) => PaginationFooter(
            isMoreLoading: source.isMoreLoading,
            hasMore: source.hasMore,
            itemCount: source.listings.length,
            endMessage: "You're all caught up",
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom)),
    ];
  }

  Widget _buildListings(HomeServiceSource source, double padding) {
    if (source.isLoading) {
      return _ListingGrid(padding: padding, itemCount: 3, itemBuilder: (_, __) => const ListingCardSkeleton());
    }

    final listings = source.listings;
    if (listings.isEmpty) {
      final error = source.errorMessage;
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
          child: error != null
              ? _StatusMessage(
                  icon: Icons.wifi_off_rounded,
                  title: 'Something went wrong',
                  message: error,
                  actionLabel: 'Try again',
                  onAction: _refresh,
                )
              : _StatusMessage(
                  icon: Icons.search_off_rounded,
                  title: 'Nothing found',
                  message: _query != null || _selectedCategory != null
                      ? 'Try a different search or category.'
                      : 'No ${source.type.label.toLowerCase()} available yet.',
                ),
        ),
      );
    }

    return _ListingGrid(
      padding: padding,
      itemCount: listings.length,
      itemBuilder: (_, index) => ListingCard(listing: listings[index], onTap: () => _openListing(listings[index])),
    );
  }

  /// Side padding that keeps content centred and capped on wide screens.
  static double _horizontalPadding(double width) {
    final base = width >= 600 ? 24.0 : 16.0;
    return math.max(base, (width - _maxContentWidth) / 2);
  }
}

// ─────────────────────────────── Sections ───────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.source,
    required this.selected,
    required this.onSelected,
    required this.horizontalPadding,
  });

  final HomeServiceSource source;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (!source.isCategoryLoading && source.categories.isEmpty) {
      return const SizedBox.shrink();
    }
    // Pills sit right under the search bar; no extra heading needed.
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: HomeCategoryBar(
        categories: source.categories,
        selected: selected,
        onSelected: onSelected,
        isLoading: source.isCategoryLoading,
        horizontalPadding: horizontalPadding,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyle.sub_h1_medium_18(
        color: AppColors.textPrimary,
      ).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
    );
  }
}

/// One column on phones, two on tablets, three on wide screens.
class _ListingGrid extends StatelessWidget {
  const _ListingGrid({required this.padding, required this.itemCount, required this.itemBuilder});

  final double padding;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = width >= 900 ? 3 : (width >= 560 ? 2 : 1);

          if (columns == 1) {
            return SliverList.separated(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              separatorBuilder: (_, __) => const SizedBox(height: _spacing),
            );
          }

          // Fixed tile height = 16:9 image + text block (scaled with font size).
          final tileWidth = (width - _spacing * (columns - 1)) / columns;
          final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
          final tileHeight = tileWidth * 9 / 16 + 84 * textScale;

          return SliverGrid.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: _spacing,
              mainAxisSpacing: _spacing,
              mainAxisExtent: tileHeight,
            ),
          );
        },
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppColors.primary_1.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: AppColors.primary_1),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: AppTextStyle.sub_h1_medium_18()),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.sub_h3_regular_14(color: AppColors.textTertiary),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary_1,
                  side: const BorderSide(color: AppColors.primary_1),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
