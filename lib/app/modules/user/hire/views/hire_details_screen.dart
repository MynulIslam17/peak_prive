import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/appText.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/available_service.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../routes/app_routes.dart';

class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final icon = Assets.icons;
  final image = Assets.images;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            /// background image part
            image.opening.image(
              height: size.height * 0.48,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            /// overlap card part==================
            Positioned(
              top: size.height * 0.4,
              left: 0,
              right: 0,
              child: Container(
                width: size.width,
                height:
                    size.height *
                    0.6, // Adjusted height to make space for bottom row if needed
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      /// line image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: image.line.image(width: 87.w, height: 9.h),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// provider info section ===================
                      ProviderInfo(onTapCall: () {}, onTapMessage: () {}),

                      ///tab
                      TabBar(
                        controller: tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                        labelStyle: AppTextStyle.sub_h3_medium_14(),
                        indicator: BoxDecoration(color: Color(0xffd6c24d)),

                        tabs: [
                          Tab(text: "About"),
                          Tab(text: "Review"),
                        ],
                      ),



                      TabBarView(
                        controller: tabController,
                          children: [

                           Center(child: Text("af"),),
                           Center(child: Text("af"),),


                      ]),










                      Spacer(),

                      /// Fixed bottom row (Price and Button)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.h,
                          bottom: 20.h,
                        ), // Add vertical padding for the bottom row
                        child: Row(
                          children: [
                            Text(
                              "\$9.99",
                              style: AppTextStyle.sub_h1_medium_18(
                                color: AppColors.primary_1,
                              ),
                            ),
                            SizedBox(width: 30.w),
                            Expanded(
                              child: CustomButton(
                                height: 44,
                                onTap: () {
                                  Get.toNamed(Routes.passInformation);
                                },
                                text: "Book Ski Pass",
                                backgroundColor: AppColors.primary_1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// app bar Back button
            CustomBackButton(
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
