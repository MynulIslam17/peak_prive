import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_home_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_booking_card.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../routes/app_routes.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  /// find controller
  final authController = Get.find<AuthController>();
  final homeController = Get.find<ProviderHomeController>();

  final images = Assets.images;
  final icons = Assets.icons;

  final List<Map<String, dynamic>> _requestPending = [
    {"Today booking": 06},
    {"Booking request": 33},
    {"Amount": "20K"},
  ];

  @override
  void initState() {
    // TODO: implement initState

    ///call the method for fetch home data

    _fetchData();

    super.initState();
  }

  Future<void> _fetchData() async {
    bool success = await homeController.fetchProviderHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: GetBuilder<ProviderHomeController>(
          builder: (controller) {
            // Show shimmer while loading
            if (controller.isLoading) {
              return ProviderHomeShimmer();
            }

            if (controller.providerHome == null) {
              return Center(child: Text("Not Data Found"));
            }

            /// get stats map
            final providerStats = controller.providerHome!.stats;
            final statsMap = {
              "Today booking": providerStats.todayBookingCount,
              "Booking Request": providerStats.totalBooking,
              "Amount": providerStats.totalBalance,
            };

            // Use recent services from model
            final recentServices = controller.providerHome!.recentServices;

            // Use recent bookings from model
            final recentBookings = controller.providerHome!.recentBookings;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    /// profile section
                    ProviderProfile(
                      imageUrl:
                          authController.userModel!.profilePic ??
                          '', // network URL
                      role:
                          "${authController.userModel!.providerType!} Provider",
                      name: authController.userModel!.fullName ?? "",
                      onTap: () {
                        Get.toNamed(Routes.providerProfileScreen);
                      },
                    ),

                    SizedBox(height: 20),

                    ///pending service booking request section
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // evenly spaced
                      children: statsMap.entries.map((entry) {
                        final title = entry.key;
                        final value = entry.value;

                        return Expanded(
                          /// makes all cards equal width
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Text(
                                    "$title",
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
                                  style: AppTextStyle.h3_semibold_20().copyWith(
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

                    SizedBox(height: 20),

                    /// my service
                    CategoryTitle(
                      title: "My service",
                      text: "See All",
                      onClick: () {},
                    ),

                    SizedBox(height: 11),

                    SizedBox(
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
                                image: service.thumbnail, // thumbnail from model
                                title: service.title,
                                price: "\$${service.totalPrice}", // convert to string
                                rating: service.averageRating.toDouble(),
                                reviews: service.reviews.length,
                                location: service.serviceArea,
                                onDelete: () {},
                                onEdit: () {},
                                packageType: "Premium",
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    /// My booking
                    CategoryTitle(
                      title: "Booking management",
                      text: "See All",
                      onClick: () {},
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recentBookings.length,
                      itemBuilder: (context, index) {
                        final booking = recentBookings[index];
                        return ProviderBookingCard(
                          image: booking.product!.thumbnail, // you can decide what to show as image
                          onTap: () {},
                        );
                      },
                    ),





                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
