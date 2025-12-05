import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';
import 'package:harry_service_app/app/core/widgets/my_service_card.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_service_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/pass/controller/delete_controller.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../pass/views/add_pass_screen.dart';
import '../controllers/provider_all_service_controller.dart';
import '../models/provider_resturant_service.dart';
import '../../../user/shared/models/ski_pass_model.dart' hide SkiPass;

class ProviderServiceScreen extends StatefulWidget {
  const ProviderServiceScreen({super.key});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {
  final authController = Get.find<AuthController>();
  final serviceController = Get.put(AllServiceController());


  /// make a category list for add

  /// Navigate based on provider type
  void _createNewService() async {
    final providerType = authController.userModel?.providerType?.toLowerCase() ?? '';

    if (providerType == "ski_pass") {
      /// Navigate to AddPassScreen
      final result = await Get.to(() => const AddPassScreen(), arguments: {"isEdit": false});
      if (result == true) {
        await serviceController.refreshServices();
      }
    } else if (providerType == "restaurant") {
      /// Navigate to AddRestaurantScreen
      final result = await Get.toNamed(Routes.addRestaurantService, arguments: {"isEdit": false});

    } else if (providerType == "transport") {
      final result = await Get.to(() => const AddPassScreen(), arguments: {"isEdit": false});
      if (result == true) {
        await serviceController.refreshServices();
      }
      Get.toNamed(Routes.transportDetails);
    } else if (providerType == "massage") {
      Get.toNamed(Routes.addMessageService);
    } else {
      Get.toNamed(Routes.addMessageService);
    }
  }


  @override
  void initState() {
    super.initState();
    final providerType = authController.userModel!.providerType?.toLowerCase() ?? '';

    String url;

    if (providerType == "ski_pass") {
      url = AppUrls.providerPassService; // example URL for ski pass
    } else if (providerType == "restaurant") {
      url = AppUrls.providerRestaurantService;
    } else {
      url = AppUrls.providerPassService; // fallback
    }

    serviceController.fetchServices(url);
  }

  @override
  Widget build(BuildContext context) {
    final providerType = authController.userModel!.providerType?.toLowerCase() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<AllServiceController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const ProviderServiceShimmer();
            }

            final errorMessage = controller.errorMessage;
            final skiPassList = controller.skiPassList;
            final restaurantList = controller.restaurantServiceList;

            final isSkiPass = providerType == "ski_pass";
            final activeListLength = isSkiPass ? skiPassList.length : restaurantList.length;

            if (errorMessage != null) {
              return Center(
                child: Text(
                  errorMessage,
                  style: AppTextStyle.sub_h3_medium_14(),
                ),
              );
            }

            if (activeListLength == 0) {
              return Center(
                child: Text(
                  "No services found.",
                  style: AppTextStyle.sub_h3_medium_14(),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProviderProfile(
                      imageUrl: authController.userModel?.profilePic ?? '',
                      role: "${authController.userModel?.providerType ?? ""} Provider",
                      name: authController.userModel?.fullName ?? "",
                      onTap: () => Get.toNamed(Routes.providerProfileScreen),
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.red,
                        size: 30,
                      ),
                      onIconTap: () => print("Icon tapped!"),
                    ),
                    SizedBox(height: 24.h),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: activeListLength,
                      itemBuilder: (context, index) {
                        if (isSkiPass) {
                          final pass = skiPassList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MyServiceCard(
                              image: pass.thumbnail,
                              title: pass.title,
                              status: "\$${pass.amount}/Day",
                              rating: pass.averageRating.toDouble(),
                              reviews: pass.reviews.length,
                              location: pass.serviceArea,
                              packageType: pass.skiPassType,
                              onDelete: () async {
                                DeleteDialogService.show(
                                  context: context,
                                  title: "Delete Pass",
                                  message: "Are you sure you want to delete this pass?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.providerPassServiceDelete(pass.id),
                                    );
                                    if (result) {
                                      await serviceController.refreshServices();
                                    } else {
                                      Get.snackbar("Error", deleteController.errorMessage ?? "Delete failed");
                                    }
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.to(() => const AddPassScreen(), arguments: {
                                  "pass": pass,
                                  "isEdit": true,
                                });
                                if (result == true) {
                                  await serviceController.refreshServices();
                                }
                              },
                            ),
                          );
                        } else {
                          final restaurant = restaurantList[index];
                          final items = restaurantList[index];




                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MyServiceCard(

                              image: restaurant.thumbnail,
                              title: restaurant.title,
                              status: restaurant.status,
                              rating: restaurant.averageRating ?? 0.0,
                              reviews: restaurant.reviews.length,
                              location: restaurant.serviceArea,

                              onDelete: () async {
                                DeleteDialogService.show(
                                  context: context,
                                  title: "Delete Restaurant Seat",
                                  message: "Are you sure you want to delete this seat?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.deleteRestaurantUrl(restaurant.sId),
                                    );
                                    if (result) {
                                      await serviceController.refreshServices();
                                    } else {
                                      Get.snackbar("Error", deleteController.errorMessage ?? "Delete failed");
                                    }
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.toNamed(Routes.addRestaurantService, arguments: {
                                  "restaurant": restaurant,
                                  "isEdit": true,
                                });

                                if (result == true) { /// only refresh if actual changes happened
                                  await serviceController.refreshServices();
                                }
                              },

                            ),
                          );
                        }
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
