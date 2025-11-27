import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/widgets/custome_back_button.dart';

class ExtraBookingScreen extends StatefulWidget {
  const ExtraBookingScreen({super.key});

  @override
  State<ExtraBookingScreen> createState() => _ExtraBookingScreenState();
}

class _ExtraBookingScreenState extends State<ExtraBookingScreen> {
  final PanelController panelController = PanelController();

  // Sample data - replace with actual data
  final String bookingStatus = 'Overtime '; // or 'Active'
  final String cardId = 'BK-12345';
  final String userId = 'USR-67890';
  final String userName = 'John Doe';

  // Time data
  final double originalBookingHours = 3.0; // Original booking time in hours
  final double extraUsesHours = 1.5; // Extra time used in hours
  final String timeLeft = '2h 30m'; // Time remaining (for active status)

  // Pricing data
  final double baseAmount = 150.00;
  final double perHourCost = 30.00;

  // Calculated values
  double get totalBookingTime => originalBookingHours + extraUsesHours;
  double get extraAmount => extraUsesHours * perHourCost;
  double get overtimeAmount => extraAmount; // used in payment summary
  double get overtimeHours => extraUsesHours;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final bool isOvertime = bookingStatus.toLowerCase() == 'overtime';

    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        minHeight: size.height * 0.48,
        maxHeight: size.height * 0.75,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        parallaxEnabled: true,
        parallaxOffset: 0.2,
        body: Stack(
          children: [
            // Background Image with Overlay
            Stack(
              children: [
                Image.network(
                  "https://via.placeholder.com/600x400",
                  width: double.infinity,
                  height: size.height * 0.6,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: double.infinity,
                      height: size.height * 0.6,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: size.height * 0.6,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: size.height * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: CustomBackButton(
                onTap: () => Get.back(),
              ),
            ),
          ],
        ),
        panelBuilder: (ScrollController scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Container(
              color: Colors.grey[50],
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Drag Handle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: Colors.white,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          panelController.isPanelOpen
                              ? panelController.close()
                              : panelController.open();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Booking Status Card
                  _buildBookingStatusCard(isOvertime),

                  const SizedBox(height: 16),

                  // Booking Details Card
                  _buildBookingDetailsCard(),

                  const SizedBox(height: 16),

                  // Time Usage Card
                  _buildTimeUsageCard(isOvertime),

                  const SizedBox(height: 16),

                  // Payment Summary
                  _buildPaymentSummary(isOvertime),

                  const SizedBox(height: 24),

                  // Make Payment Button
                  _buildPaymentButton(isOvertime),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),

    );
  }

  // --- Helper Widgets (Untouched) ---

  Widget _buildSummaryRow(String label, double amount, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isHighlight ? Colors.orange[700] : Colors.grey[700],
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isHighlight ? Colors.orange[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Placeholder for missing helper widgets to make the file runnable/complete
  Widget _buildBookingStatusCard(bool isOvertime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOvertime ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(isOvertime ? Icons.access_time_filled : Icons.check_circle,
              color: isOvertime ? Colors.red : Colors.green),
          const SizedBox(width: 12),
          Text(
            isOvertime ? 'Overtime Status' : 'Booking Active',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOvertime ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Card ID', cardId),
          _buildDetailRow('User ID', userId),
          _buildDetailRow('User Name', userName),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTimeUsageCard(bool isOvertime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time Usage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTimeRow('Original Booking', '${originalBookingHours}h'),
          _buildTimeRow('Total Time Used', '${totalBookingTime}h', isHighlight: true),
          if (isOvertime)
            _buildTimeRow('Extra Time (Overtime)', '${extraUsesHours}h', isDanger: true)
          else
            _buildTimeRow('Time Left', timeLeft),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, {bool isHighlight = false, bool isDanger = false}) {
    Color valueColor = isDanger ? Colors.red : (isHighlight ? Colors.blue : Colors.black87);
    FontWeight valueWeight = isHighlight || isDanger ? FontWeight.bold : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: valueWeight,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  // End Placeholder

  Widget _buildPaymentSummary(bool isOvertime) {
    final double totalAmount = baseAmount + (isOvertime ? overtimeAmount : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Base Amount', baseAmount),
          if (isOvertime) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Overtime (${overtimeHours}h)',
              overtimeAmount,
              isHighlight: true,
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(bool isOvertime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to payment screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              isOvertime ? 'Make Payment' : 'Proceed to Payment',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}