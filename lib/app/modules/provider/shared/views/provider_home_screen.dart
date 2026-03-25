import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_home_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_massage_service_model.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_resturant_service.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_transport_service_model.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/models/extention.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/dynamic_booking_card.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../routes/app_routes.dart';
import '../../pass/controller/delete_controller.dart';
import '../controllers/provider_all_service_controller.dart'
    show AllServiceController;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final authController = Get.find<AuthController>();
  final homeController = Get.find<ProviderHomeController>();
  final navController = Get.find<NavController>();

  final images = Assets.images;
  final icons = Assets.icons;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  /// Helper function to format date-time strings
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

  Future<void> _fetchData() async {
    await homeController.fetchProviderHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<ProviderHomeController>(
          builder: (controller) {
            if (authController.userModel == null || controller.isLoading) {
              return ProviderHomeShimmer();
            }

            if (controller.providerHome == null) {
              return const Center(child: Text("No Data Found"));
            }

            final providerStats = controller.providerHome!.stats;
            final statsMap = {
              "Today booking": providerStats.todayBookingCount,
              "Booking Request": providerStats.totalBooking,
              "Amount": "\$${providerStats.totalBalance}",
            };

            final recentServices = controller.providerHome!.recentServices;
            final recentBookings = controller.providerHome!.recentBookings;

            return RefreshIndicator(
              color: AppColors.primary_1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile
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

                      const SizedBox(height: 20),

                      // Stats Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: statsMap.entries.map((entry) {
                          final title = entry.key;
                          final value = entry.value;

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 85,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle.sub_h2_medium_16()
                                          .copyWith(
                                            fontSize: 11,
                                            color: Colors.grey.shade700,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$value",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.h3_semibold_20()
                                        .copyWith(
                                          color: AppColors.primary_1,
                                          fontSize: 17,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      //----- My Services Section
                      CategoryTitle(
                        title: "My service",
                        text: "See All",
                        onClick: () {
                          navController.changeIndex(1);
                        },
                      ),

                      const SizedBox(height: 11),

                      recentServices.isEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "No services added yet",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 255,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentServices.length,
                                itemBuilder: (context, index) {
                                  String providerType =
                                      authController.userModel!.providerType!;

                                  final service = recentServices[index];

                                  // Determine the price text
                                  String text = providerType == "Ski_Pass"
                                      ? "\$${service.amount}/Day"
                                      : (providerType == "Transport" ||
                                            providerType == "Massage" ||
                                            providerType == "Ski_Hire")
                                      ? "\$${service.amount}/Hr"
                                      : "\$${service.status}";

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 300,
                                      child: MyServiceCard(
                                        image: service
                                            .thumbnail, // service thumbnail
                                        title: service.title, // service title

                                        rating: service.averageRating
                                            .toDouble(), // rating
                                        reviews: service
                                            .reviews
                                            .length, // number of reviews
                                        location: service
                                            .serviceArea, // location/service area
                                        /// delete
                                        onDelete: () async {
                                          if (providerType == "Ski_Pass") {
                                            DeleteDialogService.show(
                                              context: context,
                                              title: "Delete Service",
                                              message:
                                                  "Are you sure you want to delete this service?",
                                              onDelete: () async {
                                                final deleteController =
                                                    Get.put(DeleteController());
                                                final result =
                                                    await deleteController
                                                        .deleteItem(
                                                          url:
                                                              AppUrls.providerPassServiceDelete(
                                                                service.id,
                                                              ),
                                                        );

                                                if (result) {
                                                  homeController
                                                      .providerHome!
                                                      .recentServices
                                                      .removeAt(index);
                                                  homeController.update();

                                                  Future.microtask(() {
                                                    homeController
                                                        .refreshData();
                                                  });

                                                  return true; // Closes the dialog quickly
                                                } else {
                                                  Get.snackbar(
                                                    "Error",
                                                    deleteController
                                                            .errorMessage ??
                                                        "Delete failed",
                                                  );
                                                  return false;
                                                }
                                              },
                                            );
                                          } else if (providerType ==
                                              "Massage") {
                                            DeleteDialogService.show(
                                              context: context,
                                              title: "Delete Service",
                                              message:
                                                  "Are you sure you want to delete this service?",
                                              onDelete: () async {
                                                final deleteController =
                                                    Get.put(DeleteController());
                                                final result =
                                                    await deleteController
                                                        .deleteItem(
                                                          url:
                                                              AppUrls.deleteMassageServiceUrl(
                                                                service.id,
                                                              ),
                                                        );

                                                if (result) {
                                                  homeController
                                                      .providerHome!
                                                      .recentServices
                                                      .removeAt(index);
                                                  homeController.update();

                                                  Future.microtask(() {
                                                    homeController
                                                        .refreshData();
                                                  });

                                                  return true; // Closes the dialog quickly
                                                } else {
                                                  Get.snackbar(
                                                    "Error",
                                                    deleteController
                                                            .errorMessage ??
                                                        "Delete failed",
                                                  );
                                                  return false;
                                                }
                                              },
                                            );
                                          } else if (providerType ==
                                              "Ski_Hire") {
                                            // for delete

                                            DeleteDialogService.show(
                                              context: context,
                                              title: "Delete Service",
                                              message:
                                                  "Are you sure you want to delete this service?",
                                              onDelete: () async {
                                                final deleteController =
                                                    Get.put(DeleteController());
                                                final result =
                                                    await deleteController
                                                        .deleteItem(
                                                          url:
                                                              AppUrls.deleteHireServiceUrl(
                                                                service.id,
                                                              ),
                                                        );

                                                if (result) {
                                                  homeController
                                                      .providerHome!
                                                      .recentServices
                                                      .removeAt(index);
                                                  homeController.update();

                                                  Future.microtask(() {
                                                    homeController
                                                        .refreshData();
                                                  });

                                                  return true; // Closes the dialog quickly
                                                } else {
                                                  Get.snackbar(
                                                    "Error",
                                                    deleteController
                                                            .errorMessage ??
                                                        "Delete failed",
                                                  );
                                                  return false;
                                                }
                                              },
                                            );
                                          } else {
                                            DeleteDialogService.show(
                                              context: context,
                                              title: "Delete Seat",
                                              message:
                                                  "Are you sure you want to delete this service?",
                                              onDelete: () async {
                                                final deleteController =
                                                    Get.put(DeleteController());
                                                final result =
                                                    await deleteController
                                                        .deleteItem(
                                                          url:
                                                              AppUrls.deleteRestaurantUrl(
                                                                service.id,
                                                              ),
                                                        );

                                                if (result) {
                                                  homeController
                                                      .providerHome!
                                                      .recentServices
                                                      .removeAt(index);
                                                  homeController.update();

                                                  Future.microtask(() {
                                                    homeController
                                                        .refreshData();
                                                  });

                                                  return true; // Closes the dialog quickly
                                                } else {
                                                  Get.snackbar(
                                                    "Error",
                                                    deleteController
                                                            .errorMessage ??
                                                        "Delete failed",
                                                  );
                                                  return false;
                                                }
                                              },
                                            );
                                          }
                                        },

                                        /// edit
                                        onEdit: () async {
                                          if (providerType == "Restaurant") {
                                            final fullRestaurantModel =
                                                Result.fromRecentService(
                                                  service,
                                                );

                                            final result = await Get.toNamed(
                                              Routes.addRestaurantService,
                                              arguments: {
                                                "restaurant":
                                                    fullRestaurantModel, // Pass the converted model
                                                "isEdit": true,
                                              },
                                            );

                                            if (result == true) {
                                              // only refresh if actual changes happened
                                              homeController.refreshData();
                                            }
                                          } else if (providerType ==
                                              "Massage") {
                                            final fullMassageModel =
                                                MassageResult.fromRecentService(
                                                  service,
                                                );

                                            final result = await Get.toNamed(
                                              Routes.addMessageService,
                                              arguments: {
                                                "massage":
                                                    fullMassageModel, // Pass the converted model
                                                "isEdit": true,
                                              },
                                            );

                                            if (result == true) {
                                              // only refresh if actual changes happened
                                              homeController.refreshData();
                                            }
                                          } else if (providerType ==
                                              "Transport") {
                                            // Convert RecentService to TransportResult
                                            final fullTransportModel =
                                                TransportResult.fromRecentService(
                                                  service,
                                                );

                                            // Navigate to Add Transport Service screen
                                            final result = await Get.toNamed(
                                              Routes.addTransportService,
                                              arguments: {
                                                "transport": fullTransportModel,
                                                "isEdit": true,
                                              },
                                            );

                                            // Only refresh if actual changes happened
                                            if (result == true) {
                                              homeController.refreshData();
                                            }
                                          } else if (providerType ==
                                              "Ski_Hire") {
                                            final fullHireModel = service
                                                .toHireResult();

                                            final result = await Get.toNamed(
                                              Routes.addHireService,
                                              arguments: {
                                                "hire": fullHireModel,
                                                "isEdit": true,
                                              },
                                            );

                                            if (result == true) {
                                              homeController.refreshData();
                                            }
                                          } else {
                                            final skiPass = service.toSkiPass();

                                            final result = await Get.toNamed(
                                              Routes.addPassService,
                                              arguments: {
                                                "pass": skiPass,
                                                "isEdit": true,
                                              },
                                            );

                                            if (result == true) {
                                              homeController.refreshData();
                                            }
                                          }
                                        },

                                        packageType: service.skiPassType,
                                        status: text,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 20),

                      //--- Booking Management Section
                      CategoryTitle(
                        title: "Booking management",
                        text: "See All",
                        onClick: () {
                          navController.changeIndex(2);
                        },
                      ),

                      recentBookings.isEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "No bookings found",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recentBookings.length,
                              itemBuilder: (context, index) {
                                final booking = recentBookings[index];
                                final product = booking.product;
                                final providerType =
                                    authController.userModel?.providerType ??
                                    '';

                                if (product == null) return const SizedBox();

                                final item = booking.bookingItems.isNotEmpty
                                    ? booking.bookingItems[0]
                                    : null;

                                if (providerType == "Ski_Pass") {
                                  ///pass
                                  return ServiceInfoCard(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.passDetailsService,
                                        arguments: {"bookingId": booking.id},
                                      );
                                    },
                                    imageUrl: product.thumbnail ?? '',
                                    title1: "Title",
                                    value1: product.title ?? '-',
                                    icon1Path: "assets/icons/info.svg",

                                    title2: "SkiPass Type",
                                    value2: product.skiPassType ?? '-',
                                    icon2Path: "assets/icons/badge.svg",

                                    title3: "Total Amount",
                                    value3:
                                        (booking.totalPrice != 0
                                                ? booking.totalPrice
                                                : product.totalPrice ?? 0)
                                            .toString(),
                                    icon3Path: "assets/icons/amount.svg",

                                    title4: "Location",
                                    value4: product.serviceArea ?? '-',
                                    icon4Path:
                                        "assets/icons/MapPinSimpleArea.svg",
                                  );
                                } else if (providerType == "Massage") {
                                  final formattedDate = formatDateTime(
                                    booking.date.toString(),
                                  );

                                  return ServiceInfoCard(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.massageDetailsService,
                                        arguments: {"bookingId": booking.id},
                                      );
                                    },
                                    imageUrl: product.thumbnail ?? '',
                                    title1: "Title",
                                    value1: product.title ?? '-',
                                    icon1Path: "assets/icons/badge.svg",

                                    title2: "Duration",
                                    value2: booking.duration ?? '0',
                                    icon2Path: "assets/icons/time.svg",

                                    title3: "Date-Time",
                                    // Pass the formatted slotTime string
                                    value3: formattedDate,
                                    icon3Path: "assets/icons/CalendarDots.svg",

                                    title4: "Total Price",
                                    value4: (booking.totalPrice ?? 0)
                                        .toString(),
                                    icon4Path:
                                        "assets/icons/CurrencyCircleDollar.svg",
                                  );
                                } else if (providerType == "Transport") {
                                  String formatSmart(String? dateTime) {
                                    if (dateTime == null) return 'N/A';
                                    try {
                                      final dt = DateTime.parse(dateTime);
                                      final months = [
                                        "Jan",
                                        "Feb",
                                        "Mar",
                                        "Apr",
                                        "May",
                                        "Jun",
                                        "Jul",
                                        "Aug",
                                        "Sep",
                                        "Oct",
                                        "Nov",
                                        "Dec",
                                      ];

                                      final month = months[dt.month - 1];
                                      final hour = dt.hour % 12 == 0
                                          ? 12
                                          : dt.hour % 12;
                                      final period = dt.hour >= 12
                                          ? "PM"
                                          : "AM";

                                      return "${dt.day.toString().padLeft(2, '0')} $month, ${dt.year} – "
                                          "${hour.toString().padLeft(2, '0')}:"
                                          "${dt.minute.toString().padLeft(2, '0')} $period";
                                    } catch (_) {
                                      return 'Invalid';
                                    }
                                  }

                                  final formattedStart = formatSmart(
                                    booking.startDateAndTime.toString(),
                                  );
                                  final formattedEnd = formatSmart(
                                    booking.endDateAndTime.toString(),
                                  );

                                  return ServiceInfoCard(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.transportDetailsService,
                                        arguments: {"bookingId": booking.id},
                                      );
                                    },
                                    imageUrl:
                                        product.thumbnail ??
                                        'assets/images/default_transport.png',
                                    title1: "Title",
                                    value1: product.title ?? 'N/A',
                                    icon1Path: "assets/icons/badge.svg",
                                    title2: "Product Model",
                                    value2: booking.productModel ?? 'N/A',
                                    icon2Path: "assets/icons/user3.svg",
                                    title3: "Time",
                                    value3: "$formattedStart → $formattedEnd",
                                    icon3Path: "assets/icons/time.svg",
                                    title4: "Total Price",
                                    value4: (booking.totalPrice ?? 0)
                                        .toString(),
                                    icon4Path:
                                        "assets/icons/CurrencyCircleDollar.svg",
                                  );
                                } else if (providerType == "Restaurant") {
                                  final bookingItem =
                                      booking.bookingItems.isNotEmpty
                                      ? booking.bookingItems[0]
                                      : null;
                                  final slot = booking.slots.isNotEmpty
                                      ? booking.slots[0]
                                      : null;
                                  if (bookingItem == null || slot == null) {
                                    // Return an empty widget or placeholder if data is missing
                                    return const SizedBox();
                                  }
                                  final seat =
                                      bookingItem.itemDetails?.seat ?? 'N/A';

                                  return ServiceInfoCard(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.restaurantDetailsService,
                                        arguments: {"bookingId": booking.id},
                                      );
                                    },
                                    imageUrl:
                                        product.thumbnail ??
                                        'assets/images/default_restaurant.png',
                                    title1: "Seat Type",
                                    value1: seat,
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
                                    value4: (booking.totalPrice ?? 0)
                                        .toString(),
                                    icon4Path:
                                        "assets/icons/CurrencyCircleDollar.svg",
                                  );
                                } else {
                                  /// hire

                                  /// duration converter
                                  String formatDuration(
                                    String start,
                                    String end,
                                  ) {
                                    try {
                                      final startDt = DateTime.parse(start);
                                      final endDt = DateTime.parse(end);

                                      final difference = endDt.difference(
                                        startDt,
                                      );

                                      if (difference.inMinutes <= 0) {
                                        return "0 hour";
                                      }

                                      final totalHours = difference.inHours;
                                      final days = totalHours ~/ 24;
                                      final hours = totalHours % 24;

                                      // If more than 24 hours → show day + hour
                                      if (totalHours >= 24) {
                                        return "$days day $hours hour";
                                      }

                                      // Less than 24 hours → show hours only
                                      return "$totalHours hour(s)";
                                    } catch (e) {
                                      return "N/A";
                                    }
                                  }

                                  return ServiceInfoCard(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.hireDetailsService,
                                        arguments: {"bookingId": booking.id},
                                      );
                                    },
                                    imageUrl: product.thumbnail ?? '',
                                    title1: "Ski Title",
                                    value1: product.title ?? 'N/A',
                                    icon1Path: "assets/icons/badge.svg",

                                    title2: "Duration",
                                    value2:
                                        formatDuration(
                                          booking.startDateAndTime.toString(),
                                          booking.endDateAndTime.toString(),
                                        ) ??
                                        "N/A",
                                    icon2Path: "assets/icons/user3.svg",

                                    title3: "Total Amount",

                                    value3: booking.totalPrice.toString(),
                                    icon3Path:
                                        "assets/icons/CurrencyCircleDollar.svg",

                                    title4: "Location",
                                    value4: product.serviceArea ?? "N/A",
                                    icon4Path:
                                        "assets/icons/CurrencyCircleDollar.svg",
                                  );
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),
              onRefresh: () async {

                controller.refreshData();
              },
            );
          },
        ),
      ),
    );
  }
}
