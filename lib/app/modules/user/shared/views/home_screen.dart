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

  final icons=Assets.icons;


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
      await pass.fetchAllPass();
    } else if (nav.getServiceType == "ski_hire") {
      await hire.fetchAllSkiHire();
    }
  }

  @override
  Widget build(BuildContext context) {
    String type = nav.getServiceType;

    return Scaffold(


      /// fav button
      floatingActionButton: FloatingActionButton(

          backgroundColor: AppColors.primary_1,
           child: Image.asset("assets/icons/fav.png"),
          onPressed: (){

            Get.offAllNamed(Routes.service);

          }


      ),



      backgroundColor: Colors.white,
      body: ListView(
        children: [
          /// -------------------- HEADER --------------------
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(gradient: AppColors.appBarBackground),
            child: Column(
              children: [
                UserProfileSection(
                  name: auth.userModel!.fullName,
                  image: auth.userModel!.profilePic,
                  onTap: () {  },
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

          SizedBox(height: 20),

          /// CATEGORY ONLY FOR OTHER SERVICES
          if (type != "ski_pass")
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTitle(title: "Category", text: "See All", onClick: () {  },),
                  SizedBox(height: 10),
                  CategoryList(
                    titles: ["A", "B", "C"],
                    icons: [icons.honda,icons.bmw,icons.bmw,],
                    onTap: () {},
                  ),
                ],
              ),
            ),

          SizedBox(height: 10),

          /// -------------------- LIST SECTION --------------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTitle(
                  title: type == "ski_pass"
                      ? "Top Ski Pass"
                      : "Top Ski Hire",
                  text: "See All", onClick: () {  },
                ),

                SizedBox(height: 10),

                /// ---------------- PASS LIST ----------------
                if (type == "ski_pass")
                  GetBuilder<AllPassController>(
                    builder: (controller) {
                      if (controller.fetchProgress) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (controller.skiPassList.isEmpty) {
                        return Center(child: Text("No ski pass available"));
                      }

                      /// DIRECT LIST — NO EXTRA METHODS
                      return Column(
                        children: List.generate(controller.skiPassList.length, (i) {
                          final item =controller.skiPassList[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: ItemCard(
                              image: item.thumbnail,
                              title: item.title,
                              price: "\$${item.amount}",
                              rating: item.averageRating ?? 0.0,
                              reviewCount: "(${item.reviews.length})",
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
                        }),
                      );
                    },
                  ),

                /// ---------------- HIRE LIST ----------------
                if (type == "ski_hire")
                  GetBuilder<SkiHireController>(
                    builder: (controller) {
                      if (controller.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (controller.skiHireList.isEmpty) {
                        return Center(child: Text("No ski hire available"));
                      }

                      return Column(
                        children: List.generate(controller.skiHireList.length, (i) {
                          final item = controller.skiHireList[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: ItemCard(
                              image: item.thumbnail,
                              title: item.title,
                              price: "\$${item.totalPrice}",
                              rating: item.averageRating,
                              reviewCount: "(${item.reviews.length})",
                              location: item.serviceArea,
                              fromSkiPasses: false,
                              skiPassType: "",
                              onTap: () {

                                Get.toNamed(
                                  Routes.hireDetails,

                                );

                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
