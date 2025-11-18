import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/pass/models/pass_booking_request_model.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/appBarWithTab.dart';

class SetInformation extends StatefulWidget {
  const SetInformation({super.key});

  @override
  State<SetInformation> createState() => _SetInformationState();
}

class _SetInformationState extends State<SetInformation> {
  late final prodoductId;

  /// Find booking controller
  final bookingController = Get.find<PassBookingController>();

  /// Find current user from authcontroller
  final authController = Get.find<AuthController>();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int selectedPerson = 1;
  final List<int> persons = [1, 2, 3, 4, 5];

  /// Button checkout
  void _checkoutButton() async {
    if (selectedDate == null || selectedTime == null) {
      Get.snackbar("Notice", "Please select Date and Time", backgroundColor: Colors.red);
      return;
    }

    // Format the time and date for booking
    String formattedTime = selectedTime != null
        ? selectedTime!.hour.toString().padLeft(2, '0') + ':' + selectedTime!.minute.toString().padLeft(2, '0')
        : '';

    String formattedDate = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!) // Format date as "YYYY-MM-DD"
        : '';

    // Map to be sent to the backend
    Map<String, dynamic> body = {
      "userId": authController.userModel!.id,
      "productId": prodoductId,
      "personCount": selectedPerson,
      "date": formattedDate,
      "time": formattedTime,
    };

    // Call the booking API
    bool success = await bookingController.proceedBooking(body);

    if (success) {
      selectedDate = null;
      selectedTime = null;
      Get.snackbar("Success", "Booking Success", backgroundColor: Colors.green);
    } else {
      // Handle booking failure with specific error message
      Get.snackbar("Error", bookingController.errorMessage ?? "Booking failed. Please try again.", backgroundColor: Colors.red);
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
      body: GetBuilder<PassBookingController>(builder: (controller) {
        return bookingController.bookingProgress
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
                        selectedTime != null
                            ? "${selectedTime!.format(context)}"
                            : "Select Time",
                        style: AppTextStyle.p_medium_12(),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CustomButton(
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
