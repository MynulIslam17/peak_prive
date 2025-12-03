import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_home_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/dynamic_booking_card.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../routes/app_routes.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final authController = Get.find<AuthController>();
  final homeController = Get.find<ProviderHomeController>();

  final images = Assets.images;
  final icons = Assets.icons;

  @override
  void initState() {
    super.initState();

    _fetchData();
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
              "Amount": providerStats.totalBalance,
            };

            final recentServices = controller.providerHome!.recentServices;
            final recentBookings = controller.providerHome!.recentBookings;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Profile
                    ProviderProfile(
                      imageUrl: authController.userModel!.profilePic ?? '',
                      role:
                      "${authController.userModel!.providerType ?? ""} Provider",
                      name: authController.userModel!.fullName ?? "",
                      onTap: () {
                        Get.toNamed(Routes.providerProfileScreen);
                      },
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.red,
                        size: 30,
                      ),
                      onIconTap: () {

                        print("Icon tapped!");
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

                    // My Services Section
                    CategoryTitle(
                      title: "My service",
                      text: "See All",
                      onClick: () {},
                    ),

                    const SizedBox(height: 11),

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
                                image: service.thumbnail, // service thumbnail
                                title: service.title, // service title
                                price: "\$${service.totalPrice}", // service amount/price
                                rating: service.averageRating.toDouble(), // rating
                                reviews: service.reviews.length, // number of reviews
                                location: service.serviceArea, // location/service area
                                onDelete: () {},
                                onEdit: () {},
                                packageType: service.skiPassType,
                              ),
                            ),
                          );
                        },
                      ),

                    ),

                    const SizedBox(height: 20),

                    // Booking Management Section
                    CategoryTitle(
                      title: "Booking management",
                      text: "See All",
                      onClick: () {},
                    ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentBookings.length,
                  itemBuilder: (context, index) {
                    final booking = recentBookings[index];
                    final product = booking.product;
                    final providerType=authController.userModel!.providerType;


                    if (product == null) return const SizedBox();

                    if(providerType=="Ski_Pass"){
                      return ServiceInfoCard(
                        imageUrl: product.thumbnail ?? '',
                        title1: "Title",
                        value1: product.title ?? '',
                        icon1Path: "assets/icons/info.svg",

                        title2: "SkiPass Type",
                        value2: product.skiPassType ?? '-',
                        icon2Path: "assets/icons/badge.svg",

                        title3: "Total Amount",
                        value3: (booking.totalPrice ?? product.totalPrice ?? 0).toString(),
                        icon3Path: "assets/icons/amount.svg",

                        title4: "Location",
                        value4: product.serviceArea ?? '-',
                        icon4Path: "assets/icons/MapPinSimpleArea.svg",
                      );
                    }else {
                      return ServiceInfoCard(
                        imageUrl: product.thumbnail ?? '',
                        title1: "Title",
                        value1: product.title ?? '',
                        icon1Path: "assets/icons/info.svg",

                        title2: "Duration",
                        value2: booking.duration ?? '-',
                        icon2Path: "assets/icons/time.svg",

                        title3: "Total Amount",
                        value3: (booking.totalPrice ?? product.totalPrice ?? 0).toString(),
                        icon3Path: "assets/icons/amount.svg",

                        title4: "Location",
                        value4: product.serviceArea ?? '-',
                        icon4Path: "assets/icons/MapPinSimpleArea.svg",
                      );
                    }



                  },
                )

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
