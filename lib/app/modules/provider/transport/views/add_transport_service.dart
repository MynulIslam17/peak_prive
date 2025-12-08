import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';

class AddTransportScreen extends StatefulWidget {
  const AddTransportScreen({super.key});

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final carTitleTEController = TextEditingController();
  final mileageTEController = TextEditingController();
  final powerTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final amountTEController = TextEditingController();
  final descriptionTEController = TextEditingController();
  final extraChargeTEController = TextEditingController();
  final insuranceTEController = TextEditingController();

  String? selectedBrandName;
  int? selectedSeatPerson;

  File? selectedImage;
  String? selectedImageUrl;
  final ImagePicker _picker = ImagePicker();



  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        selectedImage = File(file.path);
        selectedImageUrl = null; // clear network image if new picked
      });
    }
  }


  @override
  void dispose() {
    carTitleTEController.dispose();
    mileageTEController.dispose();
    powerTEController.dispose();
    locationTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    super.dispose();
  }




  /// save/update transport button

  void _saveRequest() async{

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
          "Add Transport",
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
            /// Car Brand Name Dropdown
            Text("Car Brand Name", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField(
              "Mitsubishi",
              ["Mitsubishi", "BMW", "Toyota", "Honda", "Mercedes"],
              selectedBrandName,
                  (value) => setState(() => selectedBrandName = value),
            ),
            SizedBox(height: 20.h),

            /// Add a Service Photo
            Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    border: Border.all(
                      color: selectedImage != null
                          ? const Color(0xFFD6B25E)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      /// === Background Image ===
                      Positioned.fill(
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : (selectedImageUrl != null && selectedImageUrl!.isNotEmpty
                            ? Image.network(
                          selectedImageUrl!,
                          fit: BoxFit.cover,
                        )
                            : const SizedBox()),
                      ),

                      /// === Upload Icon Always Visible ===
                      const Positioned(
                        top: 0,
                       left: 0,
                        right: 0,
                        bottom: 0,

                        child: Icon(
                          Icons.upload,
                          size: 40,
                          color: Colors.blue,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              "Clear, professional photos help customers trust your service",
              style: AppTextStyle.c_regular_12(),
            ),
            SizedBox(height: 24.h),

            /// Car Title
            Text("Car Title", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("BMW ", carTitleTEController),
            SizedBox(height: 20.h),

            /// Mileage/hr
            Text("Mileage/hr", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("250 km/hr", mileageTEController,isNumber: true),
            SizedBox(height: 20.h),

            /// Power
            Text("Power", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("120Hp", powerTEController,isNumber: true),
            SizedBox(height: 20.h),

            /// Set Person
            Text("Set Person", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildNumberDropdownField(
              "2",
              List.generate(16, (index) => index + 1),
              selectedSeatPerson,
                  (value) => setState(() => selectedSeatPerson = value),
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
                      _buildTextField("Amount", amountTEController,isNumber: true),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),



            /// extra charge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Extra Charge/hr", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("\$ Extra/hr", extraChargeTEController,isNumber: true),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Insurance Fee", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("Fee", insuranceTEController,isNumber: true),
                    ],
                  ),
                ),
              ],
            ),





            /// Description
            Text("Description", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write description here...", descriptionTEController),
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

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        bool isNumber = false,
        int maxLines = 1,
        Function(String)? onChanged,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: false, signed: false)
          : TextInputType.text,
      inputFormatters:
      isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        /// focused border with your gold color
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Color(0xFFD6B25E),
            width: 1.2,
          ),
        ),
      ),
    );
  }


  /// Location field with map icon
  Widget _buildLocationField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        suffixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xFFD6B25E),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),


        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Color(0xFFD6B25E),
            width: 1.2,
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

  /// String dropdown field
  Widget _buildDropdownField(
      String hint,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: selectedValue,
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
          .map((item) => DropdownMenuItem(value: item, child: Row(
        children: [
          icons.bmw.svg(),
          SizedBox(width: 5,),
          Text(item)
        ],
      )))
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Number dropdown field (for Set Person)
  Widget _buildNumberDropdownField(
      String hint,
      List<int> items,
      int? selectedValue,
      Function(int?) onChanged,
      ) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
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
        value: item,
        child: Text(item.toString()),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}