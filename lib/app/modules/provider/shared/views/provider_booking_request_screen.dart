import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_booking_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/all_booking_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/widgets/dynamic_booking_card.dart';
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

            return RefreshIndicator(
              onRefresh: () async {
                await controller.refreshBookings(showLoader: false);
              },
              color: AppColors.primary_1,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- HEADER SECTION (Always Visible) ---
                    ProviderProfile(
                      onProfileTap: () {
                        // Navigate to profile screen
                        Get.toNamed(Routes.profile);
                      },
                      onNotificationTap: () {
                        // Navigate to notifications screen
                        Get.toNamed(Routes.notification);
                      },
                    ),
                    const SizedBox(height: 18),

                    Text(
                        "All Bookings (${controller.bookings.length})",
                        style: AppTextStyle.sub_h2_medium_16()),
                    const SizedBox(height: 15),

                    /// --- DATA/SHIMMER SECTION ---
                    Builder(builder: (_) {
                      // Check loading state here so header stays visible
                      if (controller.isLoading) {
                        return _shimmerBox();
                      }

                      if (controller.bookings.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                                controller.errorMessage ?? "No bookings found.",
                                style: AppTextStyle.sub_h3_medium_14()),
                          ),
                        );
                      }

                      final providerType = authController.userModel!.providerType ?? "";

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
                                onTap: () => Get.toNamed(Routes.passDetailsService, arguments: {"bookingId": result.sId}),
                                imageUrl: product.thumbnail ?? "",
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/info.svg",
                                title2: "SkiPass Type",
                                value2: product.skiPassType ?? 'N/A',
                                icon2Path: "assets/icons/badge.svg",
                                title3: "Total Amount",
                                value3: "€${(result.totalPrice ?? 0)}",
                                icon3Path: "assets/icons/amount.svg",
                                title4: "Location",
                                value4: product.serviceArea ?? 'N/A',
                                icon4Path: "assets/icons/MapPinSimpleArea.svg",
                              );

                            case "Restaurant":
                              if (result.bookingItems.isEmpty || result.slots.isEmpty) return const SizedBox.shrink();
                              final bookingItem = result.bookingItems[0];
                              final slot = result.slots[0];
                              return ServiceInfoCard(
                                onTap: () => Get.toNamed(Routes.restaurantDetailsService, arguments: {"bookingId": result.sId}),
                                imageUrl: product.thumbnail ?? 'assets/images/default_restaurant.png',
                                title1: "Seat Type",
                                value1: bookingItem.itemDetails?.seat ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Seat Count",
                                value2: bookingItem.quantity?.toString() ?? '0',
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Slot",
                                value3: "${slot.startTime ?? 'N/A'} - ${slot.endTime ?? 'N/A'}",
                                icon3Path: "assets/icons/time.svg",
                                title4: "Total Price",
                                value4: "€${(result.totalPrice ?? 0)}",
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );

                            case "Massage":
                              return ServiceInfoCard(
                                onTap: () => Get.toNamed(Routes.massageDetailsService, arguments: {"bookingId": result.sId}),
                                imageUrl: product.thumbnail ?? 'assets/images/default_massage.png',
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/User.svg",
                                title2: "Duration",
                                value2: result.duration ?? 'N/A',
                                icon2Path: "assets/icons/time.svg",
                                title3: "Date Time",
                                value3: formatDateTime(result.date),
                                icon3Path: "assets/icons/CalendarDots.svg",
                                title4: "Total Price",
                                value4: "€${(result.totalPrice ?? 0)}",
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );

                            case "Transport":
                              String formatSmart(String? dateTime) {
                                if (dateTime == null) return 'N/A';
                                try {
                                  final dt = DateTime.parse(dateTime);
                                  final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                  final month = months[dt.month - 1];
                                  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                                  final period = dt.hour >= 12 ? "PM" : "AM";
                                  return "${dt.day.toString().padLeft(2, '0')} $month, ${dt.year} – ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
                                } catch (_) { return 'Invalid'; }
                              }
                              return ServiceInfoCard(
                                onTap: () => Get.toNamed(Routes.transportDetailsService, arguments: {"bookingId": result.sId}),
                                imageUrl: product.thumbnail ?? 'assets/images/default_transport.png',
                                title1: "Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Product Model",
                                value2: result.productModel ?? 'N/A',
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Time",
                                value3: "${formatSmart(result.startDateAndTime)} → ${formatSmart(result.endDateAndTime)}",
                                icon3Path: "assets/icons/time.svg",
                                title4: "Total Price",
                                value4: "€${(result.totalPrice ?? 0)}",
                                icon4Path: "assets/icons/CurrencyCircleDollar.svg",
                              );

                            case "Ski_Hire":
                              String formatDuration(String start, String end) {
                                try {
                                  final startDt = DateTime.parse(start);
                                  final endDt = DateTime.parse(end);
                                  final diff = endDt.difference(startDt);
                                  if (diff.inMinutes <= 0) return "0 hour";
                                  final days = diff.inHours ~/ 24;
                                  final hours = diff.inHours % 24;
                                  return days >= 1 ? "$days day $hours hour" : "${diff.inHours} hour(s)";
                                } catch (_) { return "N/A"; }
                              }
                              return ServiceInfoCard(
                                onTap: () => Get.toNamed(Routes.hireDetailsService, arguments: {"bookingId": result.sId}),
                                imageUrl: product.thumbnail ?? '',
                                title1: "Ski Title",
                                value1: product.title ?? 'N/A',
                                icon1Path: "assets/icons/badge.svg",
                                title2: "Duration",
                                value2: formatDuration(result.startDateAndTime.toString(), result.endDateAndTime.toString()),
                                icon2Path: "assets/icons/user3.svg",
                                title3: "Total Amount",
                                value3: "€${result.totalPrice}",
                                icon3Path: "assets/icons/CurrencyCircleDollar.svg",
                                title4: "Location",
                                value4: product.serviceArea ?? "N/A",
                                icon4Path: "assets/icons/MapPinSimpleArea.svg",
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



  Widget _shimmerBox() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(8, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: double.infinity,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
    );
  }

}