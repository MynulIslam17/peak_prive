import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/provider_info.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/transport_details_shimmer.dart';
import 'package:harry_service_app/app/modules/user/massage/views/review_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/controllers/restaurant_details_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../routes/app_routes.dart';

class RestaurantDetails extends StatefulWidget {
  const RestaurantDetails({super.key});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  final PanelController panelController = PanelController();
  final image = Assets.images;
  final icon = Assets.icons;
  int currentTabIndex = 0; // For About/Review navigation
  int currentMealTabIndex = 0; // For Breakfast/Lunch/Dinner navigation

  late final String productId;

  /// find controlller
  final restaurantDetailsController = Get.find<RestaurantDetailsController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// get data from perevious class
    var argument = Get.arguments;
    productId = argument["id"];

    if (productId.isNotEmpty) {
      _fetchDetails();
    }
  }

  /// fetch details method

  Future<void> _fetchDetails() async {
    await restaurantDetailsController.fetchRestaurantDetails(productId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        minHeight: size.height * 0.43,
        maxHeight: size.height * 0.9,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        parallaxEnabled: true,
        parallaxOffset: 0.2,
        body: Column(
          children: [
            Image.asset(
              "assets/images/restu1.jpg",
              width: double.infinity,
              height: size.height * 0.6,
              fit: BoxFit.cover,
            ),
          ],
        ),
        panelBuilder: (ScrollController controller) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ListView(
              controller: controller,
              children: [
                // Drag Handle

                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (panelController.isPanelOpen) {
                          panelController.close();
                        } else {
                          panelController.open();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 60,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

                /// provider part
                ProviderInfo(onTapCall: () {}, onTapMessage: () {}),

                SizedBox(height: 20),

                // Custom Buttons for Navigation (About / Review)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 0;
                        });
                      },
                      text: "About",
                      backgroundColor: currentTabIndex == 0
                          ? AppColors.primary_1
                          : Colors.grey,
                    ),

                    SizedBox(width: 7.w),

                    CustomButton(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 1;
                        });
                      },
                      text: "Review",
                      backgroundColor: currentTabIndex == 1
                          ? AppColors.primary_1
                          : Colors.grey,
                    ),
                  ],
                ),

                if (currentTabIndex == 0) ...[
                  SizedBox(height: 25),
                  _buildAboutSection(),
                ] else ...[
                  SizedBox(height: 25),
                  _buildReviewSection(),
                ],
              ],
            ),
          );
        },
      ),

      // GetBuilder<RestaurantDetailsController>(builder: (controller){
      //
      //   if(controller.fetchProgress){
      //     return RestaurantDetailsShimmer();
      //   }
      //
      //   if(controller.restaurantDetails == null){
      //     return Center(child: Text(
      //       "Massage details not available",
      //       style: AppTextStyle.sub_h3_regular_14(),
      //     ),);
      //   }else{
      //
      //     final restaurantModel=controller.restaurantDetails;
      //     final owner=controller.restaurantDetails!.owner;
      //
      //    return  SizedBox(
      //       width: size.width,
      //       height: size.height,
      //       child: Stack(
      //         children: [
      //           // Background image
      //             Image.network(
      //                restaurantModel.thumbnail,
      //               height: size.height * 0.6,
      //
      //               fit: BoxFit.cover
      //           ),
      //
      //           // Draggable Bottom Sheet
      //           DraggableScrollableSheet(
      //             initialChildSize: 0.6,
      //             minChildSize: 0.56,
      //             maxChildSize: 0.7,
      //             snap: true,
      //             snapSizes: const [0.56, 0.6, 0.7],
      //             builder: (context, scrollController) {
      //               return Container(
      //                 decoration: BoxDecoration(
      //                   color: const Color(0xffFDFAF6),
      //                   borderRadius: const BorderRadius.only(
      //                     topLeft: Radius.circular(40),
      //                     topRight: Radius.circular(40),
      //                   ),
      //                   boxShadow: [
      //                     BoxShadow(
      //                       color: Colors.black.withOpacity(0.1),
      //                       blurRadius: 10,
      //                       offset: const Offset(0, -3),
      //                     ),
      //                   ],
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     // Drag Handle
      //                     Padding(
      //                       padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      //                       child: Center(
      //                         child: image.line.image(
      //                           width: 87.w,
      //                           height: 9.h,
      //                           fit: BoxFit.contain,
      //                         ),
      //                       ),
      //                     ),
      //
      //                     // Provider Info
      //                     Card(
      //                       child: SizedBox(
      //                         height: 70.h,
      //                         width: double.infinity,
      //                         child: ProviderInfo(
      //
      //                           onTapCall: () {},
      //                           onTapMessage: () {},
      //                         ),
      //                       ),
      //                     ),
      //
      //                     Expanded(
      //                       child: ListView(
      //                         controller: scrollController,
      //                         padding: EdgeInsets
      //                             .zero, // Remove default ListView padding
      //                         children: [
      //                           Padding(
      //                             padding: const EdgeInsets.symmetric(
      //                               horizontal: 20,
      //                             ),
      //                             child: Column(
      //                               children: [
      //                                 SizedBox(height: 10.h),
      //
      //                                 // Custom Buttons for Navigation (About / Review)
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                   MainAxisAlignment.spaceBetween,
      //                                   children: [
      //                                     CustomButton(
      //                                       onTap: () {
      //                                         setState(() {
      //                                           currentTabIndex = 0;
      //                                         });
      //                                       },
      //                                       text: "About",
      //                                       backgroundColor: currentTabIndex == 0
      //                                           ? AppColors.primary_1
      //                                           : Colors.grey,
      //                                     ),
      //
      //
      //                                     SizedBox(width: 7.w,),
      //
      //                                     CustomButton(
      //                                       onTap: () {
      //                                         setState(() {
      //                                           currentTabIndex = 1;
      //                                         });
      //                                       },
      //                                       text: "Review",
      //                                       backgroundColor: currentTabIndex == 1
      //                                           ? AppColors.primary_1
      //                                           : Colors.grey,
      //                                     ),
      //                                   ],
      //                                 ),
      //
      //                                 SizedBox(height: 10.h),
      //
      //                                 // About / Review Content
      //                                 if (currentTabIndex == 0) ...[
      //                                   _buildAboutSection(),
      //                                 ] else if (currentTabIndex == 1) ...[
      //                                   _buildReviewSection(),
      //                                 ],
      //
      //                                 // Meal Type Navigation (Only for "About" section)
      //                                 if (currentTabIndex == 0) ...[
      //                                   SizedBox(height: 20.h),
      //                                   Row(
      //                                     mainAxisAlignment:
      //                                     MainAxisAlignment.spaceBetween,
      //                                     children: [
      //                                       CustomButton(
      //                                         onTap: () {
      //                                           setState(() {
      //                                             currentMealTabIndex = 0;
      //                                           });
      //                                         },
      //                                         text: "Breakfast",
      //                                         backgroundColor:
      //                                         currentMealTabIndex == 0
      //                                             ? AppColors.primary_1
      //                                             : Colors.grey,
      //                                       ),
      //
      //                                       SizedBox(width: 5.w,),
      //                                       CustomButton(
      //                                         onTap: () {
      //                                           setState(() {
      //                                             currentMealTabIndex = 1;
      //                                           });
      //                                         },
      //                                         text: "Lunch",
      //                                         backgroundColor:
      //                                         currentMealTabIndex == 1
      //                                             ? AppColors.primary_1
      //                                             : Colors.grey,
      //                                       ),
      //
      //                                       SizedBox(width: 5.w,),
      //                                       CustomButton(
      //                                         onTap: () {
      //                                           setState(() {
      //                                             currentMealTabIndex = 2;
      //                                           });
      //                                         },
      //                                         text: "Dinner",
      //                                         backgroundColor:
      //                                         currentMealTabIndex == 2
      //                                             ? AppColors.primary_1
      //                                             : Colors.grey,
      //                                       ),
      //
      //                                     ],
      //                                   ),
      //                                   SizedBox(height: 10.h),
      //
      //                                   // Meal Type Content (Only for "About" section)
      //                                   if (currentMealTabIndex == 0)
      //                                     _buildMenuList("Breakfast")
      //                                   else if (currentMealTabIndex == 1)
      //                                     _buildMenuList("Lunch")
      //                                   else if (currentMealTabIndex == 2)
      //                                       _buildMenuList("Dinner"),
      //                                 ],
      //
      //                                 SizedBox(
      //                                   height: 20.h,
      //                                 ),
      //
      //
      //
      //                               ],
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               );
      //             },
      //           ),
      //
      //           // Back Button
      //           CustomBackButton(onTap: () => Get.back()),
      //         ],
      //       ),
      //     );
      //
      //
      //   }
      //
      //
      //
      //
      //
      // })
    );
  }

  // About Section Content
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Foxtonn Restaurant", style: AppTextStyle.sub_h2_medium_16()),
            Text(
              "Thai Food",
              style: AppTextStyle.c_regular_10(color: AppColors.primary_1),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Open 10 am", style: AppTextStyle.c_regular_10()),
            SizedBox(width: 10.h),
            const CircleAvatar(backgroundColor: Colors.grey, radius: 5),
            SizedBox(width: 10.h),
            Text("Open 10 am", style: AppTextStyle.c_regular_10()),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon.loacation.svg(),
            SizedBox(width: 4.w),
            Text(
              "34 akhicnbanns Street, Off Ihama Road",
              style: AppTextStyle.c_regular_10(color: AppColors.primary_1),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Our Seat 20", style: AppTextStyle.c_regular_10()),
            SizedBox(width: 4.w),
            const CircleAvatar(radius: 6, backgroundColor: Colors.grey),
            SizedBox(width: 4.w),

          ],
        ),

        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Available Seat", style: AppTextStyle.sub_h2_medium_16()),


            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => print("See All tapped"),
                splashColor: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "See All",
                    style: AppTextStyle.sub_h3_medium_14(
                      color: AppColors.primary_1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10,),

        /// seating card list
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return buildSeatingCard(
              onTap: () {

                Get.toNamed(Routes.restaurantInfo);

              },
              imageUrl: 'path/to/your/image.png',
              seatingType: 'VIP',
              totalSeats: 20,
              availableSeats: 5,
              pricePerSeat: 5.0,
            );
          },
        ),
      ],
    );
  }

  /// Review Section Content (currently empty)
  Widget _buildReviewSection() {
    return ReviewScreen();
  }

  /// seating card

  Widget buildSeatingCard({
    required String imageUrl,
    required String seatingType,
    required int totalSeats,
    required int availableSeats,
    required double pricePerSeat,
    required VoidCallback onTap,
  }) {
    const Color vipColor = Color(0xFFD4AF37);
    const Color availableColor = Colors.red;
    const Color textColor = Colors.black;

    // Define the dimensions
    const double imageSize = 80.0;
    const double cardPadding = 12.0;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          padding: const EdgeInsets.all(cardPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// --- 1. Image ---
              Container(
                width: imageSize,
                height: imageSize,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),

                  child: Container(
                    color: Colors.grey[300],
                    child: Image.asset(
                      "assets/images/restu1.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16.0), // Spacing

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Row for Type and Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          seatingType,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: vipColor,
                          ),
                        ),

                        /// Total Text
                        Text(
                          'Total: $totalSeats',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4.0),

                    // /Available Seats Text
                    Text(
                      'Available seat $availableSeats',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: availableColor,
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    ///Row for Price label and Price value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // Price Label
                        const Text(
                          'Price',
                          style: TextStyle(fontSize: 14.0, color: textColor),
                        ),
                        // Price Value
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'Roboto'),
                            children: [
                              TextSpan(
                                text: '\$${pricePerSeat.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: vipColor,
                                ),
                              ),
                              const TextSpan(
                                text: '/per seat',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color backgroundColor;
  final double? height;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          minimumSize: Size(double.infinity, height ?? 44.h),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    );
  }
}
