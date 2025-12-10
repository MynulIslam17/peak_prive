import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/image_picker_dialog.dart';
import '../../../provider/shared/controllers/category_controller.dart';
import '../../../provider/shared/models/hire_service_model.dart';
import '../../../provider/ski_hire/controller/hire_controller.dart';
import '../../../user/shared/models/category_model.dart';
import '../../../../core/constants/api_urls.dart';

/// Model for individual hire items
class HireItemDetail {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  File? pickedImage;
  String? imageUrl;
  String? id;
  int? availableQty;

  HireItemDetail();
  HireItemDetail.fromJson(Map<String, dynamic> json) {
    titleController.text = json['productName'] ?? '';
    priceController.text = (json['price'] ?? 0).toString();
    quantityController.text = (json['totalQty'] ?? 0).toString();
    imageUrl = json['productPhoto'];
    id = json['_id'];
    availableQty = json['availableQty'];
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "productName": titleController.text,
      "productPhoto": imageUrl,
      "price": int.tryParse(priceController.text) ?? 0,
      "totalQty": int.tryParse(quantityController.text) ?? 0,
      "availableQty": availableQty ?? int.tryParse(quantityController.text) ?? 0,
    };
  }
}

/// Add/Edit Hire Screen
class AddHireScreen extends StatefulWidget {
  const AddHireScreen({super.key});

  @override
  State<AddHireScreen> createState() => _AddHireScreenState();
}

class _AddHireScreenState extends State<AddHireScreen> {
  final categoryController = Get.put(CategoryController());
  final hireController = Get.put(HireController());

  final serviceTitleController = TextEditingController();
  final selectAreaController = TextEditingController();
  final extraChargeController = TextEditingController();

  HireResult? hire; // existing hire (edit mode)
  bool isEdit = false;

  String? selectedCategoryName;
  File? mainPickedImage;
  String? mainImageUrl;

  final List<HireItemDetail> hireItems = [HireItemDetail()];
  bool isValid = true;

