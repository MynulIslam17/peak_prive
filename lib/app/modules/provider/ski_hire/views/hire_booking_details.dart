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

import '../../../../core/utils/phone_utils.dart';
import '../../../../routes/app_routes.dart';
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
    bookingId = arguments["bookingId"] ?? "";

    if (bookingId.isNotEmpty) {
      itemController
          .fetchBookingById(
        bookingId: bookingId,
        providerType: ProviderType.Ski_Hire,
      )
          .then((_) {
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


  Widget _buildHeader(Size size, String? imageUrl) {
    return Stack(
      children: [
        // Background Image Container
        Container(
          height: size.height * 0.5,
          width: double.infinity,
          color: Colors.grey[300],
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white70,
                ),
              );
            },
          )
              : Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
          ),
        ),
        // Gradient Overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Header Content: Back Button + Title
        Positioned(
          top: 45,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Title
              const Text(
                "Request Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Spacer for balance (or add menu icon here if needed)
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Helper: Back button widget (optional, can inline as above)
  Widget _backButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final screenSize = Size(screenWidth, height);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: GetBuilder<ItemController>(
        builder: (controller) {
          if (controller.isLoading) return const RestaurantDetailsShimmer();

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
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      itemController.fetchBookingById(
                        bookingId: bookingId,
                        providerType: ProviderType.Ski_Hire,
                      );
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          final data = controller.hireItem?.data;
          if (data == null) return const SizedBox.shrink();

          final user = data.user;
          final product = data.product;
          final bookingItems = data.bookingItems;

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: height * 0.99,
            minHeight: height * 0.55,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            panelBuilder: (ScrollController scController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          ModernUserCard(
                            profileUrl: user?.profileUrl,
                            fullName: user?.fullName ?? "Unknown User",
                            serviceArea: product?.serviceArea ?? "N/A",
                            onCallTap: () {

                              //TODO : make call
                              makePhoneCall(data.phoneNumber);

                            },
                            onMessageTap: () {

                               //TODO : make message
                             Get.toNamed(Routes.messagingScreen,
                               arguments: {
                                 'otherUserId':user?.sId,
                                 'chatId': '',
                                 'otherUserName': user?.fullName,
                                 'otherUserProfileUrl': user?.profileUrl,
                                 'isOnline': false,
                               },

                             );

                            },
                          ),
                          const SizedBox(height: 20),
                          if (bookingItems != null && bookingItems.isNotEmpty)
                            _buildItemsSection(bookingItems),
                          const SizedBox(height: 20),
                          PricingSection(
                            extraChargePerHour: product?.extraChargePerHour ?? 0,
                            totalPrice: data.totalPrice ?? 0,
                          ),
                          const SizedBox(height: 20),
                          ContactDetailsSection(
                            address: user?.address ?? "N/A",
                            phoneNumber: user?.phoneNumber ?? "N/A",
                          ),
                          const SizedBox(height: 20),
                          TimeScheduleSection(
                            startDateTime: data.startDateAndTime ?? "",
                            endDateTime: data.endDateAndTime ?? "",
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
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
                                backgroundColor:
                                sController.isPermitted! ? Colors.green : AppColors.primary_1,
                                foregroundColor: Colors.white,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: sController.isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                sController.isPermitted == true
                                    ? "✓ Approved"
                                    : "Approve Booking",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },

            body: _buildHeader(
              screenSize,
              product?.thumbnail ?? "",
            ),
          );
        },
      ),
    );
  }

  // ... (_buildItemsSection remains unchanged)
  Widget _buildItemsSection(List<dynamic> bookingItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rented Items",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bookingItems.length,
            itemBuilder: (context, index) {
              final itemData = bookingItems[index];
              final item = itemData.item;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(11)),
                          child: Image.network(
                            item?.productPhoto ?? "",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 30),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          item?.productName ?? "__",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
    );
  }
}