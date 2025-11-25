import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/message_details_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/pass_details_skeleton.dart';
import 'package:harry_service_app/app/modules/user/massage/controllers/message_details_controller.dart';
import 'package:harry_service_app/app/modules/user/massage/views/review_screen.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/appText.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../core/widgets/ratingbar.dart';
import '../../../../routes/app_routes.dart';

class MassageDetailsScreen extends StatefulWidget {
  const MassageDetailsScreen({super.key});

  @override
  State<MassageDetailsScreen> createState() => _MassageDetailsScreenState();
}

class _MassageDetailsScreenState extends State<MassageDetailsScreen>
    with SingleTickerProviderStateMixin {

  ///  product id
   late final String productId;
  final image = Assets.images;
  final icons = Assets.icons;

  late TabController tabController;

  /// find
  final massageController=Get.find<MassageDetailsController>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    var argument=Get.arguments;

    productId=argument["id"];


    if(productId.isNotEmpty){
      _fetchDetails();
    }


  }



  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }





  /// fetch details api calling method
  Future<void>_fetchDetails()async{
    await massageController.fetchMassageDetails(productId);


  }





  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: GetBuilder<MassageDetailsController>(builder: (controller){

        if(controller.isLoading){
          return MassageDetailsShimmer();
        }

        // Null check for hireDetails
        if (controller.massage == null) {
          return Center(
            child: Text(
              "Massage details not available",
              style: AppTextStyle.sub_h3_regular_14(),
            ),
          );
        }

        else{

              final massage =controller.massage!;
              final owner =controller.massage!.owner;

          return  SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // Background image

                Image.network(
                  massage.thumbnail,
                  height: size.height * 0.48,
                  fit: BoxFit.cover,

                ),




                // Overlap card
                Positioned(
                  top: size.height * 0.33,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xffFDFAF6),
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
                          // Line indicator
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: image.line.image(width: 87.w, height: 9.h),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Profile info
                          ProviderInfo(
                            providerName: owner.fullName,
                            rating: massage.averageRating.toString(),
                            reviewCount: massage.reviews.length,
                            image: owner.profileUrl,
                            onTapCall: () {},
                            onTapMessage: () {},
                          ),
                          SizedBox(height: 20.h),

                          // Tab bar
                          TabBar(
                            controller: tabController,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            labelStyle: AppTextStyle.sub_h3_medium_14(),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                                color: Color(0xffD4AF38),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            tabs: const [
                              Tab(text: "About"),
                              Tab(text: "Review"),
                            ],
                          ),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                // About Tab
                                ListView(
                                  padding: EdgeInsets.all(0),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: _buildAboutContent(),
                                    ),
                                  ],
                                ),
                                // Review Tab
                                ListView(
                                  padding: EdgeInsets.all(20),
                                  children: [
                                    ReviewScreen()
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Footer (Price + Button)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10.h,
                              bottom: 20.h,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    "\$ ${controller.massage!.amount}",
                                    style: AppTextStyle.sub_h3_medium_14(
                                      color: AppColors.primary_1,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30.w),



                                Expanded(
                                  child: CustomButton(
                                    onTap: () {
                                      Get.toNamed(Routes.bookingRequest,

                                      arguments: {
                                       "priceByDuration" : massage.priceByDuration,
                                        "id" : productId
                                      }
                                      );
                                    },
                                    text: "Book Now",
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

                // Back button
                CustomBackButton(
                  onTap: () {
                    Get.back();
                  },
                ),
              ],
            ),
          );
        }

      })
    );
  }

  // About tab content
  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// pricing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(massageController.massage!.title, style: AppTextStyle.h2_semibold_22(),softWrap: true,maxLines: 2,overflow: TextOverflow.ellipsis,)),
            Text("\$ ${massageController.massage!.amount}", style: AppTextStyle.sub_h2_medium_16(color:AppColors.primary_1)),
          ],
        ),
        SizedBox(height: 10.h,),

        /// open and close time
        Row(
          children: [

            Text("Open : ${massageController.massage!.openTime}",style: AppTextStyle.p_regular_12(color: AppColors.black_3),),
            SizedBox(width: 10.w,),
            CircleAvatar(radius: 5,backgroundColor: Colors.grey,),
            SizedBox(width: 10.w,),
            Text("Closed ${massageController.massage!.closeTime}",style: AppTextStyle.p_regular_12(color: AppColors.black_3),),



          ],
        ),

        SizedBox(height: 2.h,),

        ///location
        Row(
          children: [


            icons.mapPinSimpleArea.svg(width: 20,height: 20),
            SizedBox(width: 10.w,),
            Text("Location : ${massageController.massage!.serviceArea}",style:AppTextStyle.p_regular_12(color: AppColors.black_3) ,)
          ],
        ),



        SizedBox(height: 10.h),
        Text("Benefits", style: AppTextStyle.sub_h2_medium_16()),
        SizedBox(height: 10.h),
        Text(
          "${massageController.massage!.benefits}",
        ),
        SizedBox(height: 30.h),
        Text("Our recommendation", style: AppTextStyle.sub_h1_medium_18()),
        SizedBox(height: 10.h),
        Text(
          "${massageController.massage!.ourRecommendations}",
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  // Review tab content
  Widget _buildReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: AppTextStyle.sub_h1_medium_18()),
        SizedBox(height: 10.h),
        Text(
          "Review content will be displayed here. "
              "This is scrollable content for the review tab.",
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}









