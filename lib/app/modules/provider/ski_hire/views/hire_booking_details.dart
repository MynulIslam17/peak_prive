import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/build_schedule_section.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:harry_service_app/app/core/widgets/contact_details_section.dart';
import 'package:harry_service_app/app/core/widgets/price_section.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';

import '../controller/booking_item_controller.dart';
import '../controller/booking_status_controller.dart';

class HireBookingDetails extends StatefulWidget {
  const HireBookingDetails({super.key});

  @override
  State<HireBookingDetails> createState() => _HireBookingDetailsState();
}

class _HireBookingDetailsState extends State<HireBookingDetails>
    with SingleTickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  final ItemController itemController = Get.put(ItemController());
  final BookingStatusController statusController = Get.put(
    BookingStatusController(),
  );

  late AnimationController _animationController;
  late final String bookingId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final arguments = Get.arguments;
    bookingId = arguments["bookingId"];

    if (bookingId.isNotEmpty) {
      itemController.fetchBookingById(bookingId).then((_) {
        if (itemController.hireItem != null) {
          statusController.setInitialStatus(
            itemController.hireItem!.data!.isPermitted ?? false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: GetBuilder<ItemController>(
        builder: (controller) {
          if (controller.isLoading) return RestaurantDetailsShimmer();

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage!),
                ],
              ),
            );
          }

          final user = controller.user;
          final product = controller.product;
          final bookingItems = controller.bookingItems;
          final data = controller.hireItem!.data;

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: height * 0.75,
            minHeight: height * 0.55,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius: BorderRadius.circular(28),
            panelBuilder: (ScrollController scController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: scController,
                          children: [
                            ModernUserCard(
                              profileUrl: user!.profileUrl,
                              fullName: user.fullName,
                              serviceArea: product!.serviceArea,
                              onCallTap: () {},
                              onMessageTap: () {},
                            ),
                            const SizedBox(height: 20),
                            if (bookingItems != null && bookingItems.isNotEmpty)
                              _buildItemsSection(bookingItems),
                            const SizedBox(height: 20),
                            PricingSection(
                              extraChargePerHour:
                                  product.extraChargePerHour ?? 0,
                              totalPrice: data!.totalPrice ?? 0,
                            ),
                            const SizedBox(height: 20),
                            ContactDetailsSection(
                              address: user.address ?? "N/A",
                              phoneNumber: user.phoneNumber ?? "N/A",
                            ),
                            const SizedBox(height: 20),
                            TimeScheduleSection(
                              startDateTime: data.startDateAndTime!,
                              endDateTime: data.endDateAndTime!,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: GetBuilder<BookingStatusController>(
                            builder: (sController) => OutlinedButton(
                              onPressed: () async {
                                if (statusController.isPermitted == false) {
                                  await statusController.changeStatus(
                                    apiUrl: AppUrls.changeBookingStatus(
                                      data.sId!,
                                    ),
                                    status: true,
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: sController.isPermitted! ? Colors.green :  AppColors.primary_1,
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: sController.isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      sController.isPermitted == true
                                          ? "Approved"
                                          : "Approve",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            body: _buildModernHeader(height, product),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(double height, product) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1a1a2e).withOpacity(0.7),
                    const Color(0xFF16213e).withOpacity(0.7),
                  ],
                ),
              ),
              child: Image.network(product?.thumbnail ?? "", fit: BoxFit.cover),
            ),
            Positioned(
              top: 66,
              child: Text(
                "Request Details",
                style: AppTextStyle.h2_semibold_22(color: Colors.white),
              ),
            ),
            Positioned(
              top: 66,
              left: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsSection(bookingItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Items",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bookingItems.length,
            itemBuilder: (context, index) {
              final item = bookingItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            item.item?.productPhoto ?? "",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            item.item?.productName ?? "Item",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
