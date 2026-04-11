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
import '../controllers/provider_all_service_controller.dart' show AllServiceController;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final authController = Get.find<AuthController>();
  final homeController = Get.find<ProviderHomeController>();
  final navController  = Get.find<NavController>();

  // ── Assets ────────────────────────────────────────────────────────────────
  final images = Assets.images;
  final icons  = Assets.icons;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    homeController.fetchProviderHomeData();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// "YYYY-MM-DD HH:mm"
  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'Invalid';
    }
  }

  /// "01 Jan, 2024 – 02:30 PM"
  String _formatSmartDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      final dt     = DateTime.parse(dateTime);
      final hour   = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final period = dt.hour >= 12 ? "PM" : "AM";
      return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year} – "
          "${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
    } catch (_) {
      return 'Invalid';
    }
  }

  /// "X hour(s)" or "X day Y hour"
  String _formatDuration(String start, String end) {
    try {
      final diff       = DateTime.parse(end).difference(DateTime.parse(start));
      if (diff.inMinutes <= 0) return "0 hour";
      final totalHours = diff.inHours;
      if (totalHours >= 24) return "${totalHours ~/ 24} day ${totalHours % 24} hour";
      return "$totalHours hour(s)";
    } catch (_) {
      return "N/A";
    }
  }

  // ── Delete helper ─────────────────────────────────────────────────────────

  void _onDelete({
    required BuildContext context,
    required String url,
    required int index,
    String title = "Delete Service",
  }) {
    DeleteDialogService.show(
      context: context,
      title: title,
      message: "Are you sure you want to delete this service?",
      onDelete: () async {
        final deleteController = Get.put(DeleteController());
        final result = await deleteController.deleteItem(url: url);
        if (result) {
          homeController.providerHome!.recentServices.removeAt(index);
          homeController.update();
          Future.microtask(() => homeController.refreshData());
          return true;
        } else {
          Get.snackbar("Error", deleteController.errorMessage ?? "Delete failed");
          return false;
        }
      },
    );
  }

  // ── Price label ───────────────────────────────────────────────────────────

  String _priceLabel(dynamic service, String providerType) {
    if (providerType == "Ski_Pass") return "\€${service.amount}/Day";
    if (providerType == "Transport" ||
        providerType == "Massage"   ||
        providerType == "Ski_Hire") return "\€${service.amount}/Hr";
    return "\€${service.status}";
  }

  // ── Booking card builder ──────────────────────────────────────────────────

  Widget _buildBookingCard(dynamic booking, String providerType) {
    final product = booking.product;
    if (product == null) return const SizedBox();

    switch (providerType) {

      case "Ski_Pass":
        return ServiceInfoCard(
          onTap: () => Get.toNamed(Routes.passDetailsService, arguments: {"bookingId": booking.id}),
          imageUrl:  product.thumbnail ?? '',
          title1: "Title",        value1: product.title ?? '-',       icon1Path: "assets/icons/info.svg",
          title2: "SkiPass Type", value2: product.skiPassType ?? '-', icon2Path: "assets/icons/badge.svg",
          title3: "Total Amount",
          value3: (booking.totalPrice != 0 ? booking.totalPrice : product.totalPrice ?? 0).toString(),
          icon3Path: "assets/icons/CurrencyCircleDollar.svg",
          title4: "Location", value4: product.serviceArea ?? '-', icon4Path: "assets/icons/MapPinSimpleArea.svg",
        );

      case "Massage":
        return ServiceInfoCard(
          onTap: () => Get.toNamed(Routes.massageDetailsService, arguments: {"bookingId": booking.id}),
          imageUrl:  product.thumbnail ?? '',
          title1: "Title",       value1: product.title ?? '-',                     icon1Path: "assets/icons/badge.svg",
          title2: "Duration",    value2: booking.duration ?? '0',                  icon2Path: "assets/icons/time.svg",
          title3: "Date-Time",   value3: _formatDateTime(booking.date.toString()), icon3Path: "assets/icons/CalendarDots.svg",
          title4: "Total Price", value4: "€${(booking.totalPrice ?? 0).toString()}",     icon4Path: "assets/icons/CurrencyCircleDollar.svg",
        );

      case "Transport":
        return ServiceInfoCard(
          onTap: () => Get.toNamed(Routes.transportDetailsService, arguments: {"bookingId": booking.id}),
          imageUrl:  product.thumbnail ?? 'assets/images/default_transport.png',
          title1: "Title",         value1: product.title ?? 'N/A',       icon1Path: "assets/icons/badge.svg",
          title2: "Product Model", value2: booking.productModel ?? 'N/A', icon2Path: "assets/icons/user3.svg",
          title3: "Time",
          value3: "${_formatSmartDateTime(booking.startDateAndTime.toString())} → ${_formatSmartDateTime(booking.endDateAndTime.toString())}",
          icon3Path: "assets/icons/time.svg",
          title4: "Total Price", value4: "€${(booking.totalPrice ?? 0).toString()}", icon4Path: "assets/icons/CurrencyCircleDollar.svg",
        );

      case "Restaurant":
        final bookingItem = booking.bookingItems.isNotEmpty ? booking.bookingItems[0] : null;
        final slot        = booking.slots.isNotEmpty        ? booking.slots[0]        : null;
        if (bookingItem == null || slot == null) return const SizedBox();
        return ServiceInfoCard(
          onTap: () => Get.toNamed(Routes.restaurantDetailsService, arguments: {"bookingId": booking.id}),
          imageUrl:  product.thumbnail ?? 'assets/images/default_restaurant.png',
          title1: "Seat Type",   value1: bookingItem.itemDetails?.seat ?? 'N/A',                    icon1Path: "assets/icons/badge.svg",
          title2: "Seat Count",  value2: bookingItem.quantity?.toString() ?? '0',                   icon2Path: "assets/icons/user3.svg",
          title3: "Slot",        value3: "${slot.startTime ?? 'N/A'} - ${slot.endTime ?? 'N/A'}",  icon3Path: "assets/icons/time.svg",
          title4: "Total Price", value4: "€${(booking.totalPrice ?? 0)}",                  icon4Path: "assets/icons/CurrencyCircleDollar.svg",
        );

      default: // Ski_Hire
        return ServiceInfoCard(
          onTap: () => Get.toNamed(Routes.hireDetailsService, arguments: {"bookingId": booking.id}),
          imageUrl:  product.thumbnail ?? '',
          title1: "Ski Title",    value1: product.title ?? 'N/A',                                                                  icon1Path: "assets/icons/badge.svg",
          title2: "Duration",     value2: _formatDuration(booking.startDateAndTime.toString(), booking.endDateAndTime.toString()),  icon2Path: "assets/icons/user3.svg",
          title3: "Total Amount", value3: "€ ${(booking.totalPrice ?? 0)}",                                                            icon3Path: "assets/icons/CurrencyCircleDollar.svg",
          title4: "Location",     value4: product.serviceArea ?? "N/A",                                                            icon4Path: "assets/icons/MapPinSimpleArea.svg",
        );
    }
  }

  // ── Empty placeholders ────────────────────────────────────────────────────

  Widget _emptyServices() => SizedBox(
    height: 200,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("No services added yet", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    ),
  );

  Widget _emptyBookings() => SizedBox(
    height: 200,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("No bookings found", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── Profile — always visible, never hidden by shimmer ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: ProviderProfile(
                onProfileTap:      () => Get.toNamed(Routes.profile),
                onNotificationTap: () => Get.toNamed(Routes.notification),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: GetBuilder<ProviderHomeController>(
                builder: (controller) {

                  if (authController.userModel == null || controller.isLoading) {
                    return const ProviderHomeShimmer();
                  }

                  if (controller.providerHome == null) {
                    return const Center(child: Text("No Data Found"));
                  }

                  final providerType   = authController.userModel!.providerType!;
                  final stats          = controller.providerHome!.stats;
                  final recentServices = controller.providerHome!.recentServices;
                  final recentBookings = controller.providerHome!.recentBookings;

                  final statsMap = {
                    "Today booking":   stats.todayBookingCount,
                    "Booking Request": stats.totalBooking,
                    "Amount":          "\€${stats.totalBalance}",
                  };

                  return RefreshIndicator(
                    color: AppColors.primary_1,
                    onRefresh: () async => controller.refreshData(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // ── Stats ────────────────────────────────────────
                          _StatsRow(statsMap: statsMap),

                          const SizedBox(height: 20),

                          // ── My Services ──────────────────────────────────
                          CategoryTitle(
                            title: "My service",
                            text: "See All",
                            onClick: () => navController.changeIndex(1),
                          ),
                          const SizedBox(height: 11),

                          recentServices.isEmpty
                              ? _emptyServices()
                              : SizedBox(
                            height: 255,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentServices.length,
                              itemBuilder: (context, index) {
                                final service = recentServices[index];

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    width: 300,
                                    child: MyServiceCard(
                                      image:       service.thumbnail,
                                      title:       service.title,
                                      rating:      service.averageRating.toDouble(),
                                      reviews:     service.reviews.length,
                                      location:    service.serviceArea,
                                      packageType: service.skiPassType,
                                      status:      _priceLabel(service, providerType),

                                      // ── Delete ───────────────────
                                      onDelete: () async {
                                        if (providerType == "Ski_Pass") {
                                          _onDelete(context: context, url: AppUrls.providerPassServiceDelete(service.id), index: index);
                                        } else if (providerType == "Massage") {
                                          _onDelete(context: context, url: AppUrls.deleteMassageServiceUrl(service.id), index: index);
                                        } else if (providerType == "Ski_Hire") {
                                          _onDelete(context: context, url: AppUrls.deleteHireServiceUrl(service.id), index: index);
                                        } else if (providerType == "Transport") {
                                          _onDelete(context: context, url: AppUrls.deleteTransportUrl(service.id), index: index);
                                        } else {
                                          _onDelete(context: context, url: AppUrls.deleteRestaurantUrl(service.id), index: index, title: "Delete Seat");
                                        }
                                      },

                                      // ── Edit (original logic — untouched) ──
                                      onEdit: () async {
                                        if (providerType == "Restaurant") {
                                          final result = await Get.toNamed(
                                            Routes.addRestaurantService,
                                            arguments: {
                                              "restaurant": Result.fromRecentService(service),
                                              "isEdit": true,
                                            },
                                          );
                                          if (result == true) homeController.refreshData();

                                        } else if (providerType == "Massage") {
                                          final result = await Get.toNamed(
                                            Routes.addMessageService,
                                            arguments: {
                                              "massage": MassageResult.fromRecentService(service),
                                              "isEdit": true,
                                            },
                                          );
                                          if (result == true) homeController.refreshData();

                                        } else if (providerType == "Transport") {
                                          final result = await Get.toNamed(
                                            Routes.addTransportService,
                                            arguments: {
                                              "transport": TransportResult.fromRecentService(service),
                                              "isEdit": true,
                                            },
                                          );
                                          if (result == true) homeController.refreshData();

                                        } else if (providerType == "Ski_Hire") {
                                          final result = await Get.toNamed(
                                            Routes.addHireService,
                                            arguments: {
                                              "hire": service.toHireResult(),
                                              "isEdit": true,
                                            },
                                          );
                                          if (result == true) homeController.refreshData();

                                        } else {
                                          final result = await Get.toNamed(
                                            Routes.addPassService,
                                            arguments: {
                                              "pass": service.toSkiPass(),
                                              "isEdit": true,
                                            },
                                          );
                                          if (result == true) homeController.refreshData();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Booking Management ───────────────────────────
                          CategoryTitle(
                            title: "Booking management",
                            text: "See All",
                            onClick: () => navController.changeIndex(2),
                          ),

                          recentBookings.isEmpty
                              ? _emptyBookings()
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentBookings.length,
                            itemBuilder: (_, index) => _buildBookingCard(
                              recentBookings[index],
                              providerType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.statsMap});

  final Map<String, dynamic> statsMap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statsMap.entries.map((entry) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 85,
            decoration: BoxDecoration(
              border:       Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color:        Colors.white,
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  child: Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.sub_h2_medium_16().copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${entry.value}",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h3_semibold_20().copyWith(
                    color:    AppColors.primary_1,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}