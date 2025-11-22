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
import '../../../../../gen/assets.gen.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/all_pass_controller.dart';
import '../controllers/ski_hire_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final icons = Assets.icons;

  final auth = Get.find<AuthController>();
  final pass = Get.find<AllPassController>();
  final hire = Get.find<SkiHireController>();
  final nav = Get.find<NavController>();

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if (nav.getServiceType == "ski_pass") {
      pass.fetchAllPass();
    } else {
      /// fetch data with category
      hire.fetchAllSkiHireAndCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    String type = nav.getServiceType;

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary_1,
        child: Image.asset("assets/icons/fav.png"),
        onPressed: () {
          Get.offAllNamed(Routes.service);
        },
      ),

      /// MAIN BUILDER (REBUILDS on both controllers)
      body: GetBuilder<AllPassController>(
        builder: (_) {
          return GetBuilder<SkiHireController>(

            builder: (_) {

              ///  ONE COMBINED LOADING FLAG
              bool isLoading = type == "ski_pass"
                  ? pass.fetchProgress
                  : hire.isLoading;

              ///  FULL-SCREEN LOADER WHEN FETCHING
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              ///  FULL UI AFTER DATA ARRIVES
              return ListView(
                children: [
                  /// HEADER
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
                    decoration:
                    BoxDecoration(gradient: AppColors.appBarBackground),
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

                  /// CATEGORY (Only for Ski Hire/transport/message)
                  if (type != "ski_pass")
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategoryTitle(
                            title: "Category",
                            text: "See All",
                            onClick: () {},
                          ),
                          SizedBox(height: 10.h),


                         /// when click on category item

                         CategoryList(
                           categoryList: hire.categoryList,

                           onTap: (categoryName){

                         print("=>>>>>>>>>>>>>>>>>>>>>>>>${categoryName}");

                         hire.fetchAllSkiHireAndCategory(categoryName);


                         },

                         )




                        ],
                      ),
                    ),




                  SizedBox(height: 10.h),

                  /// LIST SECTION
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryTitle(
                          title: type == "ski_pass"
                              ? "Top Ski Pass"
                              : "Top Ski Hire",
                          text: "See All",
                          onClick: () {},
                        ),

                        SizedBox(height: 10.h),

                        /// SKI PASS LIST
                        if (type == "ski_pass")
                          Column(
                            children: pass.skiPassList.map((item) {
                              return Padding(
                                padding:
                                EdgeInsets.symmetric(vertical: 7.h),
                                child: ItemCard(
                                  image: item.thumbnail ?? "",
                                  title: item.title ?? "",
                                  price:
                                  "\$${item.amount?.toStringAsFixed(2) ?? "0"}",
                                  rating: item.averageRating ?? 0.0,
                                  reviewCount: "${item.reviews.length}",
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
                          Column(
                            children: hire.skiHireList.map((item) {
                              return Padding(
                                padding:
                                EdgeInsets.symmetric(vertical: 7.h),
                                child: ItemCard(
                                  image: item.thumbnail ?? "",
                                  title: item.title ?? "",
                                  price:
                                  "\$${item.totalPrice?.toStringAsFixed(2) ?? "0"}",
                                  rating: item.averageRating ?? 0.0,
                                  reviewCount: "${item.reviews.length}",
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
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
