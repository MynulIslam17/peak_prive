import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
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

  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;


  late final Map<String, dynamic> productInfo;

  ///finds controller
  final createBookingController = Get.find<CreateBookingController>();
  final  authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookingSeatController = TextEditingController();

  String? _selectedDate;
  String? _selectedTime;
  String? _selectedSlot;

  final Color goldColor = const Color(0xFFD4AF37);
  final Color textColor = Colors.black;
  final Color greyTextColor = Colors.grey;

  late final List<Slot> slotsList;

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentFailure,
      onLog: (message) => debugPrint('StripeLog: $message'),
    );
  }

  void _handlePaymentSuccess(PaymentResult result) {
    ///  Don't show snackbar immediately - wait for sheet to close
    setState(() {

      _isProcessingPayment = false;
    });
  }

  void _handlePaymentFailure(PaymentResult result) {
    setState(() {
      _isProcessingPayment = false;
    });
  }


  /// --- Convert selected date & time to ISO 8601 ---
  DateTime? _getIsoDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;
    try {
      // Split date
      List<String> dateParts = _selectedDate!.split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = 2000 + int.parse(dateParts[2]); // convert "25" -> 2025

      // Parse time
      TimeOfDay timeOfDay = TimeOfDay(
        hour: int.parse(_selectedTime!.split(":")[0]),
        minute: int.parse(_selectedTime!.split(":")[1].split(" ")[0]),
      );

      // Handle AM/PM
      if (_selectedTime!.toLowerCase().contains("pm") && timeOfDay.hour < 12) {
        timeOfDay = TimeOfDay(
          hour: timeOfDay.hour + 12,
          minute: timeOfDay.minute,
        );
      } else if (_selectedTime!.toLowerCase().contains("am") &&
          timeOfDay.hour == 12) {
        timeOfDay = TimeOfDay(hour: 0, minute: timeOfDay.minute);
      }

      return DateTime(year, month, day, timeOfDay.hour, timeOfDay.minute);
    } catch (e) {
      return null;
    }
  }

  // --- Date/Time Pickers ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: goldColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.day}/${picked.month}/${picked.year % 100}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: goldColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context);
      });
    }
  }

  // --- Booking Function ---
  Future<void> _createBooking(Map<String, dynamic> reqBody) async {
    if (_formKey.currentState!.validate()) {
      bool success = await createBookingController.proceedBooking(reqBody);

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
                SizedBox(height: 16),
                Text(
                  "Booking Successful!",
                  style: AppTextStyle.sub_h2_medium_16(color: Colors.green),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Your Booking has been processed successfully",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.c_regular_12(color: AppColors.black_3),
                ),
              ],
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          Get.offAllNamed(Routes.bottomNav);

          /// Back to previous screen
        }
      }
    }
  }

  String _totalSeatPrice(dynamic price, dynamic seat) {
    int seatCount = int.tryParse(seat.toString()) ?? 0;
    double seatPrice = (price as num).toDouble();
    return (seatPrice * seatCount).toStringAsFixed(2);
  }

  // --- Widgets ---
  Widget _buildSeatSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goldColor.withOpacity(0.1), goldColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [goldColor, goldColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: goldColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              productInfo["seatType"] == "VIP"
                  ? "assets/icons/crown.png"
                  : "assets/icons/star1.png",
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productInfo["seatType"] ?? "VIP",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Premium seating experience",
                style: TextStyle(fontSize: 12, color: greyTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSeatField() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _bookingSeatController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return "Enter number of seats";
          int availableSeat = productInfo["availableQty"];
          int selectedSeat = int.tryParse(value) ?? 0;
          if (selectedSeat <= 0) return "Enter a valid seat number";
          if (selectedSeat > availableSeat)
            return "$availableSeat seats available";
          return null;
        },
        decoration: InputDecoration(
          hintText: "Enter number of seats",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.event_seat, color: goldColor),
          suffix: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Total: ${productInfo["availableQty"]}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: goldColor,
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: goldColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          fontSize: 15,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final String dateText = _selectedDate ?? 'Select Date';
    final String timeText = _selectedTime ?? 'Select Time';
    final bool hasDate = _selectedDate != null;
    final bool hasTime = _selectedTime != null;

    return GestureDetector(
      onTap: () async {
        await _selectDate(context);
        if (mounted) await _selectTime(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (hasDate && hasTime)
                ? goldColor.withOpacity(0.3)
                : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, size: 20, color: goldColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                      color: hasDate ? textColor : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasTime ? greyTextColor : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid(List<Slot> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final bool isSelected = _selectedSlot == slot.id;

        return GestureDetector(
          onTap: () =>
              setState(() => _selectedSlot = isSelected ? null : slot.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [goldColor, goldColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? goldColor.withOpacity(0.5)
                    : Colors.grey.shade300,
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? goldColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : goldColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: isSelected ? Colors.white : goldColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slot.startTime!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        slot.endTime!,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : greyTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 16, color: goldColor),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 17 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? textColor : greyTextColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? goldColor : textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 16,
      color: textColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Booking Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Selected Seat Type'),
                  const SizedBox(height: 12),
                  _buildSeatSelection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Number of Seats'),
                  const SizedBox(height: 12),
                  _buildBookingSeatField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Select Start Date & Time'),
                  const SizedBox(height: 12),
                  _buildDateTimeSelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Available Time Slots'),
                  const SizedBox(height: 12),
                  _buildTimeSlotGrid(slotsList),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Booking Summary'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Seat',
                          _totalSeatPrice(
                            productInfo["seatPrice"],
                            _bookingSeatController.text,
                          ),
                        ),
                        Divider(color: Colors.grey[200], height: 1),
                        _buildSummaryRow('Service Fee', '\$25.00'),
                        Divider(color: Colors.grey[200], height: 1),
                        const SizedBox(height: 4),
                        _buildSummaryRow(
                          'Total Amount',
                          '\$275.00',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),


          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: GetBuilder<CreateBookingController>(builder: (controller) {
                return ElevatedButton(
                  onPressed: controller.bookingProgress
                      ? null
                      : () async {
                    // --- VALIDATIONS ---
                    if (_bookingSeatController.text.isEmpty) {
                      _showError("Please enter number of seats");
                      return;
                    }

                    int selectedSeat = int.tryParse(_bookingSeatController.text) ?? 0;
                    int availableSeat = productInfo["availableQty"];

                    if (selectedSeat <= 0) {
                      _showError("Please enter a valid seat number");
                      return;
                    }

                    if (selectedSeat > availableSeat) {
                      _showError("Only $availableSeat seats available");
                      return;
                    }

                    if (_selectedDate == null) {
                      _showError("Please select a date");
                      return;
                    }

                    if (_selectedTime == null) {
                      _showError("Please select a time");
                      return;
                    }

                    if (_selectedSlot == null || _selectedSlot!.isEmpty) {
                      _showError("Please select a time slot");
                      return;
                    }

                    // --- ISO DATE TIME ---
                    DateTime? isoDateTime = _getIsoDateTime();
                    if (isoDateTime == null) {
                      _showError("Invalid date/time");
                      return;
                    }




                    // Process Stripe payment
                    final PaymentResult = await _paymentHelper.processPayment(
                      context: context,
                      amount: 100.0, // Payment amount in dollars
                      currency: 'USD',
                      description: 'Pass Booking Payment',
                      metadata: {

                        "userId": authController.userModel?.id ?? "",
                        "productId": productInfo["productId"],

                      },
                    );

                    if(PaymentResult.isSuccess){
                      /// --- BOOKING REQUEST BODY ---
                      Map<String, dynamic> reqBody = {
                        "userId": productInfo["userId"],
                        "productId": productInfo["productId"],
                        "bookingItems": [
                          {"itemId": productInfo["itemId"], "quantity": selectedSeat},
                        ],
                        "slots": [_selectedSlot],
                        "date": isoDateTime.toIso8601String(),
                        "transactionId": PaymentResult.paymentData?['transactionId'],
                      };




                      ///--- CALL API ---
                      await _createBooking(reqBody);



                    }





                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.bookingProgress
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primary_1,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }),
            ),
          )

        ],
      ),
    );
  }

  @override
  void dispose() {
    _bookingSeatController.dispose();
    super.dispose();
  }
}