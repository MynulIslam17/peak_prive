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
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';

class BookingRequest extends StatefulWidget {
  const BookingRequest({super.key});

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  final images = Assets.images;
  final icons = Assets.icons;

  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;

  /// Controllers
  final authController = Get.find<AuthController>();
  final createBookingController = Get.find<CreateBookingController>();

  late final List<PriceByDuration> priceByDurationList;
  late final String productId;

  PriceByDuration? selectedDuration;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController requestTEController = TextEditingController();

  /// Show error message
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

    final arguments = Get.arguments;
    productId = arguments["id"] as String;

    priceByDurationList = (arguments["priceByDuration"] as List)
        .map((e) => e as PriceByDuration)
        .toList();

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
    setState(() {
      _isProcessingPayment = false;
    });
  }

  void _handlePaymentFailure(PaymentResult result) {
    setState(() {
      _isProcessingPayment = false;
    });
    _showError("Payment Failed");
  }

  /// Create Booking
  Future<void> _createBooking() async {
    if (_isProcessingPayment) return;

    // Validate selections
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

    setState(() {
      _isProcessingPayment = false;
    });

    if (paymentResult.isSuccess) {
      // Create booking body
      Map<String, dynamic> body = {
        "userId": authController.userModel!.id,
        "productId": productId,
        "durationId": selectedDuration!.id,
        "duration": selectedDuration!.duration,
        "price": selectedDuration!.amount,
        "bookingRequestText": requestTEController.text,
        "date": selectedDate!.toIso8601String(),
        "time": "${selectedTime!.hour}:${selectedTime!.minute}",
        "transactionId": paymentResult.paymentData?['transactionId'],
      };

      bool success = await createBookingController.proceedBooking(body);

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
            );
          },
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          Get.back(); // Back to previous screen
        }
      }
    } else {
      _showError("Payment failed or cancelled");
    }
  }

  /// Show date picker
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

  /// Show time picker
  Future<void> showTimePick() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      appBar: AppBar(
        title: const Text("Booking Request"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: icons.caretLeft.svg(color: Colors.black, width: 30, height: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration selection
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
                      color:item==selectedDuration ? AppColors.primary_1 : Colors.grey.withOpacity(0.5),
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

            // Date picker
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

            // Time picker
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
                      selectedTime == null
                          ? "Select Time"
                          : "${selectedTime!.hourOfPeriod.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')} ${selectedTime!.hour >= 12 ? 'PM' : 'AM'}",
                      style: AppTextStyle.sub_h3_regular_14().copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Special request
            Text("Enter Your Special Request (optional)", style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
            const SizedBox(height: 5),
            TextField(
              maxLines: 4,
              controller: requestTEController,
              decoration: InputDecoration(
                hintText: "Your Request",
                hintStyle: AppTextStyle.sub_h3_regular_14().copyWith(color: Colors.black.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),
            const Spacer(),

            // Checkout button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  // Price
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

                  // Confirm Booking Button
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isProcessingPayment ? null : _createBooking,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary_1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isProcessingPayment
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "Confirm Booking",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    requestTEController.dispose();
    super.dispose();
  }
}
