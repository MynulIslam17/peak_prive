import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/app/data/services/stripe/payment_result.dart';
import 'package:harry_service_app/app/data/services/stripe/stripe_config.dart';
import 'package:harry_service_app/app/data/services/stripe/stripe_helper.dart';
import 'package:harry_service_app/app/core/constants/env_config.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/pass/models/pass_booking_request_model.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_parser.dart';
import '../../../../core/widgets/appBarWithTab.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/pass_details_controller.dart';

class SetInformation extends StatefulWidget {
  const SetInformation({super.key});

  @override
  State<SetInformation> createState() => _SetInformationState();
}

class _SetInformationState extends State<SetInformation> {
  late final prodoductId;

  /// Find booking controllers
  final bookingController = Get.find<CreateBookingController>();


  /// Find current user from authcontroller
  final authController = Get.find<AuthController>();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int selectedPerson = 1;
  final List<int> persons = [1, 2, 3, 4, 5];

  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;

  /// Returns valid booking DateTime or null if invalid
  DateTime? validateBookingDateTime() {
    if (selectedDate == null || selectedTime == null) {
      Get.snackbar(
        "Notice",
        "Please select Date and Time",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (dateTime.isBefore(DateTime.now())) {
      Get.snackbar(
        "Invalid Date",
        "Please select a future date & time",
        backgroundColor: AppColors.primary_1,
        colorText: Colors.white,
      );
      return null;
    }

    return dateTime;
  }

  /// Button checkout
  void _checkoutButton() async {

    if (_isProcessingPayment) return;

    final bookingDateTime = validateBookingDateTime();
    if (bookingDateTime == null) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      /// 1️⃣ Start Payment
      final result = await _paymentHelper.processPayment(
        context: context,
        amount: 100.0,
        currency: 'USD',
        description: 'Pass Booking Payment',
        metadata: {
          'productId': prodoductId.toString(),
          'personCount': selectedPerson.toString(),
          'date': bookingDateTime.toIso8601String(),

        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      /// 2️⃣ Payment Success Check
      if (result.isSuccess) {

        final transactionId = result.paymentData?['transactionId'];

        /// ⚠️ Transaction null check
        if (transactionId == null) {
          Get.snackbar(
            "Error",
            "Invalid transaction ID",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        /// 3️⃣ Call Booking API
        Map<String, dynamic> body = {
          "userId": authController.userModel!.id,
          "productId": prodoductId,
          "personCount": selectedPerson,
          "date": bookingDateTime.toIso8601String(),
          "transactionId": transactionId,
        };

        bool success = await bookingController.proceedBooking(body);

        /// 4️⃣ Booking Success Check
        if (success) {

          /// ✅ Show Success Dialog
          if (mounted) {
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
                    SizedBox(height: 16.h),
                    Text(
                      "Booking Confirmed!",
                      style: AppTextStyle.sub_h2_medium_16(color: Colors.green),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Your payment & booking completed successfully",
                      textAlign: TextAlign.center,
                      style: AppTextStyle.c_regular_12(color: AppColors.black_3),
                    ),
                  ],
                ),
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                 Navigator.of(context).pop();
                // Get.back();
                Get.toNamed(Routes.ticket);
              }
            });
          }

        } else {

          /// ❌ Booking Failed (Important Case)
          Get.snackbar(
            "Booking Failed",
            bookingController.errorMessage ?? "Payment done but booking failed",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }

      } else {

        /// ❌ Payment Failed
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60.sp),
                  SizedBox(height: 16.h),
                  Text(
                    "Payment Failed",
                    style: AppTextStyle.sub_h2_medium_16(color: Colors.red),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    result.message ?? "Payment could not be processed",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.c_regular_12(color: AppColors.black_3),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "OK",
                    style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1),
                  ),
                ),
              ],
            ),
          );
        }
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      /// 🔥 VERY IMPORTANT (reset state)
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }


  /// Pick date
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Pick time
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context,child){
       return MediaQuery(
           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
           child: child!
       );
      }
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    var argument = Get.arguments;
    prodoductId = argument["id"]; // Get product ID

    // Initialize Stripe payment helper
    _initializeStripeHelper();
  }

  void _initializeStripeHelper() {
    final config = StripeConfig(
      //secretKey: EnvConfig.stripeSk,
      secretKey: "sk_test_REDACTED_ROTATE_ME",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWithTabBar(
        title: "Set Information",
        onTap: () {
          Get.back();
        },
      ),
      body: GetBuilder<CreateBookingController>(builder: (controller) {
        return bookingController.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary_1,))
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Person
              Text(
                "Select Person",
                style: AppTextStyle.c_regular_12(color: AppColors.black_3),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40.h,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<int>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: selectedPerson,
                  items: persons.map((person) {
                    return DropdownMenuItem<int>(
                      value: person,
                      child: Text("$person"),
                    );
                  }).toList(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (value) {
                    setState(() {
                      selectedPerson = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),

              // Date Picker
              Text(
                "Select Date",
                style: AppTextStyle.c_regular_12(color: AppColors.black_3),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.black_3),
                      SizedBox(width: 20.w),
                      Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Select Date",
                        style: AppTextStyle.p_medium_12(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Time Picker
              Text(
                "Select Time",
                style: AppTextStyle.c_regular_12(color: AppColors.black_3),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time, color: AppColors.black_3),
                      SizedBox(width: 20.w),
                      Text(
                        formatTime(context, selectedTime),
                        style: AppTextStyle.p_medium_12(),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _isProcessingPayment
                    ? Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary_1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : CustomButton(
                        onTap: _checkoutButton,
                        width: double.infinity,
                        text: "Proceed to Checkout",
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
