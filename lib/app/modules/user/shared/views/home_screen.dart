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
import 'package:harry_service_app/app/modules/user/shared/controllers/all_transport_controller.dart';

import '../../../../core/constants/text-style.dart';
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
  final auth = Get.find<AuthController>();
  final pass = Get.find<AllPassController>();
  final hire = Get.find<SkiHireController>();
  final transport = Get.find<TransportController>();
  final massage = Get.find<MassageController>();
  final nav = Get.find<NavController>();

  final TextEditingController searchCtrl = TextEditingController();

  String selectedCategory = "All"; // Default selected category
  bool fullScreenLoading = true; // Full shimmer loader on first load

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if (nav.getServiceType == "ski_pass") {
      await pass.fetchAllPass();
    } else if (nav.getServiceType == "ski_hire") {
      await hire.fetchAllSkiHireAndCategory();
    } else if (nav.getServiceType == "transport") {
      await transport.fetchAllTransportAndCategory();
    } else if (nav.getServiceType == "massage") {
      await massage.fetchAllMassageAndCategory();
    } else if (nav.getServiceType == "restaurant") {
    } else {}

    setState(() {
      fullScreenLoading = false; // Hide full-screen shimmer after first load
    });
  }

  @override
  Widget build(BuildContext context) {
    String type = nav.getServiceType;

    /// make the category title
    String categoryTitle = type == "transport" ? "Top Brand " : "Category";

    /// skeleton full screen for loading home
    if (fullScreenLoading) {
      /// FULL-SCREEN SHIMMER ON FIRST LOAD
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
          Column(children: List.generate(2, (_) => const ItemCardSkeleton())),
        ],
      );
    }

    /// MAIN HOME UI AFTER FIRST LOAD
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary_1,
        child: Image.asset(
          "assets/icons/fav.png",
          color: Colors.black87,
        ),
        onPressed: () {
          Get.offAllNamed(Routes.service);
        },
      ),
      body: GetBuilder<AllPassController>(
        builder: (_) {
          return GetBuilder<SkiHireController>(
            builder: (_) {
              return GetBuilder<TransportController>(
                builder: (controller) {
                  return GetBuilder<MassageController>(
                    builder: (controller) {
                      return ListView(
                        children: [
                          /// HEADER
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 20.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.appBarBackground,
                            ),
                            child: Column(
                              children: [
                                UserProfileSection(
                                  name: auth.userModel?.fullName ?? "User",
                                  image: auth.userModel?.profilePic ?? "",
                                  onTap: () {},
                                ),
                                SizedBox(height: 20.h),
                                CustomSearchBar(
                                  controller: searchCtrl,
                                  onChanged: (v) => setState(() {}),
                                  onClear: () {
                                    searchCtrl.clear();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          /// CATEGORY SECTION
                          if (type != "ski_pass") ...[
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: CategoryTitle(
                                title: categoryTitle,
                                text: "See All",
                                onClick: () {},
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 12.w),
                                child: Row(
                                  children: [
                                    /// "All" Button
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          borderRadius:
                                          BorderRadius.circular(23),
                                          onTap: () async {
                                            setState(() {
                                              selectedCategory = "All";
                                            });

                                            loadData(); /// call method which will call api based on the serviceType
                                          },
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              color: selectedCategory == "All"
                                                  ? AppColors.primary_1
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                selectedCategory == "All"
                                                    ? Colors.orange
                                                    : Colors.black54,
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
                                          style: AppTextStyle.p_medium_12()
                                              ?.copyWith(
                                            color: selectedCategory == "All"
                                                ? AppColors.primary_1
                                                : Colors.black87,
                                            fontWeight:
                                            selectedCategory == "All"
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),

                                    SizedBox(width: 15.w),

                                    /// Category List
                                    CategoryList(
                                      categoryList: type == "ski_hire"
                                          ? hire.categoryList
                                          : type == "transport"
                                          ? transport.categoryList
                                          : massage.categoryList, // ADDED
                                      selectedCategoryName: selectedCategory,
                                      onTap: (categoryName) {
                                        setState(() {
                                          selectedCategory = categoryName;
                                        });

                                        if (type == "ski_hire") {
                                          hire.fetchAllSkiHireAndCategory(
                                              categoryName);
                                        } else if (type == "transport") {
                                          transport
                                              .fetchAllTransportAndCategory(
                                              categoryName);
                                        } else if (type == "massage") {
                                          massage.fetchAllMassageAndCategory(
                                              categoryName); // ADDED
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 10.h),

                          /// LIST SECTION
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// item list category
                                CategoryTitle(
                                  title: type == "ski_pass"
                                      ? "Top Ski Pass"
                                      : type=="ski_hire"
                                      ?"Top Ski Hire"
                                      :type=="transport"
                                      ? "Top Car in Town"
                                      : type=="restaurant"
                                      ?"Restaurant"
                                      : "Massage",
                                  text: "See All",
                                  onClick: () {},
                                ),
                                SizedBox(height: 10.h),

                                /// SKI PASS LIST
                                if (type == "ski_pass")
                                  pass.fetchProgress
                                      ? Center(child: CircularProgressIndicator())
                                      : Column(
                                    children: pass.skiPassList.map((item) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7.h,
                                        ),
                                        child: ItemCard(
                                          image: item.thumbnail ?? "",
                                          title: item.title ?? "",
                                          price:
                                          "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                                          rating: item.averageRating ?? 0.0,
                                          reviewCount:
                                          "${item.reviews.length}",
                                          location: item.serviceArea ?? "",
                                          fromSkiPasses: true,
                                          skiPassType: item.skiPassType ?? "",
                                          onTap: () {
                                            Get.toNamed(
                                              Routes.passCardDetails,
                                              arguments: {"id": item.id},
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                /// SKI HIRE LIST
                                if (type == "ski_hire")
                                  hire.isLoading
                                      ? Column(
                                    children: [
                                      ItemCardSkeleton(),
                                      ItemCardSkeleton(),
                                    ],
                                  )
                                      : Column(
                                    children: hire.skiHireList.map((item) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7.h,
                                        ),
                                        child: ItemCard(
                                          image: item.thumbnail ?? "",
                                          title: item.title ?? "",
                                          price:
                                          "\$${item.totalPrice?.toStringAsFixed(2) ?? "0"}",
                                          rating: item.averageRating ?? 0.0,
                                          reviewCount:
                                          "${item.reviews.length}",
                                          location: item.serviceArea ?? "",
                                          fromSkiPasses: false,
                                          skiPassType: "",
                                          onTap: () {
                                            Get.toNamed(
                                              Routes.hireDetails,
                                              arguments: {"id": item.id},
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                /// TRANSPORT
                                if (type == "transport")
                                  transport.isLoading
                                      ? Column(
                                    children: [
                                      ItemCardSkeleton(),
                                      ItemCardSkeleton(),
                                    ],
                                  )
                                      : Column(
                                    children: transport.transportList.map((item) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 7.h),
                                        child: ItemCard(
                                          image: item.thumbnail ?? "",
                                          title: item.title ?? "",
                                          price:
                                          "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                                          rating: item.averageRating ?? 0.0,
                                          reviewCount: "${item.reviews.length}",
                                          location: item.serviceArea ?? "",
                                          fromSkiPasses: false,
                                          skiPassType: "",
                                          onTap: () {
                                            Get.toNamed(
                                              Routes.transportDetails,
                                              arguments: {"id": item.id},
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                /// MASSAGE
                                if (type == "massage")
                                  massage.isLoading
                                      ? Column(
                                    children: [
                                      ItemCardSkeleton(),
                                      ItemCardSkeleton(),
                                    ],
                                  )
                                      : Column(
                                    children: massage.massageList.map((item) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 7.h),
                                        child: ItemCard(
                                          image: item.thumbnail ?? "",
                                          title: item.title ?? "",
                                          price:
                                          "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                                          rating: item.averageRating.toDouble() ?? 0,
                                          reviewCount: "${item.reviews.length}",
                                          location: item.serviceArea ?? "",
                                          fromSkiPasses: false,
                                          skiPassType: "",
                                          onTap: () {
                                            Get.toNamed(
                                              Routes.massageDetails,
                                              arguments: {"id": item.id},
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
