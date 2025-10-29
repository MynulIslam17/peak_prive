import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/appText.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';


import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/available_service.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../routes/app_routes.dart';



class PassDetailsScreen extends StatefulWidget {
  const PassDetailsScreen({super.key});

  @override
  State<PassDetailsScreen> createState() => _PassDetailsScreenState();
}

class _PassDetailsScreenState extends State<PassDetailsScreen> {
  final image = Assets.images;
  final icons = Assets.icons;


  ///dummy list for p type

  List<String> passTypeList=["VIP","Semi-VIP","Gold","Student"];


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            image.skiDetails.image(
              height: size.height * 0.48,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            /// overlap card
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

                      /// The scrollable section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            /// main card item content that needs to scroll
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align to left for content
                            children: [
                              /// profile section
                              ProviderInfo(
                                onTapCall: () {},
                                onTapMessage: () {},
                              ),

                              SizedBox(height: 20.h),

                              Column(
                                children: [
                                  Row(
                                    /// available service
                                    children: [

                                      /// service 1
                                      Expanded(
                                        child: AvailableService(
                                          serviceType: "Free Parking",
                                          serviceCount: "3 Car Parking",
                                        ),
                                      ),

                                    SizedBox(width: 5.w,),
                             /// service 2
                                      Expanded(
                                        child: AvailableService(
                                          serviceType: "Free Event",
                                          serviceCount: "2 free event",
                                        ),
                                      ),

                                      SizedBox(width: 5.w,),
                                 /// service 3
                                      Expanded(
                                        child: AvailableService(
                                          serviceType: "Free Ski Lession",
                                          serviceCount: "2 Free Lession",
                                        ),
                                      ),


                                    ],
                                  ),

                                  SizedBox(height: 14.h),
                                  Text(AppText.serviceDetails,style: AppTextStyle.p_regular_12().copyWith(color: AppColors.black_2)),

                                  /// service details text
                                ],
                              ),

                              //  content here that will also scroll
                              SizedBox(
                                height: 20.h,
                              ),
                            ],
                          ),
                        ),
                      ),

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
                                onTap: (){
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
            CustomBackButton(onTap: (){
              Get.back();
            },),






          ],
        ),
      ),
    );
  }


}


