import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/image_picker_dialog.dart';
import '../controller/massage_controller.dart';
import '../models/price_duration_model.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/category_controller.dart';

/// 🟦 ADD MASSAGE SCREEN
/// --------------------------------------------------
class AddMassageScreen extends StatefulWidget {
  const AddMassageScreen({super.key});

  @override
  State<AddMassageScreen> createState() => _AddMassageScreenState();
}

class _AddMassageScreenState extends State<AddMassageScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  /// 🟦 CONTROLLERS
  /// --------------------------------------------------
  final categoryController = Get.put(CategoryController());
  final addMassageController = Get.put(AddNewMassageController());

  final titleTEController = TextEditingController();
  final openTimeTEController = TextEditingController();
  final closeTimeTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final amountTEController = TextEditingController();
  final descriptionTEController = TextEditingController();
  final recommendationTEController = TextEditingController();

  /// 🟦 STATE VARIABLES
  /// --------------------------------------------------
  String? _selectedCategoryName;
  File? _servicePhotoFile;

  final List<Map<String, TextEditingController>> priceDurationFields = [
    {"duration": TextEditingController(), "price": TextEditingController()}
  ];

  /// 🟦 LIFECYCLE METHODS
  /// --------------------------------------------------
  @override
  void initState() {
    super.initState();
    categoryController.fetchCategories(AppUrls.massageCategoryUrl);
  }

  @override
  void dispose() {
    titleTEController.dispose();
    openTimeTEController.dispose();
    closeTimeTEController.dispose();
    locationTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    recommendationTEController.dispose();
    for (var field in priceDurationFields) {
      field["duration"]?.dispose();
      field["price"]?.dispose();
    }
    super.dispose();
  }

  /// 🟦 HELPER FUNCTIONS
  /// --------------------------------------------------
  void _addMorePriceDurationField() {
    setState(() {
      priceDurationFields.add({
        "duration": TextEditingController(),
        "price": TextEditingController(),
      });
    });
  }

  void _pickServicePhoto() async {
    ImagePickerDialogService.show(
      context: context,
      title: "Add Service Photo",
      subtitle: "Choose from gallery or take a new photo",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) async {
        await pickImage(source);
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _servicePhotoFile = File(pickedFile.path);
      });
    }
  }

  /// 🎯 FINAL SUBMISSION FUNCTION
  /// --------------------------------------------------
  void _saveMassage() async {
    if (_selectedCategoryName == null ||
        _servicePhotoFile == null ||
        titleTEController.text.isEmpty ||
        openTimeTEController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields and select a photo.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    final selectedCategory = categoryController.categories.firstWhereOrNull(
          (cat) => cat.name == _selectedCategoryName,
    );

    if (selectedCategory == null) {
      Get.snackbar("Error", "Invalid category selected.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }
    final categoryId = selectedCategory.id;

    List<MassageDuration> priceByDurations = [];
    for (var field in priceDurationFields) {
      final amount = field["price"]!.text.trim();
      final duration = field["duration"]!.text.trim();
      if (amount.isNotEmpty && duration.isNotEmpty) {
        priceByDurations.add(MassageDuration(amount: amount, duration: duration));
      }
    }




    final isSuccess = await addMassageController.createMassagePost(
      categoryId: categoryId,
      title: titleTEController.text.trim(),
      openTime: openTimeTEController.text.trim(),
      closeTime: closeTimeTEController.text.trim(),
      description: descriptionTEController.text.trim(),
      serviceArea: locationTEController.text.trim(),
      amount: amountTEController.text.trim(),
      benefits: descriptionTEController.text.trim(),
      ourRecommendations: recommendationTEController.text.trim(),
      file: _servicePhotoFile!,
      priceByDurations: priceByDurations,
      apiUrl: AppUrls.createMassageServiceUrl,
    );

    if (isSuccess) {

      Get.snackbar("Success", "Massage Post created successfully!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary_1,
          colorText: Colors.white);

      Navigator.of(context).pop();
    } else {
      Get.snackbar("Failed", addMassageController.errorMessage ?? "An unknown error occurred.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  /// 🟦 WIDGET BUILD
  /// --------------------------------------------------
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
      body: GetBuilder<CategoryController>(builder: (controller) {
        if (categoryController.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary_1));
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🟦 MASSAGE CATEGORY DROPDOWN
                Text("Massage Category", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildDropdownField(
                    "Select Massage",
                    categoryController.categories.map((e) => e.name).toList()),
                SizedBox(height: 20.h),

                /// 🟦 SERVICE PHOTO
                Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
                SizedBox(height: 10.h),
                _buildPhotoSelectionContainer(),
                SizedBox(height: 12.h),
                Text(
                  "Clear, professional photos help customers trust your service",
                  style: AppTextStyle.c_regular_12(),
                ),
                SizedBox(height: 24.h),

                /// 🟦 TITLE
                Text("Title", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildTextField("Relaxing Massage", titleTEController),
                SizedBox(height: 20.h),

                /// 🟦 OPEN & CLOSE TIME
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

                /// 🟦 LOCATION & AMOUNT
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
                          _buildTextField("Amount", amountTEController, isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                /// 🟦 PRICE PER DURATION
                Text("Set Price Per Duration", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 12.h),
                for (int i = 0; i < priceDurationFields.length; i++) ...[
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
                            _buildDurationField(
                                "Duration", priceDurationFields[i]["duration"]!),
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
                            _buildTextField(
                                "Set Price", priceDurationFields[i]["price"]!,
                                isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],
                _buildAddMoreButton(),
                SizedBox(height: 24.h),

                /// 🟦 BENEFITS
                Text("Benefits", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildLargeTextField("Write here...", descriptionTEController),
                SizedBox(height: 20.h),

                /// 🟦 OUR RECOMMENDATION
                Text("Our recommendation", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildLargeTextField("Write here...", recommendationTEController),
                SizedBox(height: 30.h),

                /// 🟦 SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: GetBuilder<AddNewMassageController>(builder: (controller){
                  return  ElevatedButton(
                      onPressed: controller.isLoading ? null : _saveMassage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary_1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );

                  })
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        }
      }),
    );
  }

  /// 🟦 REUSABLE WIDGETS
  /// --------------------------------------------------
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
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
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildLocationField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        suffixIcon:
        const Icon(Icons.location_on_outlined, color: Color(0xFFD6B25E)),
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

  Widget _buildDurationField(String hint, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
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
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildDropdownField(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryName,
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
        value: item,
        child: Row(children: [
          icons.massage.svg(height: 18.h),
          SizedBox(width: 6.w),
          Text(item)
        ]),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryName = value;
        });
      },
    );
  }

  /// 🟦 SERVICE PHOTO SELECTION
  Widget _buildPhotoSelectionContainer() {
    return InkWell(
      onTap: _pickServicePhoto,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: _servicePhotoFile != null
              ? Border.all(color: AppColors.primary_1, width: 2)
              : null,
        ),
        child: _servicePhotoFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _servicePhotoFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        )
            : const Center(
          child: Icon(
            Icons.upload,
            size: 28,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }


  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: _addMorePriceDurationField,
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
