import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:harry_service_app/app/core/widgets/duration_price_section.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_status_controller.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/constants/text-style.dart';
import '../../ski_hire/controller/booking_item_controller.dart';

class MassageBookingDetails extends StatefulWidget {
  const MassageBookingDetails({super.key});

  @override
  State<MassageBookingDetails> createState() => _MassageBookingDetailsState();
}

class _MassageBookingDetailsState extends State<MassageBookingDetails> {
  late String bookingId;
  final PanelController _panelController = PanelController();
  final itemController = Get.put(ItemController());
  final bookingStatus = Get.put(BookingStatusController());

  @override
  void initState() {
    super.initState();
    bookingId = Get.arguments['bookingId'] ?? '';

    if (bookingId.isNotEmpty) {
      itemController.fetchBookingById(
        bookingId: bookingId,
        providerType: ProviderType.Massage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: GetBuilder<ItemController>(
        builder: (controller) {
          final bookingData = controller.massageItem?.data;

          // Full-screen loader
          if (controller.isLoading) {
            return const RestaurantDetailsShimmer();
          }

          // No data
          if (bookingData == null) {
            return const Center(child: Text('No Data Found'));
          }

          final user = bookingData.user;

          return Stack(
            children: [
              SlidingUpPanel(
                controller: _panelController,
                maxHeight: size.height * 0.75,
                minHeight: size.height * 0.55,
                parallaxEnabled: true,
                parallaxOffset: 0.2,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
                panelBuilder: (ScrollController sc) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            controller: sc,
                            children: [
                              Center(
                                child: Container(
                                  height: 5,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "User Info",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (user != null)
                                ModernUserCard(
                                  fullName: user.fullName,
                                  serviceArea: user.address,
                                  profileUrl: user.profileUrl,
                                ),
                              const SizedBox(height: 24),
                              Text(
                                "Booking Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildDetailCard(
                                label: "Massage Name",
                                value: bookingData.product?.title ?? "N/A",
                                icon: Icons.title_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              DurationAndPriceSection(
                                duration: bookingData.duration ?? "N/A",
                                price: bookingData.totalPrice ?? 0,
                              ),
                              const SizedBox(height: 12),
                              buildDetailCard(
                                label: "Location",
                                value: bookingData.product?.serviceArea ?? "N/A",
                                icon: Icons.location_city,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Date & Time",
                                style: AppTextStyle.sub_h3_medium_14(),
                              ),
                              const SizedBox(height: 12),
                              buildDetailCard(
                                label: "Booking Date",
                                value: "${formatDateTime(bookingData.date)} - ${bookingData.time ?? "N/A"}",
                                icon: Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                        // Inside the SafeArea button section:
                        SafeArea(
                          child: GetBuilder<BookingStatusController>(builder: (controller) {
                            final permitted = controller.isPermitted ?? false;

                            return ElevatedButton(
                              onPressed: () {
                                if (!permitted) {
                                  // Call controller method to approve booking
                                  controller.changeStatus(
                                    apiUrl: AppUrls.changeBookingStatus(bookingId),
                                    status: true,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor: AppColors.primary_1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primary_1.withOpacity(0.4),
                              ),
                              child: Text(
                                permitted ? "Approved" : "Approve",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }),
                        )

                      ],
                    ),
                  );
                },
                body: SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * 0.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1a1a2e).withOpacity(0.5),
                              const Color(0xFF16213e).withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: bookingData.product?.thumbnail != null
                            ? Image.network(
                          bookingData.product!.thumbnail!,
                          fit: BoxFit.cover,
                        )
                            : Container(color: Colors.grey[300]),
                      ),
                      Positioned(
                        top: 45,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Text(
                              "Request Details",
                              style: AppTextStyle.h2_semibold_22(color: Colors.white),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

  String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(dateString).toLocal();
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }
}
