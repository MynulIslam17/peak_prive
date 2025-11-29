import 'package:flutter/material.dart';
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

  final String bookingStatus = 'overtime';
  final String cardId = 'BK-12345';
  final String userId = 'USR-67890';
  final String userName = 'John Doe';

  final double originalBookingHours = 3.0;
  final double extraUsesHours = 1.5;
  final String timeLeft = '2h 30m';

  final double baseAmount = 150.00;
  final double perHourCost = 30.00;

  double get totalBookingTime => originalBookingHours + extraUsesHours;
  double get overtimeAmount => extraUsesHours * perHourCost;

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
            _buildHeaderImage(size),
            _buildBackButton(context),
          ],
        ),
        panelBuilder: (scrollController) {
          return _buildPanel(scrollController, isOvertime);
        },
      ),
    );
  }

  // ============================== HEADER IMAGE ===============================

  Widget _buildHeaderImage(Size size) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/carImg1.jpg",
          width: double.infinity,
          height: size.height * 0.6,
          fit: BoxFit.cover,

        ),

        // Gradient overlay
        Container(
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
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      child: CustomBackButton(onTap: () => Get.back()),
    );
  }

  // ============================== PANEL CONTENT ===============================

  Widget _buildPanel(ScrollController scrollController, bool isOvertime) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Colors.grey[50],
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            _buildPanelHandle(),
            _buildStatusCard(isOvertime),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTimeUsageCard(isOvertime),
            const SizedBox(height: 16),
            _buildPaymentSummary(isOvertime),
            const SizedBox(height: 24),
            _buildPaymentButton(isOvertime),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Center(
        child: InkWell(
          onTap: () => panelController.isPanelOpen
              ? panelController.close()
              : panelController.open(),
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
    );
  }

  // ============================== STATUS CARD ===============================

  Widget _buildStatusCard(bool isOvertime) {
    return _card(
      color: isOvertime ? Colors.red[50]! : Colors.green[50]!,
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

  // ============================== DETAILS CARD ===============================

  Widget _buildInfoCard() {
    return _card(
      child: Column(
        children: [
          _infoRow('Product ID', cardId),
          _infoRow('User ID', userId),
          _infoRow('User Name', userName),
        ],
      ),
    );
  }

  // ============================== TIME USAGE CARD ===============================

  Widget _buildTimeUsageCard(bool isOvertime) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _timeRow('Original Booking', '${originalBookingHours}h'),
          _timeRow('Total Time Used', '${totalBookingTime}h',
              highlight: true),
          isOvertime
              ? _timeRow('Extra Time (Overtime)', '${extraUsesHours}h',
              danger: true)
              : _timeRow('Time Left', timeLeft),
        ],
      ),
    );
  }

  // ============================== PAYMENT SUMMARY ===============================

  Widget _buildPaymentSummary(bool isOvertime) {
    final totalAmount = baseAmount + (isOvertime ? overtimeAmount : 0);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _amountRow('Base Amount', baseAmount),
          if (isOvertime)
            _amountRow('Overtime (${extraUsesHours}h)', overtimeAmount,
                highlight: true),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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

  // ============================== PAYMENT BUTTON ===============================

  Widget _buildPaymentButton(bool isOvertime) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              isOvertime ? 'Make Payment' : 'Proceed to Payment',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ============================== REUSABLE WIDGETS ===============================

  Widget _card({required Widget child, Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String value,
      {bool highlight = false, bool danger = false}) {
    Color color = danger
        ? Colors.red
        : highlight
        ? Colors.blue
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: highlight || danger
                      ? FontWeight.bold
                      : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _amountRow(String label, double amount,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color:
                  highlight ? Colors.orange : Colors.grey[700])),
          Text('\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                  highlight ? Colors.orange : Colors.black)),
        ],
      ),
    );
  }
}
