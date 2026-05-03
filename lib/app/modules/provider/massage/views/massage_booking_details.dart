import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:harry_service_app/app/core/widgets/duration_price_section.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/hire_service_model.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/controller/booking_status_controller.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../routes/app_routes.dart';
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
  final bookingStatusController = Get.put(BookingStatusController());

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
          final massage = controller.massageItem;
          final data = massage?.data;

          // Full-screen loader on first fetch
          if (controller.isLoading && massage == null) {
            return const RestaurantDetailsShimmer();
          }

          // No data
          if (data == null) {
            return const Center(child: Text('No Data Found'));
          }

          final user = data.user;
          final imageUrl = data.product?.thumbnail;

          return Stack(
            children: [
              SlidingUpPanel(
                controller: _panelController,
                maxHeight: size.height * 0.99,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
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
                              // Drag handle
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

                              if (user != null)
                                ModernUserCard(
                                  fullName: user.fullName,
                                  serviceArea: user.address,
                                  profileUrl: user.profileUrl,
                                  onMessageTap: () {
                                    //TODO : make message
                                    Get.toNamed(Routes.messagingScreen,
                                      arguments: {
                                        'otherUserId':user.id,
                                        'chatId': '',
                                        'otherUserName': user.fullName,
                                        'otherUserProfileUrl': user.profileUrl,
                                        'isOnline': false,
                                      },
                                    );

                                  },
                                  onCallTap: () {

                                    //TODO : make call
                                    makePhoneCall(data.phoneNumber);
                                  },
                                ),
                              const SizedBox(height: 24),

                              // Booking Information Section
                              Text(
                                "Title",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildDetailCard(
                                label: "Massage Name",
                                value: data.product?.title ?? "N/A",
                                icon: Icons.title_rounded,
                                color: Colors.orange,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "Price",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DurationAndPriceSection(
                                duration: data.duration ?? "N/A",
                                price: data.totalPrice ?? 0,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),

                              const SizedBox(height: 12),

                              buildDetailCard(
                                label: "Location",
                                value: data.product?.serviceArea ?? "N/A",
                                icon: Icons.location_city,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 24),

                              // Date & Time Section
                              Text(
                                "Date & Time",
                                style: AppTextStyle.sub_h3_medium_14(),
                              ),
                              const SizedBox(height: 12),
                              buildDetailCard(
                                label: "Booking",
                                value: formatDateTime(data.date),
                                icon: Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),

                        // Approval Button
                        SafeArea(
                          child: GetBuilder<BookingStatusController>(
                            builder: (statusController) {
                              final isLoading = statusController.isLoading;
                              final approved = itemController.massageItem?.data?.isPermitted ?? false;

                              return SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: approved
                                      ? null
                                      : () async {
                                    // Set button loading only
                                    statusController.setLoading(true);

                                    // Call API to approve booking
                                    await statusController.changeStatus(
                                      apiUrl: AppUrls.changeBookingStatus(bookingId),
                                      status: true,
                                    );

                                    // Update isPermitted locally without triggering shimmer
                                    itemController.massageItem?.data?.isPermitted = true;

                                    // Stop button loading
                                    statusController.setLoading(false);

                                    // Refresh button UI
                                    statusController.update();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                    backgroundColor: approved ? Colors.green : AppColors.primary_1,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                    shadowColor: AppColors.primary_1.withOpacity(0.4),
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
                // --- UPDATED HEADER SECTION ---
                body: _buildHeader(size, imageUrl),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- NEW HEADER METHOD ---
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

  Widget _backButton() {
    return GestureDetector(
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
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
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