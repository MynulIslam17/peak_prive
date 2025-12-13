import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/build_user_card.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../core/constants/text-style.dart';

class MassageBookingDetails extends StatefulWidget {
  const MassageBookingDetails({super.key});

  @override
  State<MassageBookingDetails> createState() =>
      _MassageBookingDetailsState();
}

class _MassageBookingDetailsState extends State<MassageBookingDetails> {
  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SlidingUpPanel(
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
                Text(
                  "Booking Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),

                ModernUserCard(),



                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.people_outline,
                  title: "Number of Guests",
                  subtitle: "4 Guests",
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.schedule,
                  title: "Booking Time",
                  subtitle: "12:00 PM - 2:00 PM",
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                  ),
                  child: const Text(
                    "Confirm Booking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        body: SafeArea(
          child: Stack(
            children: [
              // Header image with overlay
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
                child: Image.asset(
                  "assets/images/restu1.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              // Back button + Title Row
              Positioned(
                top: 45,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
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
                    // Title
                    Text(
                      "Request Details",
                      style: AppTextStyle.h2_semibold_22(color: Colors.white),
                    ),
                    // Spacer for balance
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern info tile widget
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
}