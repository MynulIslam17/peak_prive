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

/// Represents a single hire item with its properties
class HireItemModel {
  String? id;
  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController quantityController;
  File? imageFile;
  String? imageUrl;
  int? availableQty;

  HireItemModel({
    this.id,
    String? name,
    String? price,
    String? quantity,
    this.imageFile,
    this.imageUrl,
    int? availableQty,
  })  : nameController = TextEditingController(text: name ?? ''),
        priceController = TextEditingController(text: price ?? ''),
        quantityController = TextEditingController(text: quantity ?? ''),
        availableQty = availableQty;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'productName': nameController.text.trim(),
    'price': int.tryParse(priceController.text.trim()) ?? 0,
    'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
    'availableQty': availableQty ?? int.tryParse(quantityController.text.trim()) ?? 0,
  };

  bool get isValid =>
      nameController.text.trim().isNotEmpty &&
          priceController.text.trim().isNotEmpty &&
          int.tryParse(priceController.text.trim()) != null &&
          quantityController.text.trim().isNotEmpty &&
          int.tryParse(quantityController.text.trim()) != null &&
          (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty));

  bool hasImageChanged() => imageFile != null;

  bool hasImage() => imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);
}

/// Main screen for adding/editing hire services
class AddHireScreen extends StatefulWidget {
  const AddHireScreen({super.key});

  @override
  State<AddHireScreen> createState() => _AddHireScreenState();
}

class _AddHireScreenState extends State<AddHireScreen> {
  // Controllers
  final _categoryController = Get.put(CategoryController());
  final _hireController = Get.put(HireController());

  // Form Controllers
  final _titleController = TextEditingController();
  final _areaController = TextEditingController();
  final _extraChargeController = TextEditingController();

  // State variables
  HireResult? _originalHire;
  bool _isEditMode = false;
  String? _selectedCategory;
  File? _thumbnailFile;
  String? _thumbnailUrl;
  final List<HireItemModel> _items = [HireItemModel()];

  @override
  void initState() {
    super.initState();
    _categoryController.fetchCategories(AppUrls.hireCategory);
    _initializeEditMode();
  }

