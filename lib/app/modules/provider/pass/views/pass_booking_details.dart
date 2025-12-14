import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:harry_service_app/app/core/widgets/seat_amount_section.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_item_controller.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_status_controller.dart';
import '../../../../core/constants/api_urls.dart';

class PassBookingDetails extends StatefulWidget {
  const PassBookingDetails({super.key});

  @override
  State<PassBookingDetails> createState() => _PassBookingDetailsState();
}

class _PassBookingDetailsState extends State<PassBookingDetails> {
  final PanelController _panelController = PanelController();

  final itemController = Get.put(ItemController());
  final bookingStatus = Get.put(BookingStatusController());

  late final String bookingId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    bookingId = args["bookingId"] ?? "";

    if (bookingId.isNotEmpty) {
      itemController.fetchBookingById(
        bookingId: bookingId,
        providerType: ProviderType.Ski_Pass,
      );
    } else {
      debugPrint("BookingId not found in Get.arguments");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: GetBuilder<ItemController>(builder: (controller) {
        if (controller.isLoading) {
          return const RestaurantDetailsShimmer();
        }

        if (controller.passItem?.data == null) {
          return const Center(child: Text("Data not found"));
        }

        // Extract values from the response
        final data = controller.passItem!.data!;
        final user = data.user;
        final product = data.product;

        final String userName = user?.fullName ?? "N/A";
        final String userProfile = user?.profileUrl ?? "";
        final String userAddress = user?.address ?? "N/A";

        final String passType = product?.skiPassType ?? "N/A";
        final int passAmount = product?.amount ?? 0;
        final int personCount = data.personCount ?? 0;
        final String location = product?.serviceArea ?? "N/A";
        final String date = formatDateTime(data.date);
        final bool isPermitted = data.isPermitted ?? false;

        return SlidingUpPanel(
          controller: _panelController,
          maxHeight: size.height * 0.75,
          minHeight: size.height * 0.55,
          parallaxEnabled: true,
          parallaxOffset: 0.2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          panelBuilder: (ScrollController sc) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  _dragHandle(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      controller: sc,
                      children: [
                        ModernUserCard(
                          fullName: userName,
                          profileUrl: userProfile,
                          serviceArea: userAddress,
                          onCallTap: () {},
                          onMessageTap: () {},
                        ),
                        const SizedBox(height: 16),
                        Text("Pass Details", style: AppTextStyle.sub_h3_medium_14()),
                        PassTypeSection(passType: passType, totalAmount: passAmount),
                        const SizedBox(height: 16),
                        Text("Booking Details", style: AppTextStyle.sub_h3_medium_14()),
                        const SizedBox(height: 16),
                        buildDetailCard(
                          label: "Person Count",
                          value: personCount.toString(),
                          icon: Icons.person,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        buildDetailCard(
                          label: "Location",
                          value: location,
                          icon: Icons.location_city,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text("Date & Time", style: AppTextStyle.sub_h3_medium_14()),
                        const SizedBox(height: 16),
                        buildDetailCard(
                          label: "Date",
                          value: date,
                          icon: Icons.calendar_month,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SafeArea(
                    child: SizedBox(
                      height: 60,
                      child: GetBuilder<BookingStatusController>(
                        builder: (sc) {

                          final bool isPermitted = sc?.isPermitted ?? false;
                          final bool isLoading = sc.isLoading ;

                          return ElevatedButton(
                            onPressed: () {
                              if (!isPermitted && !isLoading) {
                                sc.changeStatus(
                                  apiUrl: AppUrls.changeBookingStatus(bookingId),
                                  status: true,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: isPermitted ? Colors.green : AppColors.primary_1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            )
                                : Text(
                              isPermitted ? "Approved" : "Approve",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
          body: SafeArea(child: _buildHeader(size, product?.thumbnail)),
        );
      }),
    );
  }

  /// header with image
  Widget _buildHeader(Size size, String? imageUrl) {
    return Stack(
      children: [
        Container(
          height: size.height * 0.5,
          width: double.infinity,
          color: Colors.grey[300],
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Container(color: Colors.grey[300]),
        ),
        Positioned(
          top: 45,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _backButton(),
              const Text(
                "Request Details",
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        height: 5,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
