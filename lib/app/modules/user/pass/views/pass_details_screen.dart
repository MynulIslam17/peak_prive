import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/appText.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_details_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/available_service.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../routes/app_routes.dart';

class PassDetailsScreen extends StatefulWidget {
  const PassDetailsScreen({super.key});

  @override
  State<PassDetailsScreen> createState() => _PassDetailsScreenState();
}

class _PassDetailsScreenState extends State<PassDetailsScreen> {
  late final String id;

  /// find the details controller
  final detailsController = Get.find<PassDetailsController>();
  final image = Assets.images;

  @override
  void initState() {
    super.initState();

    /// Get the product ID from arguments
    var argument = Get.arguments as Map<String, dynamic>;
    id = argument["id"];

    /// Fetch pass details
    _fetchData();
  }

  /// calls api method
  void _fetchData() async {
    bool success = await detailsController.fetchPass(id);
    if (!success) {
      Get.snackbar(
        "Error",
        detailsController.errorMessage ?? "Failed to fetch details",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<PassDetailsController>(
        builder: (controller) {
          if (controller.fetchProgress) {
            /// Show loading indicator while fetching
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          if (controller.passDetails == null) {
            /// Show error or empty state
            return Center(
              child: Text(controller.errorMessage ?? "No details available"),
            );
          }

          final pass = controller.passDetails!;

          /// accessing the full passDetails
          final owner = pass.owner;

          ///then from that gets owner model

          return SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // Thumbnail
                Image.network(
                  pass.thumbnail,
                  height: size.height * 0.48,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                ///  Overlap card
                Positioned(
                  top: size.height * 0.4,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: size.width,
                    height: size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Drag line
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: image.line.image(width: 87.w, height: 9.h),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Scrollable content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Provider info
                                  ProviderInfo(
                                    providerName: owner.email,
                                    rating: pass.averageRating.toString(),
                                    onTapCall: () {},
                                    onTapMessage: () {},
                                  ),

                                  /// Services - exactly 3 items per row
                                  GridView.builder(
                                    shrinkWrap:
                                        true,
                                    physics:
                                        NeverScrollableScrollPhysics(),
                                    itemCount: pass
                                        .services
                                        .length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing:
                                              12.w,
                                          mainAxisSpacing:
                                              6.h,
                                          childAspectRatio:
                                              1.3,
                                        ),
                                    itemBuilder: (context, index) {
                                      final service = pass.services[index];
                                      return AvailableService(
                                        serviceType: service.title,
                                        serviceCount: service.description,
                                      );
                                    },
                                  ),

                                  SizedBox(height: 14.h),

                                  // Description
                                  Text(
                                    pass.description,
                                    style: AppTextStyle.p_regular_12().copyWith(
                                      color: AppColors.black_2,
                                    ),
                                  ),

                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),

                          /// Bottom price and button
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            child: Row(
                              children: [
                                Text(
                                  "\$${pass.amount}",
                                  style: AppTextStyle.sub_h1_medium_18(
                                    color: AppColors.primary_1,
                                  ),
                                ),
                                SizedBox(width: 30.w),
                                Expanded(
                                  child: CustomButton(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.passInformation,
                                        /// pass the product id again
                                        arguments: {"id": id},
                                      );
                                    },
                                    text: "Book Ski Pass",
                                    backgroundColor: AppColors.primary_1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Back button
                CustomBackButton(onTap: () => Get.back()),
              ],
            ),
          );
        },
      ),
    );
  }
}
