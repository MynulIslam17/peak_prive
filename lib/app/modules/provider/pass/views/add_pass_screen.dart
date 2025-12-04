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
import '../../../../core/widgets/image_picker_dialog.dart';

import '../../shared/models/provider_pass_service.dart';
import '../controller/create_ski_pass_controller.dart';
import '../controller/update_pass_controller.dart';



// ============================================
// ADD PASS SCREEN
// ============================================

class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final CreatePassController createPassController = Get.put(CreatePassController());
  final UpdatePassController updatePassController = Get.put(UpdatePassController());

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
  bool hasChanges = false;

  late final bool isFromEdit;
  SkiPass? editingPass;

  String? originalTitle;
  String? originalPrice;
  String? originalDescription;
  String? originalPassType;
  String? originalArea;
  List<Map<String, String>> originalServices = [];

  @override
  void initState() {
    super.initState();

    var argument = Get.arguments ?? {};
    isFromEdit = argument["isEdit"] ?? false;
    editingPass = argument["pass"] as SkiPass?;

    if (isFromEdit && editingPass != null) {
      _fillFieldsForEdit(editingPass!);
    }

    titleTEController.addListener(_checkForChanges);
    priceTEController.addListener(_checkForChanges);
    descriptionTEController.addListener(_checkForChanges);

    if (!isFromEdit) {
      _validateForm();
    }
  }

  void _fillFieldsForEdit(SkiPass pass) {
    titleTEController.text = pass.title;
    priceTEController.text = pass.amount.toString();
    descriptionTEController.text = pass.description;
    selectedPassType = pass.skiPassType;
    selectedArea = pass.serviceArea;

    originalTitle = pass.title;
    originalPrice = pass.amount.toString();
    originalDescription = pass.description;
    originalPassType = pass.skiPassType;
    originalArea = pass.serviceArea;

    serviceFields.clear();
    if (pass.services != null && pass.services!.isNotEmpty) {
      for (var service in pass.services!) {
        final titleController = TextEditingController(text: service.title);
        final serviceController = TextEditingController(text: service.description);

        titleController.addListener(_checkForChanges);
        serviceController.addListener(_checkForChanges);

        serviceFields.add({
          "title": titleController,
          "service": serviceController,
        });
      }
    } else {
      final titleController = TextEditingController();
      final serviceController = TextEditingController();
      titleController.addListener(_checkForChanges);
      serviceController.addListener(_checkForChanges);
      serviceFields.add({"title": titleController, "service": serviceController});
    }

    originalServices = serviceFields
        .map((field) => {
      "title": field["title"]!.text,
      "service": field["service"]!.text,
    })
        .toList();
  }

  void _checkForChanges() {
    if (!isFromEdit) {
      _validateForm();
      return;
    }

    bool titleChanged = titleTEController.text != originalTitle;
    bool priceChanged = priceTEController.text != originalPrice;
    bool descriptionChanged = descriptionTEController.text != originalDescription;
    bool typeChanged = selectedPassType != originalPassType;
    bool areaChanged = selectedArea != originalArea;
    bool imageChanged = selectedImage != null;

    bool servicesChanged = false;
    if (serviceFields.length != originalServices.length) {
      servicesChanged = true;
    } else {
      for (int i = 0; i < serviceFields.length; i++) {
        String currentTitle = serviceFields[i]["title"]!.text;
        String currentService = serviceFields[i]["service"]!.text;
        if (currentTitle != originalServices[i]["title"] ||
            currentService != originalServices[i]["service"]) {
          servicesChanged = true;
          break;
        }
      }
    }

    setState(() {
      hasChanges = titleChanged ||
          priceChanged ||
          descriptionChanged ||
          typeChanged ||
          areaChanged ||
          imageChanged ||
          servicesChanged;
    });
  }

  void _validateForm() {
    if (isFromEdit) {
      _checkForChanges();
      return;
    }

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

  // ============================================
  // USE IMAGE PICKER DIALOG SERVICE
  // ============================================
  void _showImagePickerDialog() {
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
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
      _checkForChanges();
      _validateForm();
    }
  }

  Future<void> _savePass() async {
    FocusManager.instance.primaryFocus?.unfocus();

    List<Map<String, String>> services = serviceFields
        .map((field) => {
      "title": field["title"]!.text.trim(),
      "service": field["service"]!.text.trim(),
    })
        .toList();

    bool success = false;

    if (isFromEdit && editingPass != null) {
      final updateController = Get.put(UpdatePassController());
      success = await updateController.updateSkiPass(
        passId: editingPass!.id,
        title: titleTEController.text.trim(),
        skiPassType: selectedPassType!,
        area: selectedArea!,
        price: priceTEController.text.trim(),
        description: descriptionTEController.text.trim(),
        profileImage: selectedImage,
        serviceFields: services,
        ApiUrl: AppUrls.providerPassServiceUpdate(editingPass!.id),
      );

      if (!success) {
        Get.snackbar(
          "Error",
          updateController.errorMessage ?? "Failed to update pass",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    } else {
      success = await createPassController.createSkiPass(
        title: titleTEController.text.trim(),
        skiPassType: selectedPassType!,
        area: selectedArea!,
        price: priceTEController.text.trim(),
        description: descriptionTEController.text.trim(),
        profileImage: selectedImage!,
        serviceFields: services,
        ApiUrl: AppUrls.providerPassCreateUrl,
      );

      if (!success) {
        Get.snackbar(
          "Error",
          createPassController.errorMessage ?? "Failed to save pass",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    Navigator.pop(context, true);
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
        title: Text(
          isFromEdit ? "Edit Pass" : "Add Pass",
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
            _buildTextField("Enter Title", titleTEController, onChanged: _checkForChanges),
            SizedBox(height: 20.h),

            Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: _showImagePickerDialog,
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
            _buildDropdownField(
              hint: "Type",
              items: skiPassTypes,
              selectedValue: selectedPassType,
              onChanged: (value) {
                setState(() {
                  selectedPassType = value;
                });
                _checkForChanges();
              },
            ),
            SizedBox(height: 20.h),

            Text("Price/day", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildPriceTextField("0.00", priceTEController, onChanged: _checkForChanges),
            SizedBox(height: 20.h),

            Text("Select Area", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField(
              hint: "Select Area",
              items: areaList,
              selectedValue: selectedArea,
              onChanged: (value) {
                setState(() {
                  selectedArea = value;
                });
                _checkForChanges();
              },
            ),
            SizedBox(height: 20.h),

            for (int i = 0; i < serviceFields.length; i++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service ${i + 1}", style: AppTextStyle.c_regular_12()),
                  if (i != 0)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          serviceFields[i]["title"]?.dispose();
                          serviceFields[i]["service"]?.dispose();
                          serviceFields.removeAt(i);
                        });
                        _checkForChanges();
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildTextField("Service Title (e.g. Free Parking)", serviceFields[i]["title"]!, onChanged: _checkForChanges),
              SizedBox(height: 16.h),
              Text("Services", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("3 car parking", serviceFields[i]["service"]!, onChanged: _checkForChanges),
              SizedBox(height: 20.h),
            ],
            _buildAddMoreButton(),

            SizedBox(height: 24.h),
            Text("Add Description", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLargeTextField("Write a Description", descriptionTEController, onChanged: _checkForChanges),
            SizedBox(height: 30.h),

            isFromEdit
                ? GetBuilder<UpdatePassController>(
              init: UpdatePassController(),
              builder: (controller) {
                bool buttonEnabled = hasChanges;
                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: buttonEnabled && !controller.isLoading ? _savePass : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonEnabled && !controller.isLoading
                          ? AppColors.primary_1
                          : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            )
                : GetBuilder<CreatePassController>(
              init: CreatePassController(),
              builder: (controller) {
                bool buttonEnabled = isValid;
                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: buttonEnabled && !controller.isLoading ? _savePass : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonEnabled && !controller.isLoading
                          ? AppColors.primary_1
                          : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    String? selectedValue,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Row(children: [icons.ticket.svg(), const SizedBox(width: 5), Text(item)]),
      ))
          .toList(),
      onChanged: (value) {
        onChanged(value);
        setState(() {});
      },
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          final titleController = TextEditingController();
          final serviceController = TextEditingController();

          titleController.addListener(_checkForChanges);
          serviceController.addListener(_checkForChanges);

          serviceFields.add({
            "title": titleController,
            "service": serviceController,
          });
        });
        _checkForChanges();
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