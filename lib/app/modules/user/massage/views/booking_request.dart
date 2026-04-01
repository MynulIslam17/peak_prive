import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/user/massage/models/massage_details_model.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_parser.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../../../../core/constants/env_config.dart';

class BookingRequest extends StatefulWidget {
  const BookingRequest({super.key});

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  final images = Assets.images;
  final icons = Assets.icons;

  late StripePaymentHelper _paymentHelper;

  // Tracks whether payment or booking API is in progress
  bool _isProcessingPayment = false;

  final authController = Get.find<AuthController>();
  final createBookingController = Get.find<CreateBookingController>();

  late final List<PriceByDuration> priceByDurationList;
  late final String productId;

  PriceByDuration? selectedDuration;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController requestTEController = TextEditingController();

  // Shows a red snackbar error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Get arguments passed from previous screen
    final arguments = Get.arguments;
    productId = arguments["id"] as String;

    priceByDurationList = (arguments["priceByDuration"] as List)
        .map((e) => e as PriceByDuration)
        .toList();

    _initializeStripeHelper();
  }

  // Initialize Stripe payment helper with config and callbacks
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

  // Payment success — do NOT stop indicator here,
  // booking API call will continue after this
  void _handlePaymentSuccess(PaymentResult result) {}

  // Payment failed — stop indicator and show error
  void _handlePaymentFailure(PaymentResult result) {
    setState(() {
      _isProcessingPayment = false;
    });
    _showError("Payment Failed");
  }

  Future<void> _createBooking() async {
    // Prevent duplicate requests
    if (_isProcessingPayment) return;

    // Validate all required fields before proceeding
    if (selectedDuration == null) {
      _showError("Please select a duration");
      return;
    }
    if (selectedDate == null) {
      _showError("Please select a date");
      return;
    }
    if (selectedTime == null) {
      _showError("Please select a time");
      return;
    }

    // Start loading indicator
    setState(() {
      _isProcessingPayment = true;
    });

    // Process Stripe payment
    final paymentResult = await _paymentHelper.processPayment(
      context: context,
      amount: selectedDuration!.amount.toDouble(),
      currency: 'USD',
      description: 'Pass Booking Payment',
      metadata: {
        "userId": authController.userModel?.id ?? "",
        "productId": productId,
      },
    );

    if (paymentResult.isSuccess) {
      // Payment succeeded — indicator stays ON while booking API runs

      // Build the scheduled datetime from selected date and time
      DateTime scheduledDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      // Ensure scheduled time is at least 5 minutes from now
      final now = DateTime.now();
      if (scheduledDateTime.isBefore(now.add(const Duration(minutes: 2)))) {
        scheduledDateTime = now.add(const Duration(minutes: 5));
      }

      // Format time as HH:mm string
      String hour = scheduledDateTime.hour.toString().padLeft(2, '0');
      String minute = scheduledDateTime.minute.toString().padLeft(2, '0');
      String formattedTime = "$hour:$minute";

      // Build booking request body
      Map<String, dynamic> body = {
        "userId": authController.userModel!.id,
        "productId": productId,
        "durationId": selectedDuration!.id,
        "duration": selectedDuration!.duration,
        "price": selectedDuration!.amount,
        "bookingRequestText": requestTEController.text,
        "date": scheduledDateTime.toIso8601String(),
        "time": formattedTime,
        "transactionId": paymentResult.paymentData?['transactionId'],
      };

      // Call booking API
      bool success = await createBookingController.proceedBooking(body);

      // Stop indicator after booking API completes
      setState(() {
        _isProcessingPayment = false;
      });

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
                SizedBox(height: 16.h),
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

        // Auto close dialog and navigate back after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          Get.back();
        }
      } else {
        // Booking API failed after successful payment
        _showError("Booking failed. Please contact support.");
      }
    } else {
      // Payment was cancelled or failed — stop indicator
      setState(() {
        _isProcessingPayment = false;
      });
      _showError("Payment failed or cancelled");
    }
  }

  // Opens native date picker
  Future<void> showDatePick() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Opens native time picker in 12-hour format
  Future<void> showTimePick() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Booking Request"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: icons.caretLeft.svg(color: Colors.black, width: 30, height: 30),
        ),
      ),
      // Use Column so bottom button stays fixed and form scrolls independently
      body: Column(
        children: [
          // Scrollable form area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duration selection chips
                  Text("Duration", style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: priceByDurationList.map((item) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedDuration = item;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // Highlight selected duration
                            color: item == selectedDuration
                                ? AppColors.primary_1
                                : Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${item.duration}  (\$${item.amount})",
                            style: AppTextStyle.c_regular_12().copyWith(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),

                  // Date picker field
                  Text("Select Date", style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: showDatePick,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          icons.calendarDots.svg(height: 25, width: 25),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate == null
                                ? "Select Date"
                                : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                            style: AppTextStyle.sub_h3_regular_14().copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Time picker field
                  Text("Select Time", style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: showTimePick,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          icons.time.svg(height: 25, width: 25),
                          const SizedBox(width: 10),
                          Text(
                            formatTime(context, selectedTime),
                            style: AppTextStyle.sub_h3_regular_14().copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Optional special request text field
                  Text(
                    "Enter Your Special Request (optional)",
                    style: AppTextStyle.c_regular_12(color: AppColors.black_3),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    maxLines: 4,
                    controller: requestTEController,
                    decoration: InputDecoration(
                      hintText: "Your Request",
                      hintStyle: AppTextStyle.sub_h3_regular_14()
                          .copyWith(color: Colors.black.withOpacity(0.4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom bar with price and confirm button
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              // Extra bottom padding for devices with home indicator
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              // Subtle top shadow to separate from scrollable content
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Show selected duration price
                SizedBox(
                  width: 110,
                  child: Text(
                    selectedDuration != null
                        ? "\$${selectedDuration!.amount}"
                        : "\$0.00",
                    style: AppTextStyle.sub_h1_medium_18(color: AppColors.primary_1),
                  ),
                ),
                const SizedBox(width: 10),

                // Confirm booking button — disabled while processing
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessingPayment ? null : _createBooking,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary_1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Show spinner while payment or booking API is running
                      child: _isProcessingPayment
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    requestTEController.dispose();
    super.dispose();
  }
}