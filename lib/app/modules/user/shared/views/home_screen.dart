import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/item_card.dart';
import 'package:harry_service_app/app/core/widgets/category_list.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/userProfileSection.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/all_restaurant_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/all_transport_controller.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/shimmer/home_shimmer.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/all_massage_controller.dart';
import '../controllers/all_pass_controller.dart';
import '../controllers/all_ski_hire_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Controllers ──
  final auth       = Get.find<AuthController>();
  final pass       = Get.find<AllPassController>();
  final hire       = Get.find<SkiHireController>();
  final transport  = Get.find<TransportController>();
  final massage    = Get.find<MassageController>();
  final restaurant = Get.find<RestaurantController>();
  final nav        = Get.find<NavController>();

  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  String selectedCategory = "All";
  bool fullScreenLoading = true;

  // ── Getters ──
  String get serviceType => nav.getServiceType;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupScrollListener();
  }

  // ════════════════════════════════════════════════════
  // Scroll listener — pagination for ski_pass & ski_hire
  // Controller guards duplicate calls internally via
  // isLoading / isMoreLoading / hasMore checks
  // ════════════════════════════════════════════════════
  void _setupScrollListener() {
    scrollCtrl.addListener(() {
      final isNearBottom =
          scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent - 200;

      if (!isNearBottom) return;

      if (serviceType == "ski_pass") {
        pass.fetchAllPass(isLoadMore: true);
      } else if (serviceType == "ski_hire") {
        hire.fetchAllSkiHireAndCategory(
          category: selectedCategory == "All" ? null : selectedCategory,
          isLoadMore: true,
        );
      } else if (serviceType == "transport") {
        // TransportController has dedicated loadMoreTransport()
        // which handles _page++ and guard checks internally
        transport.loadMoreTransport();
      }else if (serviceType == "massage") {
        massage.loadMore();
      }else if(serviceType == "restaurant"){
        // TransportController has dedicated loadMoreTransport()
        // which handles _page++ and guard checks internally
        restaurant.loadMoreRestaurant();
      }
    });
  }

  // ════════════════════════════════════════════════════
  // Initial / category load
  // ════════════════════════════════════════════════════
  Future<void> _loadData({String? category}) async {
    final cat = (category == null || category == "All") ? null : category;

    if (serviceType == "ski_pass") {
      await pass.fetchAllPass();
    } else if (serviceType == "ski_hire") {
      await hire.fetchAllSkiHireAndCategory(category: cat);
    } else if (serviceType == "transport") {
      await transport.fetchAllTransportAndCategory(category: cat);
    } else if (serviceType == "massage") {
      await massage.fetchAllMassageAndCategory(category: cat);
    } else if (serviceType == "restaurant") {
      await restaurant.fetchAllRestaurantsAndCategory(category: cat);
    }

    if (mounted) setState(() => fullScreenLoading = false);
  }

  // ════════════════════════════════════════════════════
  // Search
  // ════════════════════════════════════════════════════
  void _onSearch(String value) {
    final cat = selectedCategory == "All" ? null : selectedCategory;
    switch (serviceType) {
      case "ski_pass":   pass.searchPass(value); break;
      case "massage":    massage.searchMassage(category: cat, search: value); break;
      case "ski_hire":   hire.searchSkiHire(category: cat, search: value); break;
      case "transport":  transport.searchTransport(category: cat, search: value); break;
      case "restaurant": restaurant.searchRestaurant(category: cat, search: value); break;
    }
  }

  // ════════════════════════════════════════════════════
  // Clear search
  // ════════════════════════════════════════════════════
  void _onClearSearch() {
    FocusScope.of(context).unfocus();
    searchCtrl.clear();
    _loadData(category: selectedCategory);
  }

  // ════════════════════════════════════════════════════
  // Category tap
  // ════════════════════════════════════════════════════
  void _onCategoryTap(String categoryName) {
    setState(() => selectedCategory = categoryName);
    _loadData(category: categoryName);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Full screen shimmer on very first load
    if (fullScreenLoading) {
      return _FullScreenShimmer(type: serviceType);
    }

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary_1,
        child: Image.asset("assets/icons/fav.png", color: Colors.black87),
        onPressed: () => Get.offAllNamed(Routes.service),
      ),
      body: RefreshIndicator(
        color: AppColors.primary_1,
        onRefresh: ()async{

          await _loadData(category: selectedCategory);
        },

        child: SafeArea(
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [

              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,       // Keeps the title (User Profile) visible
                floating: false,    // Search bar won't "pop" back in mid-scroll
                snap: false,        // Disables the snapping animation
                expandedHeight: 140.h,
                backgroundColor: Colors.white,
                elevation: 0,


                // This part stays visible at the top
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundImage: NetworkImage(auth.userModel?.profilePic ?? ""),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Hello, ${auth.userModel?.fullName ?? "User"}",
                          style: AppTextStyle.sub_h1_regular_18().copyWith(
                            fontSize: 16.sp,
                            color: Colors.black, // Ensure visibility against white appbar
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                    ),
                  ],
                ),

                // This part scrolls away and only reappears at the very top
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Padding(
                    // Top padding pushes the search bar below the pinned title area
                    padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 85.h),
                    child: Column(
                      children: [
                        CustomSearchBar(

                          controller: searchCtrl,
                          onChanged: _onSearch,
                          onClear: _onClearSearch,
                        ),
                      ],
                    ),
                  ),
                ),
              ),



              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── 2. Category section (not for ski_pass) ──
              if (serviceType != "ski_pass") ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: CategoryTitle(
                      title: serviceType == "transport" ? "Top Brand" : "Category",
                      text: "See All",
                      onClick: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildCategoryRow()),
              ],

              SliverToBoxAdapter(child: SizedBox(height: 10.h)),

              // ── 3. List title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: CategoryTitle(
                    title: _listTitle(),
                    text: "See All",
                    onClick: () {},
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 10.h)),

              // ── 4. Service list ──
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                sliver: _buildServiceList(),
              ),

              // ── 5. Pagination footer (ski_pass & ski_hire,all service) ──
              SliverToBoxAdapter(child: _buildPaginationFooter()),

              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(gradient: AppColors.appBarBackground),
      child: Column(
        children: [
          UserProfileSection(
            name: auth.userModel?.fullName ?? "User",
            image: auth.userModel?.profilePic ?? "",
            onTap: () {},
          ),
          SizedBox(height: 20.h),
          CustomSearchBar(
            elevation: 2,
            controller: searchCtrl,
            onChanged: _onSearch,
            onClear: _onClearSearch,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // CATEGORY ROW
  // ════════════════════════════════════════════════════
  Widget _buildCategoryRow() {
    final categoryList = serviceType == "ski_hire"
        ? hire.categoryList
        : serviceType == "transport"
        ? transport.categoryList
        : serviceType == "massage"
        ? massage.categoryList
        : restaurant.categoryList;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            // "All" button
            _AllCategoryButton(
              isSelected: selectedCategory == "All",
              onTap: () => _onCategoryTap("All"),
            ),
            SizedBox(width: 15.w),
            // Rest of categories
            CategoryList(
              categoryList: categoryList,
              selectedCategoryName: selectedCategory,
              onTap: _onCategoryTap,
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // SERVICE LIST — routes to correct sliver list
  // ════════════════════════════════════════════════════
  Widget _buildServiceList() {
    switch (serviceType) {
      case "ski_pass":   return _buildSkiPassList();
      case "ski_hire":   return _buildSkiHireList();
      case "transport":  return _buildTransportList();
      case "massage":    return _buildMassageList();
      case "restaurant": return _buildRestaurantList();
      default:           return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  // ════════════════════════════════════════════════════
  // PAGINATION FOOTER — ski_pass-hire-restaurant-transport-massage
  // ════════════════════════════════════════════════════
  Widget _buildPaginationFooter() {
    switch (serviceType) {

      case "ski_pass":
        return GetBuilder<AllPassController>(
          builder: (c) => PaginationFooter(
            isMoreLoading: c.isMoreLoading,
            hasMore: c.hasMore,
            itemCount: c.skiPassList.length,
            endMessage: "You've seen all ski passes",
          ),
        );

      case "ski_hire":
        return GetBuilder<SkiHireController>(
          builder: (c) => PaginationFooter(
            isMoreLoading: c.isMoreLoading,
            hasMore: c.hasMore,
            itemCount: c.skiHireList.length,
            endMessage: "You've seen all ski hire items",
          ),
        );

      case "transport":
        return GetBuilder<TransportController>(
          builder: (c) => PaginationFooter(
            isMoreLoading: c.isMoreLoading,
            hasMore: c.hasMore,
            itemCount: c.transportList.length,
            endMessage: "You've seen all transport services",
          ),
        );

      case "massage":
        return GetBuilder<MassageController>(
          builder: (c) => PaginationFooter(
            isMoreLoading: c.isMoreLoading,
            hasMore: c.hasMore,
            itemCount: c.massageList.length,
            endMessage: "You've seen all massage services",
          ),
        );

      case "restaurant":
        return GetBuilder<RestaurantController>(
          builder: (c) => PaginationFooter(
            isMoreLoading: c.isMoreLoading,
            hasMore: c.hasMore,
            itemCount: c.restaurantList.length,
            endMessage: "You've seen all restaurant items",
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ════════════════════════════════════════════════════
  // SKI PASS LIST
  // Uses: isLoading, isMoreLoading, skiPassList, errorMessage
  // ════════════════════════════════════════════════════
  Widget _buildSkiPassList() {
    return GetBuilder<AllPassController>(
      builder: (c) {
        // Initial loading shimmer
        if (c.isLoading) return _skeletonSliver();

        // Error state
        if (c.errorMessage != null && c.skiPassList.isEmpty) {
          return _emptySliver(c.errorMessage!);
        }

        // Empty state
        if (c.skiPassList.isEmpty) {
          return _emptySliver("No ski pass services found");
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = c.skiPassList[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: ItemCard(
                  image: item.thumbnail ?? "",
                  title: item.title ?? "",
                  price: "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                  rating: item.averageRating ?? 0.0,
                  reviewCount: "${item.reviews.length}",
                  location: item.serviceArea ?? "",
                  fromSkiPasses: true,
                  skiPassType: item.skiPassType ?? "",
                  onTap: () => Get.toNamed(
                    Routes.passCardDetails,
                    arguments: {"id": item.id},
                  ),
                ),
              );
            },
            childCount: c.skiPassList.length,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  // SKI HIRE LIST
  // ════════════════════════════════════════════════════
  Widget _buildSkiHireList() {
    return GetBuilder<SkiHireController>(
      builder: (c) {
        if (c.isLoading) return _skeletonSliver();
        if (c.skiHireList.isEmpty) return _emptySliver("No ski hire services found");

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = c.skiHireList[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: ItemCard(
                  image: item.thumbnail ?? "",
                  title: item.title ?? "",
                  price: "\$${item.totalPrice?.toStringAsFixed(2) ?? "0"}",
                  rating: item.averageRating ?? 0.0,
                  reviewCount: "${item.reviews.length}",
                  location: item.serviceArea ?? "",
                  fromSkiPasses: false,
                  skiPassType: "",
                  onTap: () => Get.toNamed(
                    Routes.hireDetails,
                    arguments: {"id": item.id},
                  ),
                ),
              );
            },
            childCount: c.skiHireList.length,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  // TRANSPORT LIST
  // ════════════════════════════════════════════════════
  Widget _buildTransportList() {
    return GetBuilder<TransportController>(
      builder: (c) {
        if (c.isLoading) return _skeletonSliver();
        if (c.transportList.isEmpty) return _emptySliver("No transport services found");

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = c.transportList[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: ItemCard(
                  image: item.thumbnail ?? "",
                  title: item.title ?? "",
                  price: "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                  rating: item.averageRating ?? 0.0,
                  reviewCount: "${item.reviews.length}",
                  location: item.serviceArea ?? "",
                  fromSkiPasses: false,
                  skiPassType: "",
                  onTap: () => Get.toNamed(
                    Routes.transportDetails,
                    arguments: {"id": item.id},
                  ),
                ),
              );
            },
            childCount: c.transportList.length,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  // MASSAGE LIST
  // ════════════════════════════════════════════════════
  Widget _buildMassageList() {
    return GetBuilder<MassageController>(
      builder: (c) {
        if (c.isLoading) return _skeletonSliver();
        if (c.massageList.isEmpty) return _emptySliver("No massage services found");

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = c.massageList[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: ItemCard(
                  image: item.thumbnail ?? "",
                  title: item.title ?? "",
                  price: "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                  rating: item.averageRating.toDouble(),
                  reviewCount: "${item.reviews.length}",
                  location: item.serviceArea ?? "",
                  fromSkiPasses: false,
                  skiPassType: "",
                  onTap: () => Get.toNamed(
                    Routes.massageDetails,
                    arguments: {"id": item.id},
                  ),
                ),
              );
            },
            childCount: c.massageList.length,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  // RESTAURANT LIST
  // ════════════════════════════════════════════════════
  Widget _buildRestaurantList() {
    return GetBuilder<RestaurantController>(
      builder: (c) {
        if (c.isLoading) return _skeletonSliver();
        if (c.restaurantList.isEmpty) return _emptySliver("No restaurant services found");

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = c.restaurantList[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: ItemCard(
                  image: item.thumbnail ?? "",
                  title: item.title ?? "",
                  price: "",
                  rating: item.averageRating?.toDouble() ?? 0,
                  reviewCount: "${item.reviews?.length ?? 0}",
                  location: item.serviceArea ?? "",
                  fromSkiPasses: false,
                  skiPassType: "",
                  onTap: () => Get.toNamed(
                    Routes.restaurantDetails,
                    arguments: {"id": item.id},
                  ),
                ),
              );
            },
            childCount: c.restaurantList.length,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════
  String _listTitle() {
    switch (serviceType) {
      case "ski_pass":   return "Top Ski Pass";
      case "ski_hire":   return "Top Ski Hire";
      case "transport":  return "Top Car in Town";
      case "restaurant": return "Restaurant";
      default:           return "Top Massage's Provider";
    }
  }

  Widget _skeletonSliver() => SliverList(
    delegate: SliverChildListDelegate([
      const ItemCardSkeleton(),
      const ItemCardSkeleton(),
    ]),
  );

  Widget _emptySliver(String message) => SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Text(message, style: AppTextStyle.sub_h1_regular_18()),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// "ALL" CATEGORY BUTTON — extracted widget
// ══════════════════════════════════════════════════════════════
class _AllCategoryButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AllCategoryButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: onTap,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary_1 : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.black54,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: Image.asset(
                "assets/images/all_icon.png",
                color: Colors.black87,
                width: 30,
                height: 30,
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "All",
          style: AppTextStyle.p_medium_12()?.copyWith(
            color: isSelected ? AppColors.primary_1 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FULL SCREEN SHIMMER
// ══════════════════════════════════════════════════════════════
class _FullScreenShimmer extends StatelessWidget {
  final String type;
  const _FullScreenShimmer({required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      children: [
        const HeaderSkeleton(),
        SizedBox(height: 20.h),
        if (type != "ski_pass") ...[
          const CategoryTitleSkeleton(),
          const CategorySkeleton(),
          SizedBox(height: 20.h),
        ],
        const CategoryTitleSkeleton(),
        const ItemCardSkeleton(),
        const ItemCardSkeleton(),
      ],
    );
  }
}