import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';

class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final priceTEController = TextEditingController();
  final descriptionTEController = TextEditingController();

  /// Dynamic service input fields
  final List<Map<String, TextEditingController>> serviceFields = [
    {
      "title": TextEditingController(),
      "service": TextEditingController(),
    }
  ];

  @override
  void dispose() {
    priceTEController.dispose();
    descriptionTEController.dispose();
    for (var field in serviceFields) {
      field["title"]?.dispose();
      field["service"]?.dispose();
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
          "Add Pass",
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
            /// Image Picker Section
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

            /// Ski Pass Type Dropdown
            Text("Ski Pass Type", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField("Type", ["Basic", "Vip", "Premium"]),
            SizedBox(height: 20.h),

            /// Price per day
            Text("Price/day", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("12\$ /Per day", priceTEController),
            SizedBox(height: 20.h),

            /// Select Area
            Text("Select Area", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField("Select Area", ["Mountain", "Hill", "Resort"]),
            SizedBox(height: 20.h),

            /// Dynamic Service Fields
            for (int i = 0; i < serviceFields.length; i++) ...[
              Text("Service Title", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("Service Title (e.g. Free Parking)", serviceFields[i]["title"]!),
              SizedBox(height: 16.h),
              Text("Services", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("3 car parking", serviceFields[i]["service"]!),
              SizedBox(height: 20.h),
            ],

            _buildAddMoreButton(),
            SizedBox(height: 24.h),

            /// Description
            Text("Add Description", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write a Description", descriptionTEController),
            SizedBox(height: 30.h),

            /// Save Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {

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

  /// large text filed for add description

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


  /// drop downfield
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
          borderSide: const BorderSide(color: Color(0xFFD6B25E), width: 1.2), // gold highlight when active
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Row(
        children: [
          icons.ticket.svg(),
          SizedBox(width: 5,),
          Text(item)
          
        ],
      )))
          .toList(),
      onChanged: (value) {},
    );
  }



  /// add more button
  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          serviceFields.add({
            "title": TextEditingController(),
            "service": TextEditingController(),
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
