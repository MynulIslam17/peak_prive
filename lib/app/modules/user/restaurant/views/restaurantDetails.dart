import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
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

  final authController=Get.find<AuthController>();
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
      body: GetBuilder<RestaurantDetailsController>(
        builder: (controller) {
          if (controller.fetchProgress) {
            return RestaurantDetailsShimmer();
          }
          if (controller.restaurantDetails == null) {
            return Center(child: Text("No Details available"));
          } else {
            final restaurantModel = controller.restaurantDetails;
            final owner = controller.restaurantDetails!.owner;

            return SlidingUpPanel(
              controller: panelController,
              minHeight: size.height * 0.48,
              maxHeight: size.height * 0.66,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              parallaxEnabled: true,
              parallaxOffset: 0.2,
              body: Stack(
                children: [
                  Image.network(
                    restaurantModel!.thumbnail ?? "",
                    width: double.infinity,
                    height: size.height * 0.6,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CustomBackButton(
                      onTap: () => Get.back(),
                    ),
                  ),
                ],
              ),
              panelBuilder: (ScrollController controller) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
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
                      ProviderInfo(
                        image: owner!.profileUrl,
                        providerName: owner.fullName ?? "",
                        onTapCall: () {},
                        onTapMessage: () {},
                      ),

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
            );
          }
        },
      ),
    );
  }

  ///  About Section Content
  Widget _buildAboutSection() {




    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        Text(
          restaurantDetailsController.restaurantDetails!.title,
          style: AppTextStyle.sub_h2_medium_16(),
        ),

        SizedBox(height: 6.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(backgroundColor: Colors.red, radius: 5),
            SizedBox(width: 10.h),
            Text("Close ${restaurantDetailsController.restaurantDetails!.closeTime.toString()}", style: AppTextStyle.c_regular_10()),
            SizedBox(width: 10.h),
            const CircleAvatar(backgroundColor: Colors.red, radius: 5),
            SizedBox(width: 10.h),
            Text("Open ${restaurantDetailsController.restaurantDetails!.openTime.toString()}", style: AppTextStyle.c_regular_10()),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon.loacation.svg(color: Colors.red),
            SizedBox(width: 4.w),
            Text(
              restaurantDetailsController.restaurantDetails!.serviceArea ?? "",
              style: AppTextStyle.c_regular_10(color: AppColors.primary_1),
            ),
          ],
        ),

        SizedBox(height: 20),


        Text("Available Seat", style: AppTextStyle.sub_h2_medium_16()),


        SizedBox(height: 10),

        /// seating card list
        ListView.builder(

          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: restaurantDetailsController.restaurantDetails!.items.length,
          itemBuilder: (context, index) {
            final item=restaurantDetailsController.restaurantDetails!.items[index];

            return buildSeatingCard(
              onTap: () {

                Get.toNamed(Routes.restaurantInfo,
                arguments: {
                  "userId" :authController.userModel!.id,
                   "productId": productId,
                    "quantity" : item.totalQty,
                   "itemId" :item.id,
                   "availableQty" : item.availableQty,
                  "thumbnail" : item.photo,
                  "seatType" : item.seat,
                  "totalSeat" : item.totalQty,
                  "seatPrice" : item.price,

                  "availableSeat":item.availableQty,
                  "price"     : item.price,
                  "description" : item.description,
                  "availableSlots": restaurantDetailsController.restaurantDetails!.availableSlots,



                });
              },
              imageUrl: item.photo?? "",
              seatingType: item.seat ?? "",
              totalSeats: item.totalQty ,
              availableSeats: item.availableQty,
              pricePerSeat: item.price,
            );
          },
        ),
      ],
    );
  }

  /// Review Section Content (currently empty)
  Widget _buildReviewSection() {
    return ReviewScreen(reviewList: restaurantDetailsController!.restaurantDetails!.reviews,);
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
            children: [
              /// --- 1. Image ---
              Container(
                width: imageSize,
                height: imageSize,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),

                  child: Container(
                    color: Colors.grey[300],
                    child: Image.network(
                      imageUrl,
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
