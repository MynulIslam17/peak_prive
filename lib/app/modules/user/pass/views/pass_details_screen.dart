import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/available_service.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../core/widgets/shimmer/pass_details_skeleton.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/pass_details_controller.dart';

class PassDetailsScreen extends StatefulWidget {
  const PassDetailsScreen({super.key});

  @override
  State<PassDetailsScreen> createState() => _PassDetailsScreenState();
}

class _PassDetailsScreenState extends State<PassDetailsScreen> {
  late final String id;
  final controller = Get.find<PassDetailsController>();
  final image = Assets.images;

  @override
  void initState() {
    super.initState();
    id = (Get.arguments as Map<String, dynamic>)['id'];
    controller.fetchPass(id);
  }

  @override
  Widget build(BuildContext context) {
    PanelController panelController=PanelController();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<PassDetailsController>(
        builder: (_) {
          if (controller.fetchProgress) {
            return const PassDetailsSkeleton();
          }

          final pass = controller.passDetails;
          if (pass == null) {
            return const Center(child: Text("No details available"));
          }

          return SlidingUpPanel(
            controller: panelController,
            maxHeight: size.height * 0.75,
            minHeight: size.height * 0.55,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            panelBuilder: (scrollController) =>
                _SlidingContent(pass, scrollController),
            body: SafeArea(
              child: Stack(
                children: [
                  // Background Image
                  Image.network(
                    pass.thumbnail,
                    height: size.height * 0.6,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
              
                  // Back Button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomBackButton(onTap: Get.back),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class _SlidingContent extends StatelessWidget {
  final dynamic pass;
  final ScrollController scrollController;

  const _SlidingContent(this.pass, this.scrollController);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(

        children: [
          // Drag Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProviderInfo(
                    image: pass.owner.profileUrl,
                    providerName: pass.owner.email,
                    rating: pass.averageRating.toString(),
                    onTapCall: () {},
                    onTapMessage: () {},
                  ),

                  SizedBox(height: 16.h),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pass.services.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 6.h,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (_, index) {
                      final service = pass.services[index];
                      return AvailableService(
                        serviceType: service.title,
                        serviceCount: service.description,
                      );
                    },
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    pass.description,
                    style: AppTextStyle.p_regular_12()
                        .copyWith(color: AppColors.black_2),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),

          // Bottom Action
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Row(
              children: [
                Text(
                  "\$${pass.amount}",
                  style: AppTextStyle.sub_h1_medium_18(
                    color: AppColors.primary_1,
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: CustomButton(
                    text: "Book Ski Pass",
                    backgroundColor: AppColors.primary_1,
                    onTap: () {
                      Get.toNamed(
                        Routes.passInformation,
                        arguments: {"id": pass.id},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
