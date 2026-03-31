import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/message_details_shimmer.dart';
import 'package:harry_service_app/app/modules/user/massage/controllers/message_details_controller.dart';
import 'package:harry_service_app/app/modules/user/massage/views/review_screen.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../routes/app_routes.dart';

class MassageDetailsScreen extends StatefulWidget {
  const MassageDetailsScreen({super.key});

  @override
  State<MassageDetailsScreen> createState() => _MassageDetailsScreenState();
}

class _MassageDetailsScreenState extends State<MassageDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final String productId;
  final image = Assets.images;
  final icons = Assets.icons;

  late TabController tabController;
  final massageController = Get.find<MassageDetailsController>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    var argument = Get.arguments;
    productId = argument["id"];

    if (productId.isNotEmpty) {
      _fetchDetails();
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    await massageController.fetchMassageDetails(productId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<MassageDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const MassageDetailsShimmer();
          }

          if (controller.massage == null) {
            return Center(
              child: Text(
                "Massage details not available",
                style: AppTextStyle.sub_h3_regular_14(),
              ),
            );
          }

          final massage = controller.massage!;
          final owner = massage.owner;

          return SlidingUpPanel(
            minHeight: size.height * 0.55,
            maxHeight: size.height * 0.95,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            // Persistent Footer
            footer: _buildPersistentFooter(massage, controller),
            body: Stack(
              children: [
                Image.network(
                  massage.thumbnail,
                  height: size.height * 0.5,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300]),
                ),
                Positioned(
                  top: 40.h,
                  left: 10.w,
                  child: CustomBackButton(onTap: () => Get.back()),
                ),
              ],
            ),
            panelBuilder: (sc) => _buildPanelContent(sc, massage, owner),
          );
        },
      ),
    );
  }

  Widget _buildPanelContent(
    ScrollController sc,
    dynamic massage,
    dynamic owner,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Drag Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 60.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header Info (Stays pinned at top of panel while scrolling content)
          ProviderInfo(
            providerName: owner.fullName,
            rating: massage.averageRating.toString(),
            reviewCount: massage.reviews.length,
            image: owner.profileUrl,
            onTapCall: () {
              //TODO : call provider
              makePhoneCall(owner.phoneNumber);
            },
            onTapMessage: () {
              //TODO : message provider

              Get.toNamed(
                Routes.messagingScreen,
                arguments: {
                  'otherUserId': owner.id,
                  'chatId': '',
                  'otherUserName': owner.fullName,
                  'otherUserProfileUrl': owner.profileUrl,
                  'isOnline': false,
                },
              );
            },
          ),
          SizedBox(height: 15.h),

          TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            labelStyle: AppTextStyle.sub_h3_medium_14(),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: const Color(0xffD4AF38),
              borderRadius: BorderRadius.circular(10),
            ),
            tabs: const [
              Tab(text: "About"),
              Tab(text: "Review"),
            ],
          ),
          SizedBox(height: 10.h),

          // Scrollable Content
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // About Tab
                ListView(
                  controller: sc, // Attach Panel ScrollController
                  padding: EdgeInsets.only(bottom: 120.h),
                  children: [_buildAboutContent()],
                ),
                // Review Tab
                ListView(
                  controller: sc, // Attach Panel ScrollController
                  padding: EdgeInsets.only(bottom: 120.h),
                  children: [ReviewScreen(reviewList: massage.reviews)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentFooter(
    dynamic massage,
    MassageDetailsController controller,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xffFDFAF6),
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "\$ ${massage.amount}",
              style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: CustomButton(
              onTap: () {
                Get.toNamed(
                  Routes.bookingRequest,
                  arguments: {
                    "priceByDuration": massage.priceByDuration,
                    "id": productId,
                  },
                );
              },
              text: "Book Now",
              backgroundColor: AppColors.primary_1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    final massage = massageController.massage!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                massage.title,
                style: AppTextStyle.h2_semibold_22(),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "\$ ${massage.amount}",
              style: AppTextStyle.sub_h2_medium_16(color: AppColors.primary_1),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Text(
              "Open : ${massage.openTime}",
              style: AppTextStyle.p_regular_12(color: AppColors.black_3),
            ),
            SizedBox(width: 10.w),
            const CircleAvatar(radius: 3, backgroundColor: Colors.grey),
            SizedBox(width: 10.w),
            Text(
              "Closed : ${massage.closeTime}",
              style: AppTextStyle.p_regular_12(color: AppColors.black_3),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            icons.mapPinSimpleArea.svg(width: 18, height: 18),
            SizedBox(width: 8.w),
            Text(
              "Location : ${massage.serviceArea}",
              style: AppTextStyle.p_regular_12(color: AppColors.black_3),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text("Benefits", style: AppTextStyle.sub_h2_medium_16()),
        SizedBox(height: 8.h),
        Text(
          massage.benefits,
          style: AppTextStyle.p_regular_12(color: AppColors.black_2),
        ),
        SizedBox(height: 20.h),
        Text("Our recommendation", style: AppTextStyle.sub_h1_medium_18()),
        SizedBox(height: 8.h),
        Text(
          massage.ourRecommendations,
          style: AppTextStyle.p_regular_12(color: AppColors.black_2),
        ),
      ],
    );
  }
}
