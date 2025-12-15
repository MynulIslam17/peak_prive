import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/widgets/seat_amount_section.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/details_simmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_status_controller.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/build_user_card.dart';
import '../../ski_hire/controller/booking_item_controller.dart';

class RestaurantBookingDetails extends StatefulWidget {
  const RestaurantBookingDetails({super.key});

  @override
  State<RestaurantBookingDetails> createState() =>
      _RestaurantBookingDetailsState();
}

class _RestaurantBookingDetailsState extends State<RestaurantBookingDetails> {
  final PanelController _panelController = PanelController();
  final ItemController itemController = Get.put(ItemController());
  final statusController  = Get.put(BookingStatusController());

  late final String bookingId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    bookingId = args["bookingId"];
    if (bookingId.isNotEmpty) {

      itemController.fetchBookingById(
        bookingId: bookingId,
        providerType: ProviderType.Restaurant,
      ).then((_){
        if(itemController.restaurantItem!=null){
          itemController.restaurantItem!.data!.isPermitted ?? false;
        }

      });
    } else {
      debugPrint(" bookingId not found in Get.arguments");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ItemController>(
        builder: (c) {
          ///  Loading
          if (c.isLoading) {
            return const Center(child: RestaurantDetailsShimmer());
          }

          final data = c.restaurantItem?.data;
          if (data == null) {
            return const Center(child: Text("No booking data found"));
          }

          final user = data.user;
          final product = data.product;
          final slot = (data.slots != null && data.slots!.isNotEmpty)
              ? data.slots!.first
              : null;

          final seatCount = (data.bookingItems != null &&
              data.bookingItems!.isNotEmpty)
              ? data.bookingItems!.first.quantity.toString()
              : "0";

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: size.height * 0.75,
            minHeight: size.height * 0.55,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),

            /// PANEL CONTENT
            panelBuilder: (ScrollController sc) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: sc,
                        children: [
                          // Drag handle
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
                          const SizedBox(height: 20),

                          // User card
                          ModernUserCard(
                            profileUrl: user?.profileUrl ?? "",
                            fullName: user?.fullName ?? "N/A",
                            serviceArea: product?.serviceArea ?? "N/A",
                            onCallTap: () {},
                            onMessageTap: () {},
                          ),
                          const SizedBox(height: 20),

                          // Seat & Amount
                          SeatAndAmountSection(
                            seatType: "Seat",
                            totalAmount: data.totalPrice ?? 0,
                          ),
                          const SizedBox(height: 20),

                          // Seat Details
                          Text(
                            "Seat Details",
                            style: AppTextStyle.sub_h3_medium_14(),
                          ),
                          const SizedBox(height: 10),

                          buildDetailCard(
                            label: "Seat Count",
                            value: seatCount,
                            icon: Icons.event_seat,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 10),

                          buildDetailCard(
                            label: "Booking Slot",
                            value: slot != null
                                ? "${slot.startTime} - ${slot.endTime}"
                                : "N/A",
                            icon: Icons.access_time,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 10),

                          buildDetailCard(
                            label: "Location",
                            value: product?.serviceArea ?? "N/A",
                            icon: Icons.location_city,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 20),

                          // Booking Date
                          Text(
                            "Date & Time",
                            style: AppTextStyle.sub_h3_medium_14(),
                          ),
                          const SizedBox(height: 10),
                          buildDetailCard(
                            label: "Booking Date",
                            value: data.date != null
                                ? formatDateTime(data.date)
                                : "N/A",
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),


                    // Approve button
                    SafeArea(
                      child: GetBuilder<BookingStatusController>(
                        builder: (statusController) {
                          final isLoading = statusController.isLoading;
                          final approved = itemController.restaurantItem?.data?.isPermitted ?? false;

                          return SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: approved
                                  ? null
                                  : () async {
                                // Set loading
                                statusController.setLoading(true);

                                // Call API to approve
                                await statusController.changeStatus(
                                  apiUrl: AppUrls.changeBookingStatus(bookingId),
                                  status: true,
                                );

                                // Update local model
                                itemController.restaurantItem?.data?.isPermitted = true;

                                // Stop loading
                                statusController.setLoading(false);

                                // Refresh button UI
                                statusController.update();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: approved ? Colors.green : AppColors.primary_1,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text(
                                approved ? "✓ Approved" : "Approve",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
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

            /// HEADER
            body: SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    height: size.height * 0.5,
                    width: double.infinity,
                    child: Image.network(
                      product?.thumbnail ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Request Details",
                        style: AppTextStyle.h2_semibold_22(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
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
            ),
          );
        },
      ),
    );
  }

  /// Reusable detail card
  Widget buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }




  String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";

    try {
      // Parse the string to DateTime
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Format the DateTime
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }








}
