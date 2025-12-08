import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_booking_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/all_booking_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/widgets/dynamic_booking_card.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../routes/app_routes.dart';

class ProviderBookingRequestScreen extends StatefulWidget {
  const ProviderBookingRequestScreen({super.key});

  @override
  State<ProviderBookingRequestScreen> createState() =>
      _ProviderBookingRequestScreenState();
}

class _ProviderBookingRequestScreenState
    extends State<ProviderBookingRequestScreen> {
  final authController = Get.find<AuthController>();
  final allBookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    allBookingController.fetchBookings();
  }

  // Helper function to format date-time strings
  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'Invalid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GetBuilder<BookingController>(builder: (controller) {
            if (controller.isLoading) {
              return const BookingItemShimmer();
            }

            return SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Provider Profile
                    ProviderProfile(
                      imageUrl: authController.userModel!.profilePic ?? '',
                      role:
                      "${authController.userModel!.providerType ?? ""} Provider",
                      name: authController.userModel!.fullName ?? "",
                      onTap: () =>
                          Get.toNamed(Routes.providerProfileScreen),
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.red,
                        size: 30,
                      ),
                      onIconTap: () => print("Icon tapped!"),
                    ),

                    const SizedBox(height: 18),

                    /// All bookings title
                    Text("All Bookings (${controller.bookings.length})",
                        style: AppTextStyle.sub_h2_medium_16()),
                    const SizedBox(height: 15),

                    /// Booking list
                    Builder(builder: (_) {
                      if (controller.bookings.isEmpty) {
                        return Center(
                          child: Text(
                              controller.errorMessage ?? "No bookings found."),
                        );
                      }

                      final providerType =
                          authController.userModel!.providerType ?? "";

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.bookings.length,
                        itemBuilder: (context, index) {
                          final result = controller.bookings[index];
                          final product = result.product;

                          if (product == null) return const SizedBox.shrink();

                          switch (providerType) {
                            case "Ski_Pass":
                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ?? "",
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/info.svg",
                                title2: "SkiPass Type",
                                value2: product.skiPassType ?? 'N/A',
                                icon2Path: "assets/icons/badge.svg",
                                title3: "Total Amount",
                                value3: (result.totalPrice ?? 0).toString(),
                                icon3Path: "assets/icons/amount.svg",
                                title4: "Location",
                                value4: product.serviceArea ?? 'N/A',
                                icon4Path: "assets/icons/MapPinSimpleArea.svg",
                              );

                            case "Restaurant":
                              if (result.bookingItems.isEmpty ||
                                  result.slots.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final bookingItem = result.bookingItems[0];
                              final slot = result.slots[0];
                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ??
                                    'assets/images/default_restaurant.png',
                                title1: "Seat Type",
                                value1: bookingItem.itemDetails?.seat ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Seat Count",
                                value2:
                                bookingItem.quantity?.toString() ?? '0',
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Slot",
                                value3:
                                "${slot.startTime ?? 'N/A'} - ${slot.endTime ?? 'N/A'}",
                                icon3Path: "assets/icons/time.svg",
                                title4: "Total Price",
                                value4: (result.totalPrice ?? 0).toString(),
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );

                            case "Massage":
                              final formattedDate =
                              formatDateTime(result.date);
                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ??
                                    'assets/images/default_massage.png',
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/User.svg",
                                title2: "Duration",
                                value2: result.duration ?? 'N/A',
                                icon2Path: "assets/icons/time.svg",
                                title3: "Date Time",
                                value3: formattedDate,
                                icon3Path: "assets/icons/CalendarDots.svg",
                                title4: "Total Price",
                                value4: (result.totalPrice ?? 0).toString(),
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );

                            case "Transport":
                              String formatSmart(String? dateTime) {
                                if (dateTime == null) return 'N/A';
                                try {
                                  final dt = DateTime.parse(dateTime);
                                  final months = [
                                    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                                  ];

                                  final month = months[dt.month - 1];
                                  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                                  final period = dt.hour >= 12 ? "PM" : "AM";

                                  return "${dt.day.toString().padLeft(2, '0')} $month, ${dt.year} – "
                                      "${hour.toString().padLeft(2, '0')}:"
                                      "${dt.minute.toString().padLeft(2, '0')} $period";
                                } catch (_) {
                                  return 'Invalid';
                                }
                              }

                              final formattedStart = formatSmart(result.startDateAndTime);
                              final formattedEnd = formatSmart(result.endDateAndTime);

                              return ServiceInfoCard(
                                imageUrl: product.thumbnail ?? 'assets/images/default_transport.png',
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Product Model",
                                value2: result.productModel ?? 'N/A',
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Time",
                                value3: "$formattedStart → $formattedEnd",
                                icon3Path: "assets/icons/time.svg",
                                title4: "Total Price",
                                value4: (result.totalPrice ?? 0).toString(),
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );


                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      );
                    })
                  ],
                ),
              ),
            );
          }),
        ));
  }
}
