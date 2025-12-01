import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/create_ski_pass_controller.dart';

class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final CreatePassController createPassController = Get.put(CreatePassController());

  final titleTEController = TextEditingController();
  final priceTEController = TextEditingController();
  final descriptionTEController = TextEditingController();

  final List<String> skiPassTypes = ["Basic", "Vip", "Premium"];
  final List<String> areaList = ["Mountain", "Hill", "Resort"];

  String? selectedPassType;
  String? selectedArea;

  final List<Map<String, TextEditingController>> serviceFields = [
    {"title": TextEditingController(), "service": TextEditingController()}
  ];

  File? selectedImage;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    titleTEController.addListener(_validateForm);
    priceTEController.addListener(_validateForm);
    descriptionTEController.addListener(_validateForm);
  }

  void _validateForm() {
    bool allServicesFilled = serviceFields.every((field) =>
    field["title"]!.text.trim().isNotEmpty &&
        field["service"]!.text.trim().isNotEmpty);

    bool allFilled = selectedImage != null &&
        selectedPassType != null &&
        selectedArea != null &&
        titleTEController.text.trim().isNotEmpty &&
        priceTEController.text.trim().isNotEmpty &&
        descriptionTEController.text.trim().isNotEmpty &&
        allServicesFilled;

    setState(() {
      isValid = allFilled;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
      _validateForm();
    }
  }

  void showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary_1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.image_search,
                      color: AppColors.primary_1,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select Image",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose from gallery or take a photo",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildImagePickerOption(
                    icon: Icons.photo_library_rounded,
                    title: "Gallery",
                    subtitle: "Choose from your photos",
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildImagePickerOption(
                    icon: Icons.camera_alt_rounded,
                    title: "Camera",
                    subtitle: "Take a new photo",
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePass() async {
    FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

    List<Map<String, String>> services = serviceFields
        .map((field) => {
      "title": field["title"]!.text.trim(),
      "service": field["service"]!.text.trim(),
    })
        .toList();

    final success = await createPassController.createSkiPass(
      title: titleTEController.text.trim(),
      skiPassType: selectedPassType!,
      area: selectedArea!,
      price: priceTEController.text.trim(),
      description: descriptionTEController.text.trim(),
      profileImage: selectedImage!,
      serviceFields: services,
      ApiUrl: AppUrls.providerPassCreateUrl,
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        "Error",
        createPassController.errorMessage ?? "Failed to save pass",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    titleTEController.dispose();
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("Enter Title", titleTEController, onChanged: _validateForm),
            SizedBox(height: 20.h),

            Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: showImagePickerDialog,
              child: Container(
                height: 54.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.upload, size: 28, color: Colors.black54),
              ),
            ),
            SizedBox(height: 8.h),
            selectedImage != null
                ? const Text("Image Selected", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                : const SizedBox(),
            SizedBox(height: 12.h),
            Text("Clear, professional photos help customers trust your service",
                style: AppTextStyle.c_regular_12()),
            SizedBox(height: 24.h),

            Text("Ski Pass Type", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField("Type", skiPassTypes, (value) {
              selectedPassType = value;
              _validateForm();
            }),
            SizedBox(height: 20.h),

            Text("Price/day", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildPriceTextField("0.00", priceTEController, onChanged: _validateForm),
            SizedBox(height: 20.h),

            Text("Select Area", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField("Select Area", areaList, (value) {
              selectedArea = value;
              _validateForm();
            }),
            SizedBox(height: 20.h),

            // Dynamic Services
            for (int i = 0; i < serviceFields.length; i++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service ${i + 1}", style: AppTextStyle.c_regular_12()),
                  if (i != 0)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          serviceFields.removeAt(i);
                        });
                        _validateForm();
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildTextField("Service Title (e.g. Free Parking)", serviceFields[i]["title"]!, onChanged: _validateForm),
              SizedBox(height: 16.h),
              Text("Services", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("3 car parking", serviceFields[i]["service"]!, onChanged: _validateForm),
              SizedBox(height: 20.h),
            ],
            _buildAddMoreButton(),
            SizedBox(height: 24.h),

            Text("Add Description", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write a Description", descriptionTEController, onChanged: _validateForm),
            SizedBox(height: 30.h),

            GetBuilder<CreatePassController>(
              builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isValid && !controller.isLoading ? _savePass : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid && !controller.isLoading
                          ? AppColors.primary_1
                          : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(color: AppColors.primary_1, strokeWidth: 2),
                    )
                        : const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {VoidCallback? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController controller, {VoidCallback? onChanged}) {
    return TextField(
      controller: controller,
      maxLines: 5,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Row(children: [icons.ticket.svg(), SizedBox(width: 5), Text(item)]),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          serviceFields.add({"title": TextEditingController(), "service": TextEditingController()});
        });
        _validateForm();
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
          child: Text("+ Add More", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildPriceTextField(String hint, TextEditingController controller, {VoidCallback? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final text = newValue.text;
          if (text.split('.').length > 2) return oldValue;
          if (text.contains('.')) {
            final parts = text.split('.');
            if (parts[1].length > 2) return oldValue;
          }
          return newValue;
        }),
      ],
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixText: '\$ ',
        prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary_1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary_1, width: 2)),
      ),
    );
  }
}
