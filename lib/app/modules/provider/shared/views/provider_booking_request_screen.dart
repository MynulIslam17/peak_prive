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
import 'package:harry_service_app/app/modules/provider/shared/controllers/all_booking_controller.dart';
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
  // final  bookingController=Get.put(ProviderBookingController());
  final  allBookingController=Get.put(BookingController());


  @override
  void initState() {
    // TODO: implement initState
    allBookingController.fetchBookings();
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GetBuilder<BookingController>(builder: (controller){

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
                    Text("All Bookings (${controller.bookings.length})", style: AppTextStyle.sub_h2_medium_16()),
                    const SizedBox(height: 15),

                    /// Booking list
                    GetBuilder<BookingController>(
                      builder: (controller) {

                        // Determine which list to use based on provider type
                        final isSkiPass = authController.userModel!.providerType == "Ski_Pass";
                        final isRestaurant = authController.userModel!.providerType == "Restaurant";
                        final isMassage = authController.userModel!.providerType == "Massage";

                        if (controller.bookings.isEmpty) {
                          return Center(
                            child: Text(controller.errorMessage ?? "No bookings found."),
                          );
                        }


                        if(isSkiPass){

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.bookings.length,
                            itemBuilder: (context, index) {

                              final result = controller.bookings[index];
                              final product = result.product;


                              if (product == null) {

                                return const SizedBox.shrink();
                              }

                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ?? "",
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/info.svg",
                                title2: "SkiPass Type",
                                value2:  product.skiPassType ?? 'N/A',
                                icon2Path: "assets/icons/badge.svg",
                                title3: "Total Amount",
                                value3: (result.totalPrice ?? 0).toString(),
                                icon3Path: "assets/icons/amount.svg",
                                title4: "Location",
                                value4: product.serviceArea ?? 'N/A',
                                icon4Path: "assets/icons/MapPinSimpleArea.svg",
                              );
                            },
                          );
                        }
                        else if (isRestaurant) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.bookings.length,
                            itemBuilder: (context, index) {
                              final result = controller.bookings[index];
                              final product = result.product;


                              if (product == null || result.bookingItems.isEmpty || result.slots.isEmpty) {

                                return const SizedBox.shrink();
                              }

                              final bookingItem = result.bookingItems[0];
                              final slot = result.slots[0];


                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ?? 'assets/images/default_restaurant.png',
                                title1: "Seat Type",
                                value1: bookingItem.itemDetails?.seat ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Seat Count",
                                value2: bookingItem.quantity?.toString() ?? '0',
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Slot",
                                // Null safety added for slot properties
                                value3: "${slot.startTime ?? 'N/A'}-${slot.endTime ?? 'N/A'}",
                                icon3Path: "assets/icons/time.svg",
                                title4: "Total Price",
                                value4: (result.totalPrice ?? 0).toString(),
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );
                            },
                          );
                        }
                        else if(isMassage){ // For Massage Provider
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.bookings.length,
                            itemBuilder: (context, index) {

                              final result = controller.bookings[index];
                              final product = result.product;

                              if (product == null) {
                                return const SizedBox.shrink();
                              }

                              final dateString = result.date;
                              String formattedDate = 'N/A';
                              try {
                                if (dateString != null) {
                                  // This attempts to parse the date like "2025-11-24T18:00:00.000Z"
                                  final date = DateTime.parse(dateString);
                                  formattedDate = "${date.day}/${date.month}/${date.year}";
                                }
                              } catch (_) {
                                // Handle potential date format error
                                formattedDate = 'Invalid Date';
                              }

                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ?? 'assets/images/default_massage.png',

                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/User.svg",

                                title2: "Duration",
                                value2: result.duration?? 'N/A', // Time is directly available
                                icon2Path: "assets/icons/time.svg",

                                title3: "Date Time",
                                value3: formattedDate ?? 'N/A', // Duration is available
                                icon3Path: "assets/icons/CalendarDots.svg",

                                title4: "Total Price",
                                value4: (result.totalPrice ?? 0).toString(),
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );
                            },
                          );
                        }
                        else{
                          return Center(child: Text("data"),);
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