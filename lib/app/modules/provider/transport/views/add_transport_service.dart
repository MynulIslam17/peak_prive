import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../user/shared/models/all_transport_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/image_picker_dialog.dart';
import '../../shared/controllers/category_controller.dart';
import '../../shared/models/provider_transport_service_model.dart';
import '../controllers/create_transport_controller.dart';

class AddTransportScreen extends StatefulWidget {
  const AddTransportScreen({super.key});

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  // ==================== EDIT MODE VARIABLES ====================
  bool isFromEdit = false;
  TransportResult? transportModel;

  // ==================== CONTROLLERS ===========================
  final createTransportController = Get.put(AddNewTransportServiceController());
  final categoryController = Get.put(CategoryController());

  // ==================== TEXT CONTROLLERS =====================
  final carTitleTEController = TextEditingController();
  final mileageTEController = TextEditingController();
  final powerTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final amountTEController = TextEditingController();
  final descriptionTEController = TextEditingController();
  final extraChargeTEController = TextEditingController();
  final insuranceTEController = TextEditingController();

  // ==================== STATE VARIABLES =======================
  String? selectedBrandName;
  int? selectedSeatPerson;
  File? selectedImage;
  String? selectedImageUrl;
  final ImagePicker _picker = ImagePicker();

  // ==================== FORM VALIDATION =======================
  bool get _isFormValid {
    if (carTitleTEController.text.trim().isEmpty ||
        mileageTEController.text.trim().isEmpty ||
        powerTEController.text.trim().isEmpty ||
        locationTEController.text.trim().isEmpty ||
        amountTEController.text.trim().isEmpty ||
        descriptionTEController.text.trim().isEmpty ||
        extraChargeTEController.text.trim().isEmpty ||
        insuranceTEController.text.trim().isEmpty ||
        selectedBrandName == null ||
        selectedSeatPerson == null) return false;

    if (isFromEdit) {
      final hasImage = selectedImage != null || (selectedImageUrl != null && selectedImageUrl!.isNotEmpty);
      if (!hasImage) return false;
    } else {
      if (selectedImage == null) return false;
    }

    return true;
  }

