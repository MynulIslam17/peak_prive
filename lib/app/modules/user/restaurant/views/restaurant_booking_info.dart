import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/modules/user/restaurant/models/restaurant_details_model.dart';

import '../../../../core/constants/text-style.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../../../../routes/app_routes.dart';
import '../../pass/controllers/pass_booking_controller.dart';

class RestaurantBookingInfo extends StatefulWidget {
  const RestaurantBookingInfo({super.key});

  @override
  State<RestaurantBookingInfo> createState() => _RestaurantBookingInfoState();
}

class _RestaurantBookingInfoState extends State<RestaurantBookingInfo> {
  // --- Controllers & Helpers ---
  late StripePaymentHelper _paymentHelper;
  final createBookingController = Get.find<CreateBookingController>();
  final authController = Get.find<AuthController>();
  final TextEditingController _bookingSeatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // --- State Variables ---
  late final Map<String, dynamic> productInfo;
  late final List<Slot> slotsList;
  bool _isProcessingPayment = false;
  String? _selectedDate;
  String? _selectedSlotId;

  // --- Styling ---
  final Color goldColor = const Color(0xFFD4AF37);
  final Color textColor = Colors.black;
  final Color greyTextColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    productInfo = Get.arguments;
    slotsList = List<Slot>.from(Get.arguments["availableSlots"]);
    _initializeStripeHelper();
  }

  void _initializeStripeHelper() {
    final config = StripeConfig(
      secretKey: 'sk_test_REDACTED_ROTATE_ME',
      merchantDisplayName: 'Harry Service',
      paymentSheetTheme: ThemeMode.light,
      allowsDelayedPaymentMethods: true,
    );

    _paymentHelper = StripePaymentHelper(
      config: config,
      onPaymentSuccess: (_) => setState(() => _isProcessingPayment = false),
      onPaymentFailure: (_) {
        setState(() => _isProcessingPayment = false);
        _showError("Payment Failed");
      },
    );
  }

  // --- Logic & Calculations ---

  /// Calculates the service fee amount based on percentage
  double _getCalculatedServiceFee() {
    int seatCount = int.tryParse(_bookingSeatController.text) ?? 0;
    int available = productInfo["availableQty"] ?? 0;
    double seatPrice = (productInfo["seatPrice"] as num).toDouble();

    // If input is invalid, return 0
    if (seatCount <= 0 || seatCount > available) return 0.0;

    double totalSeatPrice = seatCount * seatPrice;
    double percentage = (productInfo["serviceFee"] as num).toDouble(); // e.g., 10 for 10%

    return (totalSeatPrice * percentage) / 100;
  }

  double _calculateTotalAmount() {
    int seatCount = int.tryParse(_bookingSeatController.text) ?? 0;
    int available = productInfo["availableQty"] ?? 0;
    double seatPrice = (productInfo["seatPrice"] as num).toDouble();

    if (seatCount <= 0 || seatCount > available) return 0.0;

    double totalSeatPrice = seatCount * seatPrice;
    return totalSeatPrice + _getCalculatedServiceFee();
  }

  String? _getFormattedUtcDateTime() {
    if (_selectedDate == null || _selectedSlotId == null) return null;
    try {
      final selectedSlot = slotsList.firstWhere((s) => s.id == _selectedSlotId);
      List<String> dateParts = _selectedDate!.split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = 2000 + int.parse(dateParts[2]);

      String timeStr = selectedSlot.startTime!.toLowerCase();
      List<String> timeParts = timeStr.split(RegExp(r'[:\s]'));
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (timeStr.contains("pm") && hour < 12) hour += 12;
      if (timeStr.contains("am") && hour == 12) hour = 0;

      return DateTime.utc(year, month, day, hour, minute).toIso8601String();
    } catch (e) {
      return null;
    }
  }

  // --- Main Actions ---

  Future<void> _handleConfirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return _showError("Please select a date");
    if (_selectedSlotId == null) return _showError("Please select a time slot");

    setState(() => _isProcessingPayment = true);

    final paymentResult = await _paymentHelper.processPayment(
      context: context,
      amount: _calculateTotalAmount(),
      currency: 'USD',
      description: 'Restaurant Booking',
      metadata: {"userId": authController.userModel?.id ?? "", "productId": productInfo["productId"]},
    );

    if (paymentResult.isSuccess) {
      Map<String, dynamic> reqBody = {
        "userId": productInfo["userId"],
        "productId": productInfo["productId"],
        "bookingItems": [
          {"itemId": productInfo["itemId"], "quantity": int.parse(_bookingSeatController.text)}
        ],
        "totalPrice": _calculateTotalAmount(),
        "slots": [_selectedSlotId],
        "date": _getFormattedUtcDateTime(),
        "transactionId": paymentResult.paymentData?['transactionId'] ?? '',
      };

      bool success = await createBookingController.proceedBooking(reqBody);
      if (success) _showSuccessDialog();
    } else {
      setState(() => _isProcessingPayment = false);
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: "Booking Request"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Selected Seat Type'),
                  _buildSeatSelection(),
                  const SizedBox(height: 24),
                  _sectionTitle('Number of Seats'),
                  _buildSeatField(),
                  const SizedBox(height: 24),
                  _sectionTitle('Select Date'),
                  _buildDatePicker(),
                  const SizedBox(height: 24),
                  _sectionTitle('Available Time Slots'),
                  _buildTimeSlotGrid(),
                  const SizedBox(height: 24),
                  _sectionTitle('Booking Summary'),
                  _buildSummaryCard(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w600)),
  );

  Widget _buildSummaryCard() {
    int seatCount = int.tryParse(_bookingSeatController.text) ?? 0;
    int available = productInfo["availableQty"] ?? 0;
    double seatPrice = (productInfo["seatPrice"] as num).toDouble();
    double feePercent = (productInfo["serviceFee"] as num).toDouble();

    double seatTotal = (seatCount > 0 && seatCount <= available) ? (seatCount * seatPrice) : 0.0;
    double serviceFee = _getCalculatedServiceFee();
    double totalAmount = _calculateTotalAmount();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Column(
        children: [
          _summaryRow('Total Seat', '\$${seatTotal.toStringAsFixed(2)}'),
          Divider(color: Colors.grey[200]),
          _summaryRow('Service Fee ($feePercent%)', '\$${serviceFee.toStringAsFixed(2)}'),
          Divider(color: Colors.grey[200]),
          _summaryRow('Total Amount', '\$${totalAmount.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 17 : 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: isTotal ? textColor : greyTextColor)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? goldColor : textColor)),
        ],
      ),
    );
  }

  // --- Custom Widget Partials (Design Maintained) ---

  Widget _buildSeatSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [goldColor.withOpacity(0.1), goldColor.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: goldColor, borderRadius: BorderRadius.circular(12)),
            child: Image.asset(productInfo["seatType"] == "VIP" ? "assets/icons/crown.png" : "assets/icons/star1.png", width: 28, height: 28),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(productInfo["seatType"] ?? "VIP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: goldColor)),
            Text("Premium seating experience", style: TextStyle(fontSize: 12, color: greyTextColor)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSeatField() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _bookingSeatController,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 || (int.tryParse(v!)! > productInfo["availableQty"]) ? "Invalid seat number" : null,
        decoration: InputDecoration(
          hintText: "Enter number of seats",
          prefixIcon: Icon(Icons.event_seat, color: goldColor),
          suffix: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: goldColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text("Total: ${productInfo["availableQty"]}", style: TextStyle(fontSize: 12, color: goldColor, fontWeight: FontWeight.bold)),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
        if (date != null) setState(() => _selectedDate = "${date.day}/${date.month}/${date.year % 100}");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Icon(Icons.calendar_today, color: goldColor),
          const SizedBox(width: 12),
          Text(_selectedDate ?? 'Select Date', style: TextStyle(color: _selectedDate != null ? textColor : Colors.grey[400], fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ]),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2),
      itemCount: slotsList.length,
      itemBuilder: (context, index) {
        final slot = slotsList[index];
        final isSelected = _selectedSlotId == slot.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlotId = isSelected ? null : slot.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: [goldColor, goldColor.withOpacity(0.85)]) : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
            ),
            child: Row(children: [
              Icon(Icons.access_time_rounded, size: 18, color: isSelected ? Colors.white : goldColor),
              const SizedBox(width: 10),
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slot.startTime!, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold)),
                Text(slot.endTime!, style: TextStyle(color: isSelected ? Colors.white70 : greyTextColor, fontSize: 12)),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: GetBuilder<CreateBookingController>(builder: (controller) {
          bool isLoading = controller.isLoading || _isProcessingPayment;
          return ElevatedButton(
            onPressed: isLoading ? null : _handleConfirmBooking,
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Confirm Booking', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          );
        }),
      ),
    );
  }

  void _showError(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
          const SizedBox(height: 16),
          Text("Booking Successful!", style: AppTextStyle.sub_h2_medium_16(color: Colors.green)),
        ]),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => Get.offAllNamed(Routes.bottomNav));
  }

  @override
  void dispose() {
    _bookingSeatController.dispose();
    super.dispose();
  }
}