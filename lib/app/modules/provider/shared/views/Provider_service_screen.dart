import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';
import 'package:harry_service_app/app/core/widgets/my_service_card.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_service_shimmer.dart';
import '../../../../routes/app_routes.dart';
import '../../pass/views/add_pass_screen.dart';
import '../controllers/provider_all_service_controller.dart';

class ProviderServiceScreen extends StatefulWidget {
  const ProviderServiceScreen({super.key});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {
  final authController = Get.find<AuthController>();
  final skiPassController = Get.put(SkiPassController());

  void _createNewService() {
    final providerType = authController.userModel!.providerType;

    if (providerType == "Ski_Pass") {
      _navigateToAddPass();
    } else if (providerType == "Transport") {
      Get.toNamed(Routes.transportDetails);
    } else if (providerType == "Restaurant") {
      Get.toNamed(Routes.addRestaurantService);
    } else if (providerType == "Massage") {
      Get.toNamed(Routes.addMessageService);
    } else {
      Get.toNamed(Routes.addMessageService);
    }
  }

  /// Navigate to AddPassScreen and refresh data on return
  Future<void> _navigateToAddPass() async {

    final result = await Get.to(() => const AddPassScreen());

    // If result is true, refresh the ski pass list
    if (result == true) {
      await _refreshSkiPassList();
    }



  }

  /// Refresh ski pass list
  Future<void> _refreshSkiPassList() async {
    // Call the refresh method from controller
    await skiPassController.refreshData();
  }

  @override
  void initState() {
    super.initState();
    // Fetch ski passes on screen load
    skiPassController.fetchSkiPassData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<SkiPassController>(
          builder: (controller) {
            // Show shimmer fullscreen while loading
            if (controller.isLoading) {
              return const ProviderServiceShimmer();
            }

            // After loading ends
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  /// Provider profile
                  ProviderProfile(
                    imageUrl: authController.userModel?.profilePic ?? '',
                    role: "${authController.userModel?.providerType ?? ""} Provider",
                    name: authController.userModel?.fullName ?? "",
                    onTap: () {
                      Get.toNamed(Routes.providerProfileScreen);
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.red,
                      size: 30,
                    ),
                    onIconTap: () => print("Icon tapped!"),
                  ),

                  SizedBox(height: 24.h),

                  /// My service title with Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("My service", style: AppTextStyle.sub_h2_medium_16()),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _createNewService,
                        splashColor: Colors.white24,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.primary_1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 15),
                              SizedBox(width: 4.w),
                              Text(
                                "Add",
                                style: AppTextStyle.p_medium_12(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 17.h),

                  /// Ski Pass List or "No services found"
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        if (controller.errorMessage != null) {
                          return Center(
                            child: Text(
                              controller.errorMessage!,
                              style: AppTextStyle.sub_h3_medium_14(),
                            ),
                          );
                        }

                        if (controller.skiPassList.isEmpty) {
                          return Center(
                            child: Text(
                              "No services found.",
                              style: AppTextStyle.sub_h3_medium_14(),
                            ),
                          );
                        }

                        // List of ski passes
                        return ListView.builder(
                          itemCount: controller.skiPassList.length,
                          itemBuilder: (context, index) {
                            final pass = controller.skiPassList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: MyServiceCard(
                                image: pass.thumbnail,
                                title: pass.title,
                                price: "\$${pass.amount}/Day",
                                rating: pass.averageRating.toDouble(),
                                reviews: pass.reviews.length,
                                location: pass.serviceArea,
                                packageType: pass.skiPassType,
                                onDelete: () => print("Delete ${pass.title}"),
                                onEdit: () => print("Edit ${pass.title}"),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}