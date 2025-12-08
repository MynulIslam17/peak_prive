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
import 'package:harry_service_app/app/modules/provider/shared/models/provider_massage_service_model.dart';

class ProviderServiceScreen extends StatefulWidget {
  const ProviderServiceScreen({super.key});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {
  final authController = Get.find<AuthController>();
  final serviceController = Get.put(AllServiceController());

  void _createNewService() async {
    final providerType = authController.userModel?.providerType ?? '';

    if (providerType == "Ski_Pass") {
      final result = await Get.to(() => const AddPassScreen(), arguments: {"isEdit": false});
      if (result == true) await serviceController.refreshServices();
    } else if (providerType == "Restaurant") {
      final result = await Get.toNamed(Routes.addRestaurantService, arguments: {"isEdit": false});
      if (result == true) await serviceController.refreshServices();
    } else if (providerType == "Massage") {
      final result = await Get.toNamed(Routes.addMessageService, arguments: {"isEdit": false});
      if (result == true) await serviceController.refreshServices();
    } else if(providerType=="Transport") {
      final result = await Get.toNamed(Routes.addTransportService, arguments: {"isEdit": false});
      if (result == true) await serviceController.refreshServices();
    }else{

    }
  }

  @override
  void initState() {
    super.initState();
    final providerType = authController.userModel?.providerType ?? "";
    String url;
    if (providerType == "Ski_Pass") {
      url = AppUrls.providerPassService;
    } else if (providerType == "Restaurant") {
      url = AppUrls.providerRestaurantService;
    } else if (providerType == "Massage") {
      url = AppUrls.providerMassageService;
    } else if(providerType=="Transport") {
      url = AppUrls.transportServiceUrl();
    }else{
      url = AppUrls.transportCategoryUrl;
    }
    serviceController.fetchServices(url);
  }

  @override
  Widget build(BuildContext context) {
    final providerType = authController.userModel?.providerType ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<AllServiceController>(
          builder: (controller) {
            if (controller.isLoading) return const ProviderServiceShimmer();

            final errorMessage = controller.errorMessage;
            if (errorMessage != null) {
              return Center(child: Text(errorMessage, style: AppTextStyle.sub_h3_medium_14()));
            }

            List<dynamic> activeList = [];
            if (providerType == "Ski_Pass") activeList = controller.skiPassList;
            else if (providerType == "Restaurant") activeList = controller.restaurantServiceList;
            else if (providerType == "Massage") activeList = controller.massageServiceList;
            else if (providerType == "Transport") activeList = controller.transportServiceList;

            if (activeList.isEmpty) {
              return Center(child: Text("No services found.", style: AppTextStyle.sub_h3_medium_14()));
            }

            return RefreshIndicator(
                color: AppColors.primary_1,
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProviderProfile(
                      imageUrl: authController.userModel?.profilePic ?? '',
                      role: "${authController.userModel?.providerType ?? ""} Provider",
                      name: authController.userModel?.fullName ?? "",
                      onTap: () => Get.toNamed(Routes.providerProfileScreen),
                      icon: const Icon(Icons.notifications, color: Colors.red, size: 30),
                      onIconTap: () => print("Icon tapped!"),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("My service (${activeList.length})", style: AppTextStyle.sub_h2_medium_16()),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _createNewService,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: AppColors.primary_1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 15),
                                SizedBox(width: 4.w),
                                Text("Add", style: AppTextStyle.p_medium_12(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 17.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeList.length,
                      itemBuilder: (context, index) {
                        if (providerType == "Ski_Pass") {
                          final pass = controller.skiPassList[index];
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
                                  message: "Are you sure?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.providerPassServiceDelete(pass.id),
                                    );
                                    if (result) serviceController.removeItemFromList(pass.id, providerType);
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.to(() => const AddPassScreen(),
                                    arguments: {"pass": pass, "isEdit": true});
                                if (result == true) await serviceController.refreshServices();
                              },
                            ),
                          );
                        }

                        if (providerType == "Restaurant") {
                          final restaurant = controller.restaurantServiceList[index];
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
                                  message: "Are you sure?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.deleteRestaurantUrl(restaurant.sId),
                                    );
                                    if (result) serviceController.removeItemFromList(restaurant.sId!, providerType);
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.toNamed(
                                  Routes.addRestaurantService,
                                  arguments: {"restaurant": restaurant, "isEdit": true},
                                );
                                if (result == true) await serviceController.refreshServices();
                              },
                            ),
                          );
                        }

                        if (providerType == "Massage") {
                          final massage = controller.massageServiceList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MyServiceCard(
                              image: massage.thumbnail ?? "",
                              title: massage.title ?? "",
                              status: "\$${massage.amount.toString()}",
                              rating: massage.averageRating ?? 0.0,
                              reviews: massage.reviews?.length ?? 0,
                              location: massage.serviceArea ?? "N/A",
                              onDelete: () async {
                                DeleteDialogService.show(
                                  context: context,
                                  title: "Delete Massage Service",
                                  message: "Are you sure?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.deleteMassageServiceUrl(massage.sId!),
                                    );
                                    if (result) serviceController.removeItemFromList(massage.sId!, providerType);
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.toNamed(
                                  Routes.addMessageService,
                                  arguments: {
                                    "massage": massage,
                                    "isEdit": true,

                                    },
                                );
                                if (result == true) await serviceController.refreshServices();
                              },
                            ),
                          );
                        }

                        if(providerType=="Transport"){
                          final transport=controller.transportServiceList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MyServiceCard(
                              image: transport.thumbnail ?? "",
                              title: transport.title ?? "",
                              status: "\$${transport.amount.toString()}",
                              rating: transport.averageRating!.toDouble()  ,
                              reviews: transport.reviews?.length ?? 0,
                              location: transport.serviceArea ?? "N/A",
                              onDelete: () async {
                                DeleteDialogService.show(
                                  context: context,
                                  title: "Delete Massage Service",
                                  message: "Are you sure?",
                                  onDelete: () async {
                                    final deleteController = Get.put(DeleteController());
                                    final result = await deleteController.deleteItem(
                                      url: AppUrls.deleteTransportUrl(transport.sId!),
                                    );
                                    if (result) serviceController.removeItemFromList(transport.sId!, providerType);
                                    return result;
                                  },
                                );
                              },
                              onEdit: () async {
                                final result = await Get.toNamed(
                                  Routes.addMessageService,
                                  arguments: {
                                    "massage": transport,
                                    "isEdit": true,

                                  },
                                );
                                if (result == true) await serviceController.refreshServices();
                              },
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ), onRefresh: ()async{
              await serviceController.refreshServices(

              );


            }
            );
          },
        ),
      ),
    );
  }
}