  @override
  void initState() {
    super.initState();

    // Fetch categories
    categoryController.fetchCategories(AppUrls.hireCategory);

    // Check for edit mode arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      hire = args['hire'] as HireResult?;
      isEdit = args['isEdit'] == true;
      if (hire != null) {
        _populateFieldsForEdit(hire!);
      }
    }
  }

  /// Populate fields if editing existing hire
  void _populateFieldsForEdit(HireResult hireData) {
    serviceTitleController.text = hireData.title ?? '';
    selectAreaController.text = hireData.serviceArea ?? '';
    extraChargeController.text = hireData.extraChargePerHour?.toString() ?? '';
    mainImageUrl = hireData.thumbnail;
    selectedCategoryName = hireData.category?.name;

    if (hireData.items != null && hireData.items!.isNotEmpty) {
      hireItems.clear();
      for (var item in hireData.items!) {
        hireItems.add(HireItemDetail.fromJson({
          "_id": item.id,
          "productName": item.name,
          "productPhoto": item.productPhoto,
          "price": item.price,
          "totalQty": item.quantity,
          "availableQty": item.availableQty,
        }));
      }
    }
  }

  /// Add more items
  void _addMoreItem() {
    setState(() {
      hireItems.add(HireItemDetail());
    });
  }


  /// Check if the list of hire items has been modified (added, removed, or content changed)
  bool _checkItemModification() {
    // 1. Check for change in total count (added/removed items)
    if (hire?.items?.length != hireItems.length) {
      return true;
    }

    // 2. Check for content modification in existing items
    if (hire != null) {
      for (int i = 0; i < hireItems.length; i++) {
        final currentItem = hireItems[i];
        final originalItem = hire!.items![i]; // Safe due to length check

        // Check if any field has changed for this item
        if (currentItem.titleController.text.trim() != originalItem.name ||
            currentItem.priceController.text.trim() != originalItem.price.toString() ||
            currentItem.quantityController.text.trim() != originalItem.quantity.toString() ||
            currentItem.pickedImage != null // A new image was picked
        ) {
          return true;
        }
        // Note: We don't need to check item.imageUrl since that's the original URL.
      }
    }

    // If we are here, the list size is the same and no fields/images changed.
    return false;
  }


  /// Save or update hire
  void _saveHire() async {
    // --- 0. Validation for Top-Level Fields ---
    if (mainPickedImage == null && (mainImageUrl == null || mainImageUrl!.isEmpty)) {
      Get.snackbar("Error", "Please select a main Service Photo");
      return;
    }
    if (selectedCategoryName == null) {
      Get.snackbar("Error", "Please select a Category");
      return;
    }
    if (serviceTitleController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a Title");
      return;
    }
    if (selectAreaController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a Service Area");
      return;
    }
    if (extraChargeController.text.trim().isEmpty ||
        int.tryParse(extraChargeController.text.trim()) == null) {
      Get.snackbar("Error", "Please enter a valid Extra Charge");
      return;
    }

    final selectedCategory = categoryController.categories.firstWhere(
          (cat) => cat.name == selectedCategoryName,
      orElse: () => ServiceCategory(id: "", name: "", categoryPhoto: ""),
    );

    if (selectedCategory.id.isEmpty) {
      Get.snackbar("Error", "Invalid category selected");
      return;
    }

    // --- FINAL DATA MAP & FILE LIST PREPARATION ---
    Map<String, dynamic> finalData = {};
    List<File> itemImages = [];
    bool isUpdate = isEdit && hire != null;

    // --- 1. Prepare Item Data (Conditional for Update) ---
    bool areItemsChanged = isUpdate ? _checkItemModification() : true;

    if (!isUpdate || areItemsChanged) {
      // If we are creating OR items have changed in update mode, validate and compile all items
      for (int i = 0; i < hireItems.length; i++) {
        final item = hireItems[i];
        final itemNumber = i + 1;

        // Item Validation (Must ensure all item data is valid if being sent)
        if (item.titleController.text.trim().isEmpty) {
          Get.snackbar("Error", "Item $itemNumber: Please enter a Title");
          return;
        }
        if (item.priceController.text.trim().isEmpty ||
            int.tryParse(item.priceController.text.trim()) == null) {
          Get.snackbar("Error", "Item $itemNumber: Please enter a valid Price");
          return;
        }
        if (item.quantityController.text.trim().isEmpty ||
            int.tryParse(item.quantityController.text.trim()) == null) {
          Get.snackbar("Error", "Item $itemNumber: Please enter a valid Quantity");
          return;
        }
        if (item.pickedImage == null && (item.imageUrl == null || item.imageUrl!.isEmpty)) {
          Get.snackbar("Error", "Item $itemNumber: Please select an Image");
          return;
        }

        // Item Data Compilation (Flattening)
        finalData["productItems[$i][productName]"] = item.titleController.text.trim();
        finalData["productItems[$i][price]"] = item.priceController.text.trim();
        finalData["productItems[$i][quantity]"] = item.quantityController.text.trim();

        // IMPORTANT: Include the item ID for existing items during an update
        if (item.id != null) {
          finalData["productItems[$i][_id]"] = item.id;
        }

        // Collect new images
        if (item.pickedImage != null) {
          itemImages.add(item.pickedImage!);
        }
      }
    }

    // --- 2. Prepare Top-Level Fields ---
    if (isUpdate) {
      // Only include fields that have changed by comparing to original 'hire' model

      if (serviceTitleController.text.trim() != hire!.title) {
        finalData['title'] = serviceTitleController.text.trim();
      }
      if (selectAreaController.text.trim() != hire!.serviceArea) {
        finalData['serviceArea'] = selectAreaController.text.trim();
      }
      if (extraChargeController.text.trim() != hire!.extraChargePerHour.toString()) {
        finalData['extraChargePerHour'] = extraChargeController.text.trim();
      }
      // Category ID comparison
      final originalCategoryId = hire!.category?.id ?? '';
      if (selectedCategory.id != originalCategoryId) {
        finalData['category'] = selectedCategory.id;
      }
      // Add ID for routing (required by your controller's update logic, typically)
      finalData["_id"] = hire!.id;

    } else {
      // For CREATE, include ALL required fields
      finalData['title'] = serviceTitleController.text.trim();
      finalData['serviceArea'] = selectAreaController.text.trim();
      finalData['extraChargePerHour'] = extraChargeController.text.trim();
      finalData['category'] = selectedCategory.id;
    }

    // --- 3. API Call ---
    bool success = false;
    if (isUpdate) {
      // Ensure we have at least one change (a file or a field) before calling update
      if (finalData.length <= 1 && mainPickedImage == null && itemImages.isEmpty && !areItemsChanged) {
        Get.snackbar("Info", "No changes detected.", backgroundColor: Colors.yellow);
        return;
      }

      success = await hireController.updateHireService(
        apiUrl: AppUrls.updateHireServiceUrl(hire!.id!),
        thumbnail: mainPickedImage,
        itemImages: itemImages,
        data: finalData, // Final map contains only changed fields/items
      );
    } else {
      success = await hireController.createHireService(
        apiUrl: AppUrls.createHireUrl,
        thumbnail: mainPickedImage!,
        itemImages: itemImages,
        data: finalData, // Final map contains all fields
      );
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        "Error",
        hireController.errorMessage ?? "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Image picker helpers
  Future<void> _pickImageForMain(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) setState(() {
      mainPickedImage = File(picked.path);
      mainImageUrl = null;
    });
  }

  Future<void> _pickImageForItem(HireItemDetail item, ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) setState(() {
      item.pickedImage = File(picked.path);
      item.imageUrl = null;
    });
  }

  Future<ImageSource?> _showImagePickerDialog() async {
    ImageSource? pickedSource;
    await ImagePickerDialogService.show(
      context: context,
      title: "Choose Image",
      subtitle: "Select from gallery or take a new photo",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) => pickedSource = source,
    );
    return pickedSource;
  }

  void _pickMainServicePhoto() async {
    final source = await _showImagePickerDialog();
    if (source != null) _pickImageForMain(source);
  }

  void _pickItemImage(HireItemDetail item) async {
    final source = await _showImagePickerDialog();
    if (source != null) _pickImageForItem(item, source);
  }

  @override
  void dispose() {
    serviceTitleController.dispose();
    selectAreaController.dispose();
    extraChargeController.dispose();
    for (var item in hireItems) {
      item.titleController.dispose();
      item.priceController.dispose();
      item.quantityController.dispose();
    }
    super.dispose();
  }

  // ----------------- UI -----------------
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isLocation = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyle.c_regular_12(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyle.c_regular_12().copyWith(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (isLocation)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    required String? selectedValue,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
        hint: Text(hint, style: AppTextStyle.c_regular_12().copyWith(color: Colors.grey.shade500)),
        value: selectedValue,
        style: AppTextStyle.c_regular_12().copyWith(color: Colors.black),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
        items: items.map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: (value) => setState(() => selectedCategoryName = value),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    bool hasImage = mainPickedImage != null || (mainImageUrl != null && mainImageUrl!.isNotEmpty);
    return GestureDetector(
      onTap: _pickMainServicePhoto,
      child: Container(
        height: 150.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary_1 : Colors.grey.shade300,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                mainPickedImage != null
                    ? Image.file(mainPickedImage!, fit: BoxFit.cover)
                    : Image.network(mainImageUrl!, fit: BoxFit.cover),
              Center(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  padding: EdgeInsets.all(8),
                  child: const Icon(Icons.upload, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImageField(HireItemDetail item) {
    return GestureDetector(
      onTap: () => _pickItemImage(item),
      child: Container(
        height: 48.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            item.pickedImage != null
                ? Image.file(item.pickedImage!, height: 30.h, width: 30.h, fit: BoxFit.cover)
                : (item.imageUrl != null
                ? Image.network(item.imageUrl!, height: 30.h, width: 30.h, fit: BoxFit.cover)
                : const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.amber)),
            const SizedBox(width: 8),
            Text("File(SVG)", style: AppTextStyle.c_regular_12().copyWith(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkiItemBlock(HireItemDetail item, int index) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title", style: AppTextStyle.c_regular_12()),
                const SizedBox(height: 8),
                _buildTextField("Item Title", item.titleController),
              ],
            )),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Image", style: AppTextStyle.c_regular_12()),
                const SizedBox(height: 8),
                _buildItemImageField(item),
              ],
            )),
            if (hireItems.length > 1)
              IconButton(
                onPressed: () => setState(() => hireItems.removeAt(index)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Price", style: AppTextStyle.c_regular_12()),
                const SizedBox(height: 8),
                _buildTextField("\$ price", item.priceController, keyboardType: TextInputType.number),
              ],
            )),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Quantity", style: AppTextStyle.c_regular_12()),
                const SizedBox(height: 8),
                _buildTextField("10", item.quantityController, keyboardType: TextInputType.number),
              ],
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() => SizedBox(
    width: double.infinity,
    height: 50.h,
    child: OutlinedButton.icon(
      onPressed: _addMoreItem,
      icon: const Icon(Icons.add, color: Colors.black87),
      label: Text("Add More",
          style: AppTextStyle.p_medium_12().copyWith(color: Colors.black87, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
    ),
  );

  Widget _buildSaveButton() => GetBuilder<HireController>(builder: (controller){

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isValid ? _saveHire : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppColors.primary_1 : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isLoading? Center(child: CircularProgressIndicator(color: Colors.white,),): Text(isEdit? "Update": "Save",
            style: AppTextStyle.p_medium_12().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  });

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
        title:  Text(isEdit? "Update Ski_Hire" : "Create Ski_Hire",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: GetBuilder<CategoryController>(builder: (controller){

        if(controller.isLoading){
          return Center(child: CircularProgressIndicator(color: AppColors.primary_1,),);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Category", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 8),
              _buildDropdownField(
                hint: "Select...",
                items: controller.categoryNames ,
                selectedValue: selectedCategoryName,
              ),
              const SizedBox(height: 24),
              Text("Add a Service Photo", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 8),
              _buildPhotoUploadArea(),
              const SizedBox(height: 8),
              Text(
                (mainPickedImage != null || (mainImageUrl != null && mainImageUrl!.isNotEmpty))
                    ? "Restaurant Photo Selected"
                    : "Not Selected (Restaurant Photo)",
                style: AppTextStyle.p_medium_12().copyWith(
                  fontWeight: FontWeight.w700,
                  color:(mainPickedImage != null || (mainImageUrl != null && mainImageUrl!.isNotEmpty))
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text("Clear, professional photos help customers trust your service",
                  style: AppTextStyle.c_light_12()),


              const SizedBox(height: 24),
              Text("Title", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 24),
              _buildTextField("Ski Safety", serviceTitleController),

              const SizedBox(height: 24),
              Text("Select Area", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 24),
              _buildTextField("Area", selectAreaController,isLocation: true),
              const SizedBox(height: 24),
              Text("Select Area", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 24),
              _buildTextField("Extra Charge/hr", extraChargeController,keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              Text("Ski Item", style: AppTextStyle.p_medium_12().copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...hireItems.asMap().entries.map((entry) {
                int index = entry.key;
                HireItemDetail item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSkiItemBlock(item, index),
                );
              }),

              _buildAddMoreButton(),
              const SizedBox(height: 30),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        );



      }),
    );
  }
}
