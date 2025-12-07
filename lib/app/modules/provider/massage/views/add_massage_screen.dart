import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_massage_service_model.dart';
import 'package:harry_service_app/app/modules/user/shared/models/all_massage_model.dart';
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

  /// gets value from other class variable
  late bool isFromEdit;
  MassageResult? massageResult;

  /// 🟦 FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  bool _isFormValid = false;
  bool _isDirty = false;

  Map<String, dynamic> _initialValues = {};

  final List<Map<String, TextEditingController>> priceDurationFields = [
    {"duration": TextEditingController(), "price": TextEditingController()}
  ];

  /// 🟦 LIFECYCLE METHODS
  /// --------------------------------------------------
  @override
  void initState() {
    super.initState();
    var argument = Get.arguments;
    isFromEdit = argument?["isEdit"] ?? false;

    if (argument != null && argument is Map<String, dynamic> && argument["massage"] != null) {
      massageResult = argument["massage"] as MassageResult;
    }

    _addListenersToControllers();

    categoryController.fetchCategories(AppUrls.massageCategoryUrl).then((_) {
      if (isFromEdit && massageResult != null) {
        setState(() {
          _retrieveAllFiled();
        });
      }
      _checkFormValidity();
    });
  }

  void _addListenersToControllers() {
    titleTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    openTimeTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    closeTimeTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    locationTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    amountTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    descriptionTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });
    recommendationTEController.addListener(() { _checkFormValidity(); _checkIfDirty(); });

    for (var field in priceDurationFields) {
      field["duration"]?.addListener(_checkIfDirty);
      field["price"]?.addListener(_checkIfDirty);
    }
  }

  /// 🟦 CORE VALIDITY CHECK
  /// --------------------------------------------------
  void _checkFormValidity() {
    final bool textFieldsFilled = titleTEController.text.isNotEmpty &&
        openTimeTEController.text.isNotEmpty &&
        closeTimeTEController.text.isNotEmpty &&
        locationTEController.text.isNotEmpty &&
        amountTEController.text.isNotEmpty &&
        descriptionTEController.text.isNotEmpty &&
        recommendationTEController.text.isNotEmpty;

    final bool photoValid = isFromEdit
        ? (massageResult?.thumbnail != null || _servicePhotoFile != null)
        : (_servicePhotoFile != null);

    final bool categorySelected = _selectedCategoryName != null;

    final bool overallValid = textFieldsFilled && photoValid && categorySelected;

    if (_isFormValid != overallValid) {
      if (mounted) {
        setState(() {
          _isFormValid = overallValid;
        });
      }
    }
  }

  /// 🟦 DIRTY CHECK (CRITICAL FOR EDIT MODE)
  /// --------------------------------------------------
  void _checkIfDirty() {
    if (!isFromEdit || massageResult == null || _initialValues.isEmpty) {
      if (_isDirty) {
        if (mounted) {
          setState(() {
            _isDirty = false;
          });
        }
      }
      return;
    }

    // 1. Check Text Fields
    bool fieldsChanged = titleTEController.text.trim() != _initialValues['title'] ||
        openTimeTEController.text.trim() != _initialValues['openTime'] ||
        closeTimeTEController.text.trim() != _initialValues['closeTime'] ||
        locationTEController.text.trim() != _initialValues['serviceArea'] ||
        amountTEController.text.trim() != _initialValues['amount'] ||
        descriptionTEController.text.trim() != _initialValues['benefits'] ||
        recommendationTEController.text.trim() != _initialValues['ourRecommendations'];

    // 2. Check Category
    bool categoryChanged = _selectedCategoryName != _initialValues['categoryName'];

    // 3. Check Photo
    bool photoChanged = _servicePhotoFile != null;

    // 4. Check Dynamic Price/Duration Fields
    bool pricesChanged = _checkPriceDurationDirty();

    bool currentDirty = fieldsChanged || categoryChanged || photoChanged || pricesChanged;

    if (_isDirty != currentDirty) {
      if (mounted) {
        setState(() {
          _isDirty = currentDirty;
        });
      }
    }
  }

  bool _checkPriceDurationDirty() {
    final List<Map<String, String>> currentPrices = priceDurationFields
        .where((f) => f["duration"]!.text.trim().isNotEmpty && f["price"]!.text.trim().isNotEmpty)
        .map((f) => {
      "duration": f["duration"]!.text.trim(),
      "amount": f["price"]!.text.trim(),
    })
        .toList();

    final List<Map<String, String>> initialPrices = _initialValues['priceByDuration'] ?? [];

    if (currentPrices.length != initialPrices.length) {
      return true;
    }

    final List<Map<String, String>> sortedCurrent = List.from(currentPrices);
    final List<Map<String, String>> sortedInitial = List.from(initialPrices);

    sortedCurrent.sort((a, b) => (a['duration']! + a['amount']!).compareTo(b['duration']! + b['amount']!));
    sortedInitial.sort((a, b) => (a['duration']! + a['amount']!).compareTo(b['duration']! + b['amount']!));

    for (int i = 0; i < sortedCurrent.length; i++) {
      if (sortedCurrent[i]['duration'] != sortedInitial[i]['duration'] ||
          sortedCurrent[i]['amount'] != sortedInitial[i]['amount']) {
        return true;
      }
    }
    return false;
  }

  /// 🟦 retrieve all value (COMPLETE IMPLEMENTATION)
  /// --------------------------------------------------
  void _retrieveAllFiled() {
    if (massageResult == null) return;

    // 1. Text Fields - Handle null values properly
    titleTEController.text = massageResult!.title ?? "";
    openTimeTEController.text = massageResult!.openTime ?? "";
    closeTimeTEController.text = massageResult!.closeTime ?? "";
    locationTEController.text = massageResult!.serviceArea ?? "";
    amountTEController.text = massageResult!.amount?.toString() ?? "";
    descriptionTEController.text = massageResult!.benefits ?? "";
    recommendationTEController.text = massageResult!.ourRecommendations ?? "";

    // 2. Dropdown (Category)
    _selectedCategoryName = massageResult!.category?.name;

    // 3. Dynamic Price By Duration Fields
    for (var field in priceDurationFields) {
      field["duration"]?.removeListener(_checkIfDirty);
      field["price"]?.removeListener(_checkIfDirty);
      field["duration"]?.dispose();
      field["price"]?.dispose();
    }
    priceDurationFields.clear();

    final List<Map<String, String>> initialPriceDurations = [];

    // Only populate if priceByDuration exists and has items
    if (massageResult!.priceByDuration != null && massageResult!.priceByDuration!.isNotEmpty) {
      for (var item in massageResult!.priceByDuration!) {
        final String duration = item.duration ?? "";
        final String amount = item.amount?.toString() ?? "";

        final durationController = TextEditingController(text: duration);
        final priceController = TextEditingController(text: amount);

        durationController.addListener(_checkIfDirty);
        priceController.addListener(_checkIfDirty);

        priceDurationFields.add({
          "duration": durationController,
          "price": priceController,
        });

        if (duration.isNotEmpty && amount.isNotEmpty) {
          initialPriceDurations.add({"duration": duration, "amount": amount});
        }
      }
    }

    // Ensure at least one field exists
    if (priceDurationFields.isEmpty) {
      final durationController = TextEditingController();
      final priceController = TextEditingController();
      durationController.addListener(_checkIfDirty);
      priceController.addListener(_checkIfDirty);
      priceDurationFields.add({
        "duration": durationController,
        "price": priceController,
      });
    }

    // Store initial values - normalize empty strings and nulls
    _initialValues = {
      'title': titleTEController.text.trim(),
      'openTime': openTimeTEController.text.trim(),
      'closeTime': closeTimeTEController.text.trim(),
      'serviceArea': locationTEController.text.trim(),
      'amount': amountTEController.text.trim(),
      'benefits': descriptionTEController.text.trim(),
      'ourRecommendations': recommendationTEController.text.trim(),
      'categoryName': _selectedCategoryName,
      'priceByDuration': initialPriceDurations
        ..sort((a, b) => (a['duration']! + a['amount']!).compareTo(b['duration']! + b['amount']!)),
    };
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
      field["duration"]?.removeListener(_checkIfDirty);
      field["price"]?.removeListener(_checkIfDirty);
      field["duration"]?.dispose();
      field["price"]?.dispose();
    }
    super.dispose();
  }

  /// 🟦 HELPER FUNCTIONS
  /// --------------------------------------------------
  void _addMorePriceDurationField() {
    setState(() {
      final newDurationController = TextEditingController();
      final newPriceController = TextEditingController();

      newDurationController.addListener(_checkIfDirty);
      newPriceController.addListener(_checkIfDirty);

      priceDurationFields.add({
        "duration": newDurationController,
        "price": newPriceController,
      });
    });
    _checkIfDirty();
  }

  void _removePriceDurationField(int index) {
    setState(() {
      priceDurationFields[index]["duration"]?.removeListener(_checkIfDirty);
      priceDurationFields[index]["price"]?.removeListener(_checkIfDirty);
      priceDurationFields[index]["duration"]?.dispose();
      priceDurationFields[index]["price"]?.dispose();
      priceDurationFields.removeAt(index);
    });
    _checkIfDirty();
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
      _checkFormValidity();
      _checkIfDirty();
    }
  }

  /// 🎯 FINAL SUBMISSION FUNCTION
  /// --------------------------------------------------
  void _saveMassage() async {
    if (!_isFormValid) {
      Get.snackbar("Error", "Please fill all required fields.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    if (isFromEdit && !_isDirty) {
      Get.snackbar("Info", "No changes detected to update.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      Get.snackbar("Error", "Please correct the highlighted errors.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    final selectedCategory = categoryController.categories.firstWhereOrNull(
          (cat) => cat.name == _selectedCategoryName,
    );
    if (selectedCategory == null) {
      Get.snackbar("Error", "Please select a valid category.",
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

    final bool isSuccess;

    if (isFromEdit && massageResult != null) {
      final String updateUrlWithId = AppUrls.updateMassageServiceUrl(massageResult!.sId ?? "");

      isSuccess = await addMassageController.updateMassagePost(
        apiUrl: updateUrlWithId,
        categoryId: categoryId,
        title: titleTEController.text.trim(),
        openTime: openTimeTEController.text.trim(),
        closeTime: closeTimeTEController.text.trim(),
        description: descriptionTEController.text.trim(),
        benefits: descriptionTEController.text.trim(),
        serviceArea: locationTEController.text.trim(),
        amount: amountTEController.text.trim(),
        ourRecommendations: recommendationTEController.text.trim(),
        priceByDurations: priceByDurations,
        file: _servicePhotoFile,
      );
    } else {
      isSuccess = await addMassageController.createMassagePost(
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
    }

    if (isSuccess) {
      Get.snackbar("Success", "${isFromEdit ? 'Updated' : 'Created'} successfully!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary_1,
          colorText: Colors.white);

      Navigator.of(context).pop(true);
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
    final bool isButtonDisabled = isFromEdit
        ? (!_isFormValid || !_isDirty)
        : (!_isFormValid);

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
          isFromEdit ? "Edit Massage" : "Add Massage",
          style: const TextStyle(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Massage Category", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildDropdownField(
                      "Select Massage",
                      categoryController.categories.map((e) => e.name).toList()),
                  SizedBox(height: 20.h),

                  Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
                  SizedBox(height: 10.h),
                  _buildPhotoSelectionContainer(),
                  SizedBox(height: 12.h),
                  Text(
                    "Clear, professional photos help customers trust your service",
                    style: AppTextStyle.c_regular_12(),
                  ),
                  SizedBox(height: 24.h),

                  Text("Title", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildValidatedTextField("Relaxing Massage", titleTEController),
                  SizedBox(height: 20.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Open Time", style: AppTextStyle.c_regular_12()),
                            SizedBox(height: 8.h),
                            _buildValidatedTimeField("Select Time", openTimeTEController),
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
                            _buildValidatedTimeField("Select Time", closeTimeTEController),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location", style: AppTextStyle.c_regular_12()),
                            SizedBox(height: 8.h),
                            _buildValidatedTextField("Select Area", locationTEController),
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
                            _buildValidatedTextField("Amount", amountTEController, isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  Text("Set Price Per Duration", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 12.h),
                  Column(
                    children: List.generate(priceDurationFields.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
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
                            if (priceDurationFields.length > 1)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: InkWell(
                                  onTap: () => _removePriceDurationField(i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.close, size: 20, color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  _buildAddMoreButton(),
                  SizedBox(height: 24.h),

                  Text("Benefits", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildValidatedLargeTextField("Write here...", descriptionTEController, validationMessage: "Benefits are required"),
                  SizedBox(height: 20.h),

                  Text("Our recommendation", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  _buildValidatedLargeTextField("Write here...", recommendationTEController, validationMessage: "Recommendation is required"),
                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: GetBuilder<AddNewMassageController>(builder: (controller){
                      final bool finalDisabledState = isButtonDisabled || controller.isLoading;

                      return ElevatedButton(
                        onPressed: finalDisabledState ? null : _saveMassage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: finalDisabledState ? AppColors.primary_1.withOpacity(0.5) : AppColors.primary_1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          isFromEdit ? "Update" : "Save",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  /// 🟦 REUSABLE WIDGETS
  /// --------------------------------------------------

  Widget _buildPhotoSelectionContainer() {
    final existingPhotoUrl = isFromEdit && _servicePhotoFile == null
        ? massageResult?.thumbnail
        : null;

    return InkWell(
      onTap: _pickServicePhoto,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: (_servicePhotoFile != null || existingPhotoUrl != null)
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
            : existingPhotoUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            existingPhotoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text("Image Load Failed", style: TextStyle(color: Colors.red)),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
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


  // ----------------- UNVALIDATED TEXT FIELD (for optional fields like price/duration items) -----------------
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (value) => _checkIfDirty(), // Check dirty state on change
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
            String newText;
            if (hours == 0 && minutes == 0) {
              newText = ""; // Allow clearing if both are zero, though time picker usually prevents this.
            } else if (hours == 0) {
              newText = "$minutes min";
            } else if (minutes == 0) {
              newText = "$hours hr";
            } else {
              newText = "$hours hr $minutes min";
            }
            controller.text = newText;
          });
          _checkIfDirty(); // Check dirty state after setting text
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

  // ----------------- VALIDATED TEXT FORM FIELDS (for required fields) -----------------

  Widget _buildValidatedTextField(String hint, TextEditingController controller,
      {bool isNumber = false, String? validationMessage = "This field is required"}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validationMessage;
        }
        return null;
      },
      onChanged: (value) {
        _checkFormValidity();
        _checkIfDirty();
      },
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildValidatedTimeField(String hint, TextEditingController controller) {
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
          _checkFormValidity();
          _checkIfDirty();
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Time is required";
            }
            return null;
          },
          onChanged: (value) {
            // This is primarily for validation checks, actual text change is via onTap
            _checkFormValidity();
            _checkIfDirty();
          },
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedLargeTextField(String hint, TextEditingController controller, {String? validationMessage}) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validationMessage ?? "This field is required";
        }
        return null;
      },
      onChanged: (value) {
        _checkFormValidity();
        _checkIfDirty();
      },
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryName,
      dropdownColor: Colors.white,
      validator: (value) {
        if (value == null) {
          return "Please select a category";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedCategoryName = value;
          _checkFormValidity(); // Check validity after selecting category
          _checkIfDirty(); // Check dirty state after selecting category
        });
      },
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
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