  /// Initialize edit mode if hire data is passed
  void _initializeEditMode() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['isEdit'] == true) {
      _originalHire = args['hire'] as HireResult?;
      _isEditMode = true;
      if (_originalHire != null) {
        _populateFormData(_originalHire!);
      }
    }
  }

  /// Populate form with existing hire data
  void _populateFormData(HireResult hire) {
    _titleController.text = hire.title ?? '';
    _areaController.text = hire.serviceArea ?? '';
    _extraChargeController.text = hire.extraChargePerHour?.toString() ?? '';
    _selectedCategory = hire.category?.name;
    _thumbnailUrl = hire.thumbnail;

    if (hire.items?.isNotEmpty ?? false) {
      _items.clear();
      for (var item in hire.items!) {
        int? convertedQty;
        if (item.availableQty is int) {
          convertedQty = item.availableQty as int;
        } else if (item.availableQty is num) {
          convertedQty = (item.availableQty as num).toInt();
        }

        _items.add(
          HireItemModel(
            id: item.id,
            name: item.name,
            price: item.price.toString(),
            quantity: item.quantity.toString(),
            imageUrl: item.productPhoto,
            availableQty: convertedQty,
          ),
        );
      }
    }
  }

  /// ============ VALIDATION ============

  /// Validate top-level form fields
  String? _validateTopLevelFields() {
    if (_selectedCategory == null) return 'Please select a category';
    if (_thumbnailFile == null && (_thumbnailUrl == null || _thumbnailUrl!.isEmpty)) {
      return 'Please upload a service photo';
    }
    if (_titleController.text.trim().isEmpty) return 'Please enter service title';
    if (_areaController.text.trim().isEmpty) return 'Please enter service area';
    if (_extraChargeController.text.trim().isEmpty) {
      return 'Please enter extra charge per hour';
    }
    if (int.tryParse(_extraChargeController.text.trim()) == null) {
      return 'Extra charge must be a valid number';
    }
    return null;
  }

  /// Validate all items
  String? _validateItems() {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];

      if (item.nameController.text.trim().isEmpty) {
        return 'Item ${i + 1}: Please enter item name';
      }
      // For edit mode: only require image if it's a new item (no imageUrl and no imageFile)
      // For create mode: always require image
      if (!item.hasImage()) {
        return 'Item ${i + 1}: Please upload item image';
      }
      if (item.priceController.text.trim().isEmpty) {
        return 'Item ${i + 1}: Please enter price';
      }
      if (int.tryParse(item.priceController.text.trim()) == null) {
        return 'Item ${i + 1}: Price must be a valid number';
      }
      if (item.quantityController.text.trim().isEmpty) {
        return 'Item ${i + 1}: Please enter quantity';
      }
      if (int.tryParse(item.quantityController.text.trim()) == null) {
        return 'Item ${i + 1}: Quantity must be a valid number';
      }
    }
    return null;
  }

  /// Validate entire form and return error message if invalid
  String? _validateForm() {
    final topLevelError = _validateTopLevelFields();
    if (topLevelError != null) return topLevelError;

    final itemsError = _validateItems();
    if (itemsError != null) return itemsError;

    return null;
  }

  /// Check if form data has been modified in edit mode
  bool _hasFormChanged() {
    if (!_isEditMode || _originalHire == null) return true;

    // Check top-level fields
    if (_titleController.text.trim() != (_originalHire!.title ?? '')) return true;
    if (_areaController.text.trim() != (_originalHire!.serviceArea ?? '')) return true;
    if (_extraChargeController.text.trim() != (_originalHire!.extraChargePerHour?.toString() ?? '')) {
      return true;
    }
    if (_selectedCategory != _originalHire!.category?.name) return true;
    if (_thumbnailFile != null) return true;

    // Check items
    if (_items.length != (_originalHire!.items?.length ?? 0)) return true;

    for (int i = 0; i < _items.length; i++) {
      final currentItem = _items[i];
      final originalItem = _originalHire!.items![i];

      if (currentItem.nameController.text.trim() != originalItem.name ||
          currentItem.priceController.text.trim() != originalItem.price.toString() ||
          currentItem.quantityController.text.trim() != originalItem.quantity.toString() ||
          currentItem.imageFile != null) {
        return true;
      }
    }

    return false;
  }

  /// ============ DATA PREPARATION ============

  /// Prepare form data for API submission
  Map<String, dynamic> _prepareFormData() {
    final data = <String, dynamic>{};

    if (_isEditMode && _originalHire != null) {
      data['_id'] = _originalHire!.id;

      // Add only changed fields
      if (_titleController.text.trim() != _originalHire!.title) {
        data['title'] = _titleController.text.trim();
      }
      if (_areaController.text.trim() != _originalHire!.serviceArea) {
        data['serviceArea'] = _areaController.text.trim();
      }
      if (_extraChargeController.text.trim() != _originalHire!.extraChargePerHour.toString()) {
        data['extraChargePerHour'] = _extraChargeController.text.trim();
      }
      if (_selectedCategory != _originalHire!.category?.name) {
        final category = _categoryController.categories
            .firstWhereOrNull((c) => c.name == _selectedCategory);
        if (category != null) data['category'] = category.id;
      }
    } else {
      // Create mode - add all fields
      data['title'] = _titleController.text.trim();
      data['serviceArea'] = _areaController.text.trim();
      data['extraChargePerHour'] = _extraChargeController.text.trim();

      final category = _categoryController.categories
          .firstWhereOrNull((c) => c.name == _selectedCategory);
      if (category != null) data['category'] = category.id;
    }

    // Add items
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      data['productItems[$i][productName]'] = item.nameController.text.trim();
      data['productItems[$i][price]'] = item.priceController.text.trim();
      data['productItems[$i][quantity]'] = item.quantityController.text.trim();
      if (item.id != null) data['productItems[$i][_id]'] = item.id;
    }

    return data;
  }

  /// Collect item images that need to be uploaded
  List<File> _getItemImages() {
    return _items.where((item) => item.imageFile != null).map((item) => item.imageFile!).toList();
  }

  /// ============ ACTIONS ============

  /// Handle save/update button press
  void _onSavePressed() async {
    // Validate form
    final validationError = _validateForm();
    if (validationError != null) {
      Get.snackbar(
        'Validation Error',
        validationError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check for changes in edit mode
    if (_isEditMode && !_hasFormChanged()) {
      Get.snackbar(
        'No Changes',
        'Please make changes before updating',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Prepare data
    final formData = _prepareFormData();
    final itemImages = _getItemImages();

    // Submit
    await _submitForm(formData, itemImages);
  }

  /// Submit form to API
  Future<void> _submitForm(Map<String, dynamic> formData, List<File> itemImages) async {
    bool success;

    if (_isEditMode) {
      success = await _hireController.updateHireService(
        apiUrl: AppUrls.updateHireServiceUrl(_originalHire!.id!),
        thumbnail: _thumbnailFile,
        itemImages: itemImages,
        data: formData,
      );
    } else {
      success = await _hireController.createHireService(
        apiUrl: AppUrls.createHireUrl,
        thumbnail: _thumbnailFile!,
        itemImages: itemImages,
        data: formData,
      );
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        'Error',
        _hireController.errorMessage ?? 'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick image from source
  Future<void> _pickImage(
      ImageSource source, {
        required bool isMainImage,
        HireItemModel? item,
      }) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        if (isMainImage) {
          _thumbnailFile = File(picked.path);
          _thumbnailUrl = null;
        } else if (item != null) {
          item.imageFile = File(picked.path);
          item.imageUrl = null;
        }
      });
    }
  }

  /// Show image source selection dialog
  Future<void> _showImageSourceDialog({
    required bool isMainImage,
    HireItemModel? item,
  }) async {
    ImageSource? source;
    await ImagePickerDialogService.show(
      context: context,
      title: 'Choose Image',
      subtitle: 'Select from gallery or take a new photo',
      galleryLabel: 'Gallery',
      gallerySubtitle: 'Choose from your photos',
      cameraLabel: 'Camera',
      cameraSubtitle: 'Take a new photo',
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (s) => source = s,
    );
    if (source != null) {
      await _pickImage(source!, isMainImage: isMainImage, item: item);
    }
  }

  /// Add new hire item
  void _addItem() {
    setState(() {
      _items.add(HireItemModel());
    });
  }

  /// Remove hire item
  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _extraChargeController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  // ============ UI BUILD METHODS ============

  Widget _buildCategoryDropdown(List<String> categories) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
        hint: Text(
          'Select Category',
          style: AppTextStyle.c_regular_12().copyWith(color: Colors.grey.shade500),
        ),
        value: _selectedCategory,
        style: AppTextStyle.c_regular_12(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
        items: categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
      ),
    );
  }

  Widget _buildTextInput(
      TextEditingController controller,
      String label,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        bool showLocationIcon = false,
      }) {
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
                hintStyle:
                AppTextStyle.c_regular_12().copyWith(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (showLocationIcon)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailUpload() {
    final hasImage = _thumbnailFile != null || (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service Photo', style: AppTextStyle.c_regular_12()),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _showImageSourceDialog(isMainImage: true),
          child: Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage ? AppColors.primary_1 : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    _thumbnailFile != null
                        ? Image.file(_thumbnailFile!, fit: BoxFit.cover)
                        : Image.network(_thumbnailUrl!, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          hasImage ? '✓ Photo Selected' : '✗ No Photo Selected',
          style: AppTextStyle.p_medium_12().copyWith(
            color: hasImage ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(HireItemModel item, int index) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title', style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildTextInput(
                    item.nameController,
                    'Item Title',
                    'Item Title',
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image', style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(isMainImage: false, item: item),
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
                          if (item.imageFile != null)
                            Image.file(item.imageFile!, height: 30.h, width: 30.h, fit: BoxFit.cover)
                          else if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                            Image.network(item.imageUrl!, height: 30.h, width: 30.h, fit: BoxFit.cover)
                          else
                            const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.amber),
                          SizedBox(width: 8.w),
                          Text('File(SVG)', style: AppTextStyle.c_regular_12().copyWith(color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_items.length > 1)
              Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price', style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildTextInput(
                    item.priceController,
                    'Price',
                    '\$ price',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity', style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildTextInput(
                    item.quantityController,
                    'Quantity',
                    '10',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: Text(
          'Add Item',
          style: AppTextStyle.p_medium_12().copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          _isEditMode ? 'Update Service' : 'Create Service',
          style: AppTextStyle.p_medium_12().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Hire Service' : 'Create Hire Service',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<CategoryController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("Category"),
                SizedBox(height: 10,),
                _buildCategoryDropdown(controller.categoryNames),
                SizedBox(height: 20.h),
                _buildThumbnailUpload(),
                SizedBox(height: 20.h),
                Text("Title"),
                SizedBox(height: 10,),
                _buildTextInput(_titleController, 'Service Title', 'Hire Title'),
                SizedBox(height: 16.h),

                Text("Location"),
             SizedBox(height: 10,),
                _buildTextInput(
                  _areaController,
                  'Service Area',
                  'Enter location',
                  showLocationIcon: true,
                ),
                SizedBox(height: 16.h),
                Text('Extra Charge per Hour'),
                SizedBox(height: 10,),
                _buildTextInput(
                  _extraChargeController,
                  'Extra Charge per Hour',
                  'e.g., 50',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Items',
                  style: AppTextStyle.p_medium_12().copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                ..._items.asMap().entries.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildItemCard(e.value, e.key),
                )),
                SizedBox(height: 12.h),
                _buildAddItemButton(),
                SizedBox(height: 24.h),
                GetBuilder<HireController>(
                  builder: (controller) => _buildSubmitButton(controller.isLoading),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }
}