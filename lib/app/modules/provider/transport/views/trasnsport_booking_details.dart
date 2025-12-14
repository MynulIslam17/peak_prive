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
            maxHeight: size.height * 0.75,
            minHeight: size.height * 0.55,
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
                              fullName: user.fullName,
                              serviceArea: user.address,
                              profileUrl: user.profileUrl,
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
                                  extraChargePerHour:
                                  product?.extraChargePerHours ?? "0",
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
                              onPressed: ()async{

                                if(!isPermitted){

                                  await statusController.changeStatus(
                                    apiUrl: AppUrls.changeBookingStatus(
                                      bookingId,
                                    ),
                                    status: true,
                                  );

                                }


                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:statusCtrl.isPermitted! ? Colors.green :  AppColors.primary_1 ,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: statusCtrl.isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)) : Text(
                                statusCtrl.isPermitted == true
                                    ? "Approved"
                                    : "Approve",
                              )
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

  /// HEADER
  Widget _buildHeader(Size size, String? imageUrl) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            height: size.height * 0.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
            ),
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const SizedBox(),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: Get.back,
              child: const CircleAvatar(
                backgroundColor: Colors.black38,
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Request Details",
                style: AppTextStyle.h2_semibold_22(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// UI HELPERS
  Widget _sectionTitle(String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style:
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
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
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return "N/A";
    return DateFormat('dd MMM yyyy, hh:mm a')
        .format(DateTime.parse(date).toLocal());
  }







  String calculateDuration(String? start, String? end) {
    if (start == null || end == null) return "N/A";

    try {
      DateTime startDate = DateTime.parse(start).toLocal();
      DateTime endDate = DateTime.parse(end).toLocal();

      Duration diff = endDate.difference(startDate);

      if (diff.isNegative) {
        // Handle if endDate is before startDate
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
