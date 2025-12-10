import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/category_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/image_picker_dialog.dart';

/// Model class for handling individual repeatable hire items (Ski Item).
class HireItemDetail {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  // Image handling
  File? pickedImage; // If user selects a new image
  String? imageUrl;  // If there is an existing image from API

  // Existing API data
  String? id;        // _id from API
  int? availableQty; // Optional

  // Constructor for new items
  HireItemDetail();

  // Initialize from API JSON
  HireItemDetail.fromJson(Map<String, dynamic> json) {
    titleController.text = json['productName'] ?? '';
    priceController.text = (json['price'] ?? 0).toString();
    quantityController.text = (json['totalQty'] ?? 0).toString();
    imageUrl = json['productPhoto'];
    id = json['_id'];
    availableQty = json['availableQty'];
  }

  // Convert to JSON for saving/updating
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




class AddHIreScreen extends StatefulWidget {
  const AddHIreScreen({super.key});

  @override
  State<AddHIreScreen> createState() => _AddHIreScreenState();
}

class _AddHIreScreenState extends State<AddHIreScreen> {

  /// find/put controller
  final categoryController=Get.put(CategoryController());

  final serviceTitleController = TextEditingController();
  final selectAreaController = TextEditingController();

  String? selectedHireName;

  File? mainPickedImage; // New image picked for service
  String? mainImageUrl;  // Existing image from API

  final List<HireItemDetail> hireItems = [HireItemDetail()];

  bool isValid = true; // For enabling save button

  /// Add a new item to the list
  void _addMoreItem() {
    setState(() {
      hireItems.add(HireItemDetail());
    });
  }



  @override
  void initState() {
    // TODO: implement initState

    categoryController.fetchCategories(AppUrls.hireCategory);

    super.initState();
  }



  /// Save action button
  void _saveHire() {
    /// 1. Service Info
    final String serviceTitle = serviceTitleController.text;
    final String area = selectAreaController.text;
    final String? category = selectedHireName;

    /// 2. Main Service Image
    final File? mainImageFile = mainPickedImage;
    final String? mainImageUrlFromApi = mainImageUrl;

    ///3. Hire Items
    List<Map<String, dynamic>> hireItemData = hireItems.map((item) {
      return {
        "title": item.titleController.text,
        "price": int.tryParse(item.priceController.text) ?? 0,
        "quantity": int.tryParse(item.quantityController.text) ?? 0,
        "imageFile": item.pickedImage,
        "imageUrl": item.imageUrl,
        "id": item.id,
        "availableQty": item.availableQty,
      };
    }).toList();

    // Now you have all data in variables
    print("Service Title=>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: $serviceTitle");
    print("Area: $area");
    print("Category: $category");
    print("Main Image File: $mainImageFile");
    print("Main Image URL: $mainImageUrlFromApi");
    print("Hire Items=>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: $hireItemData");

    // TODO: You can now send this data to your API or save locally
  }


  /// Pick image for main service photo
  void _pickMainServicePhoto() async {
    final source = await _showImagePickerDialog();
    if (source != null) _pickImageForMain(source);
  }

  /// Pick image for an individual hire item
  void _pickItemImage(HireItemDetail item) async {
    final source = await _showImagePickerDialog();
    if (source != null) _pickImageForItem(item, source);
  }

  /// Show Image Picker Dialog and return source
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
      onImageSourceSelected: (source) {
        pickedSource = source;
      },
    );
    return pickedSource;
  }

  /// Pick main service image
  Future<void> _pickImageForMain(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        mainPickedImage = File(picked.path);
        mainImageUrl = null;
      });
    }
  }

  /// Pick image for a hire item
  Future<void> _pickImageForItem(HireItemDetail item, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        item.pickedImage = File(picked.path);
        item.imageUrl = null;
      });
    }
  }

  @override
  void dispose() {
    serviceTitleController.dispose();
    selectAreaController.dispose();
    for (var item in hireItems) {
      item.titleController.dispose();
      item.priceController.dispose();
      item.quantityController.dispose();
    }
    super.dispose();
  }

  // -------------------- UI Helpers --------------------

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isLocation = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
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
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) => setState(() => selectedHireName = value),
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
              // Image if available
              if (hasImage)
                mainPickedImage != null
                    ? Image.file(mainPickedImage!, fit: BoxFit.cover)
                    : Image.network(mainImageUrl!, fit: BoxFit.cover),

              // Centered upload icon
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38, // semi-transparent overlay
                    shape: BoxShape.circle,
                  ),
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



  /// Individual hire item image
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

  Widget _buildSkiItemBlock(HireItemDetail item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title", style: AppTextStyle.c_regular_12()),
                  const SizedBox(height: 8),
                  _buildTextField("Item Title", item.titleController),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Image", style: AppTextStyle.c_regular_12()),
                  const SizedBox(height: 8),
                  _buildItemImageField(item),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price", style: AppTextStyle.c_regular_12()),
                  const SizedBox(height: 8),
                  _buildTextField("\$ price", item.priceController, keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Quantity", style: AppTextStyle.c_regular_12()),
                  const SizedBox(height: 8),
                  _buildTextField("10", item.quantityController, keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return SizedBox(
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
  }

  Widget _buildSaveButton() {
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
        child: Text("Save",
            style: AppTextStyle.p_medium_12().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
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
        title: const Text("Add Hire",
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
                items: const ["Ski Gear", "Snowboard", "Safety Equipment"],
                selectedValue: selectedHireName,
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
              const SizedBox(height: 8),
              _buildTextField("Ski Safety", serviceTitleController),
              const SizedBox(height: 24),
              Text("Select Area", style: AppTextStyle.c_regular_12()),
              const SizedBox(height: 8),
              _buildTextField("Select Area", selectAreaController, isLocation: true),
              const SizedBox(height: 24),
              Text("Ski Item", style: AppTextStyle.p_medium_12().copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...hireItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSkiItemBlock(item),
              )),
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