  // ==================== IMAGE PICKER ===========================
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() {
        selectedImage = File(file.path);
        selectedImageUrl = null;
      });
    }
  }

  void _pickServicePhoto() {
    ImagePickerDialogService.show(
      context: context,
      title: isFromEdit ? "Change Service Photo" : "Add Service Photo",
      subtitle: "Choose from gallery or take a new photo",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) => _pickImage(source),
    );
  }

  // ==================== INIT STATE ============================
  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    isFromEdit = args["isEdit"] ?? false;

    final dynamic transportArg = args["transport"];
    if (transportArg != null) {
      if (transportArg is TransportResult) {
        transportModel = transportArg;
      } else if (transportArg is Map<String, dynamic>) {
        transportModel = TransportResult.fromJson(transportArg);
      }
    }

    categoryController.fetchCategories(AppUrls.transportCategoryUrl).then((_) {
      if (isFromEdit && transportModel != null) _populateFields(transportModel!);
    });
  }

  void _populateFields(TransportResult model) {
    carTitleTEController.text = model.title ?? "";
    mileageTEController.text = model.milage ?? "";
    powerTEController.text = model.power ?? "";
    locationTEController.text = model.serviceArea ?? "";
    amountTEController.text = model.amount?.toString() ?? "";
    descriptionTEController.text = model.description ?? "";
    extraChargeTEController.text = model.extraChargePerHours ?? "";
    insuranceTEController.text = model.insuranceFee?.toString() ?? "";
    selectedSeatPerson = model.personCount != null ? int.tryParse(model.personCount!) : null;
    selectedBrandName = model.category?.name;
    selectedImageUrl = model.thumbnail;
    setState(() {});
  }

  // ==================== SAVE REQUEST ==========================
  void _saveRequest() async {
    if (!_isFormValid) {
      Get.snackbar('Validation Failed', 'Please fill all required fields and select a photo.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final category = categoryController.categories.firstWhereOrNull((c) => c.name == selectedBrandName);
    if (category == null) {
      Get.snackbar('Error', 'Selected brand not found.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final data = {
      "title": carTitleTEController.text.trim(),
      "milage": mileageTEController.text.trim(),
      "power": powerTEController.text.trim(),
      "serviceArea": locationTEController.text.trim(),
      "amount": amountTEController.text.trim(),
      "description": descriptionTEController.text.trim(),
      "extraChargePerHours": extraChargeTEController.text.trim(),
      "insuranceFee": insuranceTEController.text.trim(),
      "personCount": selectedSeatPerson.toString(),
      "category": category.id,
      if (isFromEdit) "_id": transportModel?.sId,
    };

    bool result;
    if (isFromEdit && transportModel != null) {
      result = await createTransportController.updateTransportService(
        serviceId: transportModel!.sId!, // Existing service ID
        data: data,
        file: selectedImage, // Can be null if no new image is selected
        apiUrl: AppUrls.updateTransportUrl(transportModel!.sId!),
      );
    } else {
      result = await createTransportController.createTransportService(
        data: data,
        file: selectedImage!,
        apiUrl: AppUrls.createTransportService,
      );
    }


    if (result) {

      isFromEdit?
      Navigator.of(context).pop(true):
      Navigator.of(context).pop();


    } else {
      Get.snackbar('Failed', createTransportController.errorMessage ?? 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  /// this filed check if any filed changes during edit or not

  bool get _hasChanges {
    if (!isFromEdit || transportModel == null) return true; // For create, always true

    final category = categoryController.categories.firstWhereOrNull((c) => c.name == selectedBrandName);

    return carTitleTEController.text.trim() != (transportModel!.title ?? "") ||
        mileageTEController.text.trim() != (transportModel!.milage ?? "") ||
        powerTEController.text.trim() != (transportModel!.power ?? "") ||
        locationTEController.text.trim() != (transportModel!.serviceArea ?? "") ||
        amountTEController.text.trim() != (transportModel!.amount?.toString() ?? "") ||
        descriptionTEController.text.trim() != (transportModel!.description ?? "") ||
        extraChargeTEController.text.trim() != (transportModel!.extraChargePerHours ?? "") ||
        insuranceTEController.text.trim() != (transportModel!.insuranceFee?.toString() ?? "") ||
        selectedSeatPerson != (transportModel!.personCount != null ? int.tryParse(transportModel!.personCount!) : null) ||
        selectedBrandName != transportModel!.category?.name ||
        selectedImage != null; // if new image selected
  }


  @override
  void dispose() {
    carTitleTEController.dispose();
    mileageTEController.dispose();
    powerTEController.dispose();
    locationTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    extraChargeTEController.dispose();
    insuranceTEController.dispose();
    super.dispose();
  }

  // ==================== UI ===========================
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
        title: Text(isFromEdit ? "Edit Transport" : "Add Transport",
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
      ),
      body: GetBuilder<CategoryController>(builder: (controller) {
        if (controller.isLoading) return Center(child: CircularProgressIndicator(color: AppColors.primary_1));

        final categoryNames = controller.categories.map((e) => e.name).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Car Brand Name", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildDropdownField("Select Brand", categoryNames, selectedBrandName, (value) => setState(() => selectedBrandName = value)),
              SizedBox(height: 20.h),
              Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
              SizedBox(height: 10.h),
              _buildImagePicker(),
              SizedBox(height: 12.h),
              Text("Car Title", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("Title", carTitleTEController),
              SizedBox(height: 20.h),
              Text("Mileage/hr", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("km/hr", mileageTEController, isNumber: true),
              SizedBox(height: 20.h),
              Text("Power", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("Hp", powerTEController, isNumber: true),
              SizedBox(height: 20.h),
              Text("Set Person", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildNumberDropdownField("Person count", List.generate(16, (i) => i + 1), selectedSeatPerson, (value) => setState(() => selectedSeatPerson = value)),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("Select Area", locationTEController),
                    ],
                  )),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Amount/hr", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("Amount", amountTEController, isNumber: true),
                    ],
                  )),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Extra Charge/hr", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("\$ Extra/hr", extraChargeTEController, isNumber: true),
                    ],
                  )),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Insurance Fee", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTextField("Fee", insuranceTEController, isNumber: true),
                    ],
                  )),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Description", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildLargeTextField("Write description here...", descriptionTEController),
              SizedBox(height: 30.h),
              GetBuilder<AddNewTransportServiceController>(builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !controller.isLoading && _hasChanges ? _saveRequest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isFromEdit ? "Update" : "Save", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                );
              }),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        // normal border (unchanged)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        // gold border only when focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary_1,
            width: 2,
          ),
        ),
      ),
    );
  }


  Widget _buildLargeTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary_1,
            width: 2,
          ),
        ),
      ),
    );
  }


  Widget _buildDropdownField(String hint, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNumberDropdownField(String hint, List<int> items, int? selectedValue, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickServicePhoto,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selectedImage != null || selectedImageUrl != null ? AppColors.primary_1 : Colors.transparent, width: 2),
        ),
        child: selectedImage != null
            ? Image.file(selectedImage!, fit: BoxFit.cover)
            : (selectedImageUrl != null
            ? Image.network(selectedImageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error))
            : const Icon(Icons.upload, size: 40, color: Colors.blue)),
      ),
    );
  }
}
