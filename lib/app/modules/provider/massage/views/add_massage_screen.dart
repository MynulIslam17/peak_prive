

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';

class AddMassageScreen extends StatefulWidget {
  const AddMassageScreen({super.key});

  @override
  State<AddMassageScreen> createState() => _AddMassageScreenState();
}

class _AddMassageScreenState extends State<AddMassageScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final titleTEController = TextEditingController();
  final openTimeTEController = TextEditingController();
  final closeTimeTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final amountTEController = TextEditingController();
  final descriptionTEController = TextEditingController();
  final recommendationTEController = TextEditingController();

  /// Dynamic benefit fields
  final List<Map<String, TextEditingController>> benefitFields = [
    {
      "duration": TextEditingController(),
      "price": TextEditingController(),
    }
  ];

  @override
  void dispose() {
    titleTEController.dispose();
    openTimeTEController.dispose();
    closeTimeTEController.dispose();
    locationTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    recommendationTEController.dispose();
    for (var field in benefitFields) {
      field["duration"]?.dispose();
      field["price"]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Massage",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Massage Category Dropdown
            Text("Massage Category", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField("Select...", ["Relaxing", "Deep Tissue", "Thai", "Hot Stone"]),
            SizedBox(height: 20.h),

            /// Add a Service Photo
            Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
            SizedBox(height: 10.h),
            Container(
              height: 54.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.upload, size: 28, color: Colors.black54),
            ),
            SizedBox(height: 12.h),
            Text(
              "Clear, professional photos help customers trust your service",
              style: AppTextStyle.c_regular_12(),
            ),
            SizedBox(height: 24.h),

            /// Title
            Text("Title", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("Relaxing Massage", titleTEController),
            SizedBox(height: 20.h),

            /// Open Time and Close Time (Side by Side)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Open Time", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTimeField("Select Time", openTimeTEController),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Close Time", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTimeField("Select Time", closeTimeTEController),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            /// Location and Amount/hr (Side by Side)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildLocationField("Select Area", locationTEController),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Amount/hr", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("Amount", amountTEController),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            /// Set Price Per Duration Section
            Text("Set Price Per Duration", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 12.h),

            /// Dynamic Benefit Fields
            for (int i = 0; i < benefitFields.length; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i == 0) ...[
                          Text("Duration", style: AppTextStyle.c_regular_12()),
                          SizedBox(height: 8.h),
                        ],
                        _buildDurationField("Duration", benefitFields[i]["duration"]!),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i == 0) ...[
                          Text("Set Price", style: AppTextStyle.c_regular_12()),
                          SizedBox(height: 8.h),
                        ],
                        _buildTextField("Set Price", benefitFields[i]["price"]!),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            _buildAddMoreButton(),
            SizedBox(height: 24.h),

            /// Benefits
            Text("Benefits", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write here...", descriptionTEController),
            SizedBox(height: 20.h),

            /// Our recommendation
            Text("Our recommendation", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write here...", recommendationTEController),
            SizedBox(height: 30.h),

            /// Save Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary_1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  /// --- Reusable Widgets ---

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  /// Time picker field
  Widget _buildTimeField(String hint, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            controller.text = picked.format(context);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: const Icon(Icons.access_time, color: Color(0xFFD6B25E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),
    );
  }

  /// Location field with map icon
  Widget _buildLocationField(String hint, TextEditingController controller) {
    return InkWell(
      onTap: () {
        // TODO: Open map picker screen
        // For now, just update with placeholder
        // setState(() {
        //   controller.text = "Selected Location";
        // });
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFD6B25E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),
    );
  }

  /// Duration field with clock icon
  Widget _buildDurationField(String hint, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            // Format as duration (e.g., "35 min" or "1 hr 30 min")
            final hours = picked.hour;
            final minutes = picked.minute;
            if (hours == 0) {
              controller.text = "$minutes min";
            } else if (minutes == 0) {
              controller.text = "$hours hr";
            } else {
              controller.text = "$hours hr $minutes min";
            }
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: const Icon(Icons.access_time, color: Color(0xFFD6B25E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),
    );
  }

  /// Large text field for description
  Widget _buildLargeTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  /// Dropdown field
  Widget _buildDropdownField(String hint, List<String> items) {

    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,

        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD6B25E), width: 1.2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(

          value: item, child: Row(children: [
            icons.massage.svg(),
           SizedBox(width: 6,),
           Text(item)
      ],)))
          .toList(),
      onChanged: (value) {},
    );
  }

  /// Add more button
  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          benefitFields.add({
            "duration": TextEditingController(),
            "price": TextEditingController(),
          });
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        height: 45.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            "+ Add More",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}