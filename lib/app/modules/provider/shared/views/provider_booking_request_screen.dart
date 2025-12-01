
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/provider_booking_card.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_booking_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_all_booking_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/widgets/dynamic_booking_card.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../data/models/booking_details_model.dart';
import '../../../../routes/app_routes.dart';
import '../models/restaurant_bookin_model.dart';
import '../models/ski_pass_booking_model.dart';

class ProviderBookingRequestScreen extends StatefulWidget {
   const ProviderBookingRequestScreen({super.key});

   @override
   State<ProviderBookingRequestScreen> createState() => _ProviderBookingRequestScreenState();
 }

 class _ProviderBookingRequestScreenState extends State<ProviderBookingRequestScreen> {


  final images=Assets.images;
  final icons=Assets.icons;



  /// finds controller

  final authController = Get.find<AuthController>();
  final  bookingController=Get.put(ProviderBookingController());


  @override
  void initState() {
    // TODO: implement initState
    bookingController.fetchProviderBookings();
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<ProviderBookingController>(builder: (controller){
        
          if(controller.isLoading){
            return BookingItemShimmer();
          }


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Provider Profile
                  ProviderProfile(
                    imageUrl: authController.userModel!.profilePic ?? '',
                    role: "${authController.userModel!.providerType ?? ""} Provider",
                    name: authController.userModel!.fullName ?? "",
                    onTap: () => Get.toNamed(Routes.providerProfileScreen),
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.red,
                      size: 30,
                    ),
                    onIconTap: () => print("Icon tapped!"),
                  ),
          
                  const SizedBox(height: 18),
          
                  /// All bookings title
                  Text("All Bookings", style: AppTextStyle.sub_h2_medium_16()),
                  const SizedBox(height: 15),
          
                  /// Booking list
                  GetBuilder<ProviderBookingController>(
                    builder: (controller) {

                      // Determine which list to use based on provider type
                      final isSkiPass = authController.userModel!.providerType == "SkiPass";
                      final isRestaurant = authController.userModel!.providerType == "Restaurant";

                      final bookings = isSkiPass
                          ? controller.bookingResultsList
                          : isRestaurant
                          ? controller.restaurantList
                          : controller.bookingResultsList; // fallback

                      if (bookings.isEmpty) {
                        return Center(
                          child: Text(controller.errorMessage ?? "No bookings found."),
                        );
                      }


                      if(isSkiPass){

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index]as Result;
                            final user = booking.user;
                            final product = booking.product;

                            if (product == null) return const SizedBox.shrink();

                            return ServiceInfoCard(
                              imageUrl: product.thumbnail ?? '',
                              title1: "Title",
                              value1: product.title ?? '',
                              icon1Path: "assets/icons/info.svg",
                              title2: "SkiPass Type",
                              value2:  product.skiPassType?? '-',
                              icon2Path: "assets/icons/badge.svg",
                              title3: "Total Amount",
                              value3: (booking.totalPrice ?? 0).toString(),
                              icon3Path: "assets/icons/amount.svg",
                              title4: "Location",
                              value4: user!.address?? '-',
                              icon4Path: "assets/icons/MapPinSimpleArea.svg",
                            );
                          },
                        );
                      }
                      else if (isRestaurant) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index] as RestaurantResult;
                            final user = booking.user;

                            final product = booking.product;

                            if (product == null) return const SizedBox.shrink();

                            return ServiceInfoCard(
                              imageUrl: product.thumbnail ?? '',
                              title1: "Title",
                              value1: product.title ?? '',
                              icon1Path: "assets/icons/info.svg",
                              title2: "Name",//"Seat Type",
                              value2: user!.fullName ?? '-',
                              icon2Path: "assets/icons/badge.svg",
                              title3: "Total Amount",
                              value3: (booking.totalPrice ?? 0).toString(),
                              icon3Path: "assets/icons/amount.svg",
                              title4: "Address",
                              value4:  user!.address ?? '-',
                              icon4Path: "assets/icons/MapPinSimpleArea.svg",
                            );
                          },
                        );
                      } else{
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.bookingResultsList.length,
                          itemBuilder: (context, index) {
                            final booking = controller.bookingResultsList[index];
                            final user = controller.bookingResultsList[index].user;
                            final product = booking.product;

                            if (product == null) return const SizedBox.shrink();

                            return ServiceInfoCard(
                              imageUrl: product.thumbnail ?? '',
                              title1: "Title",
                              value1: product.title ?? '',
                              icon1Path: "assets/icons/info.svg",
                              title2: "SkiPass Type",
                              value2:  product.skiPassType?? '-',
                              icon2Path: "assets/icons/badge.svg",
                              title3: "Total Amount",
                              value3: (booking.totalPrice ?? 0).toString(),
                              icon3Path: "assets/icons/amount.svg",
                              title4: "Location",
                              value4: user!.address?? '-',
                              icon4Path: "assets/icons/MapPinSimpleArea.svg",
                            );
                          },
                        );
                      }



                    },
                  )
          
                ],
              ),
            ),
          );
        
        }),
      )
    );
  }

 }
