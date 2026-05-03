import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:harry_service_app/app/core/widgets/duration_price_section.dart';
import 'package:harry_service_app/app/core/widgets/overtime_extracharge.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';

import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_status_controller.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../routes/app_routes.dart';
import '../../ski_hire/controller/booking_item_controller.dart';

class TransportBookingDetails extends StatefulWidget {
  const TransportBookingDetails({super.key});

  @override
  State<TransportBookingDetails> createState() =>
      _TransportBookingDetailsState();
}

class _TransportBookingDetailsState extends State<TransportBookingDetails> {
  final PanelController _panelController = PanelController();

  /// Controllers (USING Get.put)
  final ItemController itemController = Get.put(ItemController());
  final BookingStatusController statusController =
  Get.put(BookingStatusController());

  late final String bookingId;

  @override
  void initState() {
    super.initState();

    bookingId = Get.arguments?['bookingId'] ?? '';

    if (bookingId.isNotEmpty) {
      itemController
          .fetchBookingById(
        bookingId: bookingId,
        providerType: ProviderType.Transport,
      )
          .then((_) {
        final data = itemController.transportItem?.data;
        if (data != null) {
          statusController.setInitialStatus(data.isPermitted ?? false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ItemController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const RestaurantDetailsShimmer();
          }

          final transport = controller.transportItem?.data;
          if (transport == null) {
            return const Center(child: Text("No data found"));
          }

          final user = transport.user;
          final product = transport.product;
          final isPermitted = transport.isPermitted ?? false;

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: size.height * 0.99,
            minHeight: size.height * 0.55,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
            panelBuilder: (sc) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: sc,
                        children: [
                          Center(
                            child: Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// USER INFO
                          if (user != null)
                            ModernUserCard(
                              fullName: user.fullName ?? "N/A",
                              serviceArea: user.address ?? "N/A",
                              profileUrl: user.profileUrl ?? "N/A",
                              onCallTap: (){
                                //TODO : make call
                                makePhoneCall(
                                  transport.phoneNumber
                                );
                              },
                              onMessageTap: (){
                                //TODO : make message
                                Get.toNamed(Routes.messagingScreen,
                                  arguments: {
                                    'otherUserId':user?.id,
                                    'chatId': '',
                                    'otherUserName': user?.fullName,
                                    'otherUserProfileUrl': user?.profileUrl,
                                    'isOnline': false,
                                  },
                                );
                              },
                            ),

                          const SizedBox(height: 24),

                          _sectionTitle("Title"),
                          buildDetailCard(
                            label: "Tittle",
                            value: product?.title ?? "N/A",
                            icon: Icons.directions_car,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 24),

                          _sectionTitle("Booking Item"),
                          buildDetailCard(
                            label: "Vehicle",
                            value: product?.category!.name ?? "N/A",
                            icon: Icons.directions_car,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 16),

                          _sectionTitle("Base Time"),
                          DurationAndPriceSection(
                            duration: calculateDuration(
                              controller.transportItem!.data!.startDateAndTime,
                              controller.transportItem!.data!.endDateAndTime,
                            ),
                            price: transport.totalPrice ?? 0,
                          ),

                          const SizedBox(height: 16),

                          _sectionTitle("Booking Status"),
                          buildDetailCard(
                            label: "Status",
                            value: transport.bookingStatus ?? "N/A",
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),

                          const SizedBox(height: 16),

                          /// if  over time then it will show
                          if (transport.timeLabel != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  "Over Time",
                                  color: Colors.red,
                                ),
                                OvertimeAndChargeSection(
                                  timeLabel: transport.timeLabel!,
                                  overtimeAmount:
                                  transport.overTimeAmount ?? 0,
                                  extraChargePerHour:product?.extraChargePerHours,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    /// APPROVE BUTTON
                    SafeArea(
                      child: GetBuilder<BookingStatusController>(
                        builder: (statusCtrl) {
                          return SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!isPermitted) {
                                  await statusController.changeStatus(
                                    apiUrl: AppUrls.changeBookingStatus(
                                      bookingId,
                                    ),
                                    status: true,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: statusCtrl.isPermitted!
                                    ? Colors.green
                                    : AppColors.primary_1,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: statusCtrl.isLoading
                                  ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                statusCtrl.isPermitted == true
                                    ? "✓ Approved"
                                    : "Approve",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            body: _buildHeader(size, product?.thumbnail),
          );
        },
      ),
    );
  }

  /// ✅ UPDATED HEADER - Simple with image, back button & title
  Widget _buildHeader(Size size, String? imageUrl) {
    return Stack(
      children: [
        Container(
          height: size.height * 0.5,
          width: double.infinity,
          color: Colors.grey[300],
          child: imageUrl != null
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey[300]),
          )
              : Container(color: Colors.grey[300]),
        ),
        Positioned(
          top: 45, // Adjusted based on typical status bar height + padding
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _backButton(),
              const Text(
                "Request Details",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      )
                    ]),
              ),
              const SizedBox(width: 48), // Spacer to balance the back button
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Helper: Back button widget
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

  /// UI HELPERS
  Widget _sectionTitle(String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String calculateDuration(String? start, String? end) {
    if (start == null || end == null) return "N/A";

    try {
      DateTime startDate = DateTime.parse(start).toLocal();
      DateTime endDate = DateTime.parse(end).toLocal();

      Duration diff = endDate.difference(startDate);

      if (diff.isNegative) {
        diff = diff.abs();
      }

      int days = diff.inDays;
      int hours = diff.inHours.remainder(24);
      int minutes = diff.inMinutes.remainder(60);

      String result = "";
      if (days > 0) result += "${days}d ";
      if (hours > 0) result += "${hours}h ";
      if (minutes > 0) result += "${minutes}m";

      return result.trim().isEmpty ? "0h" : result.trim();
    } catch (e) {
      return "Invalid date";
    }
  }
}