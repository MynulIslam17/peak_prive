import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_resturant_service.dart';
import 'package:harry_service_app/app/modules/user/shared/models/category_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/image_picker_dialog.dart';
import '../../shared/controllers/category_controller.dart';
import '../controller/create_restaurant_controller.dart';

/// Model class for handling individual seat type data (VIP/Normal).
class SeatItem {
  String? selectedSeatType;
  TextEditingController totalSeatController = TextEditingController();
  TextEditingController pricePerSeatController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? selectedSeatImage; // for new image picked
  String? seatImageUrl;    // for existing network image

  SeatItem({this.selectedSeatType, this.seatImageUrl});
}

/// Main screen widget for adding or editing a restaurant.
class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {

  late Map<String, dynamic> originalData;

  /// Stores the initial data of the restaurant when in edit mode for comparison.
  void _storeOriginalData() {
    if (!isFromEdit || restaurantModel == null) return;

    originalData = {
      "restaurantName": restaurantModel!.title,
      "categoryId": restaurantModel!.category!.sId,
      "openTime": restaurantModel!.openTime,
      "closeTime": restaurantModel!.closeTime,
      "serviceArea": restaurantModel!.serviceArea,
      "thumbnail": restaurantModel!.thumbnail,
      // Store sorted list for robust comparison later
      "timeSlots": restaurantModel!.slots.map((e) => "${e.startTime} - ${e.endTime}").toList()..sort(),
      "vipSeat": {
        "totalSeat": vipSeatItem.totalSeatController.text,
        "price": vipSeatItem.pricePerSeatController.text,
        "description": vipSeatItem.descriptionController.text,
        "photo": vipSeatItem.seatImageUrl
      },
      "normalSeat": {
        "totalSeat": normalSeatItem.totalSeatController.text,
        "price": normalSeatItem.pricePerSeatController.text,
        "description": normalSeatItem.descriptionController.text,
        "photo": normalSeatItem.seatImageUrl
      },
    };
  }


  ///========================
  final icons = Assets.icons;

  final AddNewRestaurantController _restaurantController = Get.put(AddNewRestaurantController());
  final restaurantNameTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final categoryController = Get.put(CategoryController());

  final List<String> foodCategory = [];
  final List<String> seatTypes = ["VIP", "Normal"];

  String? selectedCategoryId;
  Result? restaurantModel;

  String? selectedCategory;
  String? selectedDescriptionType;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  TimeOfDay? startSlotTime;
  TimeOfDay? endSlotTime;

  final List<String> timeSlots = [];

  /// main image thumbnail
  File? selectedImage; // for add
  String? selectedImageUrl;  // network URL for edit mode

  late SeatItem vipSeatItem;
  late SeatItem normalSeatItem;

  bool isValid = false;
  late final bool isFromEdit;


  /// Initializes state, checks arguments for edit mode, sets up listeners, and fetches data.
  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments ?? {};
    isFromEdit = arguments["isEdit"] ?? false;
    restaurantModel = arguments["restaurant"] as Result?;

    vipSeatItem = SeatItem(selectedSeatType: "VIP");
    normalSeatItem = SeatItem(selectedSeatType: "Normal");

    _setupInitialListeners();
    restaurantNameTEController.addListener(_checkForChanges);
    locationTEController.addListener(_checkForChanges);


    // Fetch categories first
    categoryController.fetchCategories(AppUrls.restaurantCategoryUrl).then((_) {
      setState(() {
        foodCategory.clear();
        foodCategory.addAll(categoryController.categories.map((e) => e.name));

        // If edit mode, select the current category
        if (isFromEdit && restaurantModel != null) {
          selectedCategory = restaurantModel!.category!.name;
          final selectedCategoryObj = categoryController.categories.firstWhere(
                (cat) => cat.name == selectedCategory,
            orElse: () => ServiceCategory(id: '', name: '', categoryPhoto: ''),
          );
          selectedCategoryId = selectedCategoryObj.id.isNotEmpty ? selectedCategoryObj.id : null;
        }
      });
      _checkForChanges();
    });

    // If edit, also populate other fields
    if (isFromEdit && restaurantModel != null) {
      _addValueWhenEdit();
      _storeOriginalData(); // Store data AFTER populating fields
    }
  }


  /// Populates all form fields with existing restaurant data when in edit mode.
  void _addValueWhenEdit() {
    selectedCategory = restaurantModel!.category!.name;
    restaurantNameTEController.text = restaurantModel!.title;
    locationTEController.text = restaurantModel!.serviceArea;
    selectedImageUrl = restaurantModel!.thumbnail;
    openTime = parseTime(restaurantModel!.openTime);
    closeTime = parseTime(restaurantModel!.closeTime);


    // Populate time slots
    timeSlots.clear();
    for (var slot in restaurantModel!.slots) {
      String startTime = slot.startTime;
      String endTime = slot.endTime;
      timeSlots.add("$startTime - $endTime");
    }


    for (var item in restaurantModel!.items) {
      if (item.seat == "VIP") {
        vipSeatItem.descriptionController.text = item.description;
        vipSeatItem.pricePerSeatController.text = item.price.toString();
        vipSeatItem.totalSeatController.text = item.totalQty.toString();
        vipSeatItem.seatImageUrl = item.photo;
      } else if (item.seat == "Normal") {
        normalSeatItem.descriptionController.text = item.description;
        normalSeatItem.pricePerSeatController.text = item.price.toString();
        normalSeatItem.totalSeatController.text = item.totalQty.toString();
        normalSeatItem.seatImageUrl = item.photo;
      }
    }
  }


  /// Converts a time string (e.g., "10:30 AM") into a TimeOfDay object.
  TimeOfDay parseTime(String timeString) {
    try {

      List<String> parts = timeString.split(RegExp(r'[:\s]'));
      if (parts.length < 2) return TimeOfDay.now();

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

      // Handle AM/PM logic
      if (timeString.toUpperCase().contains('PM') && hour < 12) {
        hour += 12;
      } else if (timeString.toUpperCase().contains('AM') && hour == 12) {
        hour = 0; // Midnight case
      }

      return TimeOfDay(hour: hour % 24, minute: minute);
    } catch (e) {
      return TimeOfDay.now(); // fallback
    }
  }


  /// Sets up listeners for seat item controllers to track changes.
  void _setupInitialListeners() {
    vipSeatItem.totalSeatController.addListener(_checkForChanges);
    vipSeatItem.pricePerSeatController.addListener(_checkForChanges);
    vipSeatItem.descriptionController.addListener(_checkForChanges);

    normalSeatItem.totalSeatController.addListener(_checkForChanges);
    normalSeatItem.pricePerSeatController.addListener(_checkForChanges);
    normalSeatItem.descriptionController.addListener(_checkForChanges);
  }

  /// Called on any change to trigger form validation.
  void _checkForChanges() {
    _validateForm();
  }

  /// Validates all required fields to enable or disable the submit button.
  void _validateForm() {
    bool timeSlotsAdded = timeSlots.isNotEmpty;


    bool vipValid = vipSeatItem.selectedSeatType != null &&
        vipSeatItem.totalSeatController.text.trim().isNotEmpty &&
        vipSeatItem.pricePerSeatController.text.trim().isNotEmpty &&
        vipSeatItem.descriptionController.text.trim().isNotEmpty &&
        (vipSeatItem.selectedSeatImage != null || (vipSeatItem.seatImageUrl != null && vipSeatItem.seatImageUrl!.isNotEmpty));

    bool normalValid = normalSeatItem.selectedSeatType != null &&
        normalSeatItem.totalSeatController.text.trim().isNotEmpty &&
        normalSeatItem.pricePerSeatController.text.trim().isNotEmpty &&
        normalSeatItem.descriptionController.text.trim().isNotEmpty &&
        (normalSeatItem.selectedSeatImage != null || (normalSeatItem.seatImageUrl != null && normalSeatItem.seatImageUrl!.isNotEmpty));

    bool allFilled = (selectedImage != null || (selectedImageUrl != null && selectedImageUrl!.isNotEmpty)) &&
        selectedCategory != null &&
        openTime != null &&
        closeTime != null &&
        restaurantNameTEController.text.trim().isNotEmpty &&
        locationTEController.text.trim().isNotEmpty &&
        timeSlotsAdded &&
        vipValid &&
        normalValid;

    setState(() {
      isValid = allFilled;
    });
  }

  /// Displays the dialog for picking the main restaurant image.
  void _showImagePickerDialog() {
    ImagePickerDialogService.show(
      context: context,
      title: "Add Restaurant Photo",
      subtitle: "Choose from gallery or take a new photo",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) async {
        await pickImage(source, isSeatImage: false);
      },
    );
  }

  /// Displays the dialog for picking the seat image.
  void _showSeatImagePickerDialog(SeatItem item) {
    ImagePickerDialogService.show(
      context: context,
      title: "Add Seat Photo/Layout",
      subtitle: "Choose image for the selected seat type",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) async {
        await pickImage(source, isSeatImage: true, seatItem: item);
      },
    );
  }

  /// Handles the image picking process from the selected source.
  Future<void> pickImage(ImageSource source, {required bool isSeatImage, SeatItem? seatItem}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        if (isSeatImage && seatItem != null) {
          seatItem.selectedSeatImage = File(picked.path);
          seatItem.seatImageUrl = null;
        } else {
          selectedImage = File(picked.path);
          selectedImageUrl = null;
        }
      });
      _checkForChanges();
    }
  }

  /// Shows the time picker dialog for selecting opening/closing time.
  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? (openTime ?? TimeOfDay.now()) : (closeTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
      _checkForChanges();
    }
  }

  /// Shows the time picker dialog for selecting a time slot start/end time.
  Future<void> _selectSlotTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startSlotTime ?? TimeOfDay.now()) : (endSlotTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startSlotTime = picked;
        } else {
          endSlotTime = picked;
        }
      });
    }
  }

  /// Adds the currently selected start and end slot times to the timeSlots list.
  void _addSlotTime() {
    if (startSlotTime != null && endSlotTime != null) {
      final start = startSlotTime!.format(context);
      final end = endSlotTime!.format(context);

      setState(() {
        timeSlots.add("$start - $end");
        startSlotTime = null;
        endSlotTime = null;
      });
      _checkForChanges();
    }
  }

  /// Removes a time slot at the given index.
  void _removeSlotTime(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
    _checkForChanges();
  }



  /// Helper method to check if a seat item has changed
  bool _seatItemChanged(SeatItem item, Map<String, dynamic>? originalSeat, String seatType) {
    if (originalSeat == null) {
      // Create mode - always consider changed if we have data
      return item.totalSeatController.text.isNotEmpty ||
          item.pricePerSeatController.text.isNotEmpty ||
          item.descriptionController.text.isNotEmpty ||
          item.selectedSeatImage != null ||
          item.seatImageUrl != null;
    }

    // Check each field for changes
    bool totalQtyChanged = item.totalSeatController.text != originalSeat["totalSeat"];
    bool priceChanged = item.pricePerSeatController.text != originalSeat["price"];
    bool descriptionChanged = item.descriptionController.text != originalSeat["description"];

    // Image changed only if a new file was selected (not just URL comparison)
    bool photoChanged = item.selectedSeatImage != null; // New image picked

    return totalQtyChanged || priceChanged || descriptionChanged || photoChanged;
  }

  /// Updated _saveRestaurant method with proper change detection
  void _saveRestaurant() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // Validation
    if (!isValid) {
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields, including restaurant photo, seat details, and time slots.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (isFromEdit && restaurantModel == null) {
      Get.snackbar(
        "Error",
        "Restaurant data not found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    /// ==================== CHECK FOR CHANGES ====================
    bool hasChanges = false;

    // Check basic fields
    if (restaurantNameTEController.text.trim() != originalData["restaurantName"]) hasChanges = true;
    if (selectedCategoryId != originalData["categoryId"]) hasChanges = true;
    if (openTime?.format(context) != originalData["openTime"]) hasChanges = true;
    if (closeTime?.format(context) != originalData["closeTime"]) hasChanges = true;
    if (locationTEController.text.trim() != originalData["serviceArea"]) hasChanges = true;

    // Check thumbnail (only if a new image was selected)
    if (selectedImage != null) hasChanges = true;

    // Check time slots
    final currentSlots = List<String>.from(timeSlots)..sort();
    final originalSlots = List<String>.from(originalData["timeSlots"] ?? [])..sort();
    if (currentSlots.join(',') != originalSlots.join(',')) hasChanges = true;

    // Check seat items
    bool vipChanged = _seatItemChanged(vipSeatItem, originalData["vipSeat"], "VIP");
    bool normalChanged = _seatItemChanged(normalSeatItem, originalData["normalSeat"], "Normal");
    if (vipChanged || normalChanged) hasChanges = true;

    // Early return if no changes detected
    if (isFromEdit && !hasChanges) {
      Get.snackbar(
        "No Changes",
        "No fields were modified. Nothing to update.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    /// ==================== BUILD PAYLOAD ====================
    Map<String, dynamic> payload = {};

    // Add only changed fields for non-seat data
    if (!isFromEdit || restaurantNameTEController.text.trim() != originalData["restaurantName"]) {
      payload["title"] = restaurantNameTEController.text.trim();
    }

    if (!isFromEdit || selectedCategoryId != originalData["categoryId"]) {
      payload["categoryId"] = selectedCategoryId;
    }

    if (!isFromEdit || openTime?.format(context) != originalData["openTime"]) {
      payload["openTime"] = openTime?.format(context) ?? "";
    }

    if (!isFromEdit || closeTime?.format(context) != originalData["closeTime"]) {
      payload["closeTime"] = closeTime?.format(context) ?? "";
    }

    if (!isFromEdit || locationTEController.text.trim() != originalData["serviceArea"]) {
      payload["serviceArea"] = locationTEController.text.trim();
    }

    // Thumbnail - only if new image selected
    if (!isFromEdit) {
      payload["thumbnail"] = selectedImage ?? selectedImageUrl;
    } else if (selectedImage != null) {
      payload["thumbnail"] = selectedImage;
    }

    // Time slots - only if changed
    if (!isFromEdit) {
      payload["timeSlots"] = timeSlots;
    } else if (currentSlots.join(',') != originalSlots.join(',')) {
      payload["timeSlots"] = timeSlots;
    }

    /// ==================== BUILD SEAT ITEMS ====================
    // IMPORTANT: Always send BOTH seat items with ALL their fields
    // Don't do conditional inclusion - always include both VIP and Normal with complete data
    List<Map<String, dynamic>> items = [
      {
        "seat": "VIP",
        "totalQty": vipSeatItem.totalSeatController.text,
        "price": vipSeatItem.pricePerSeatController.text,
        "description": vipSeatItem.descriptionController.text,
        "photo": vipSeatItem.selectedSeatImage ?? vipSeatItem.seatImageUrl,
      },
      {
        "seat": "Normal",
        "totalQty": normalSeatItem.totalSeatController.text,
        "price": normalSeatItem.pricePerSeatController.text,
        "description": normalSeatItem.descriptionController.text,
        "photo": normalSeatItem.selectedSeatImage ?? normalSeatItem.seatImageUrl,
      }
    ];

    payload["items"] = items;

    /// ==================== API CALL ====================
    bool success;
    if (isFromEdit) {
      success = await _restaurantController.updateRestaurant(
        payload: payload,
        restaurantId: restaurantModel!.sId,
        apiUrl: AppUrls.updateRestaurantUrl(restaurantModel!.sId),
      );
    } else {
      success = await _restaurantController.createRestaurant(
        restaurantName: restaurantNameTEController.text.trim(),
        categoryId: selectedCategoryId!,
        foodType: selectedCategory!,
        openTime: openTime?.format(context) ?? "",
        closeTime: closeTime?.format(context) ?? "",
        serviceArea: locationTEController.text,
        thumbnailImage: selectedImage ?? File(''),
        timeSlots: timeSlots,
        seatItems: [vipSeatItem, normalSeatItem],
        apiUrl: AppUrls.createRestaurantUrl,
      );
    }

    // Result
    if (success) {
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        "Error",
        _restaurantController.errorMessage ?? "Failed to save restaurant",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  /// Disposes of all TextEditingControllers and cleans up resources.
  @override
  void dispose() {
    restaurantNameTEController.dispose();
    locationTEController.dispose();
    vipSeatItem.totalSeatController.dispose();
    vipSeatItem.pricePerSeatController.dispose();
    vipSeatItem.descriptionController.dispose();
    normalSeatItem.totalSeatController.dispose();
    normalSeatItem.pricePerSeatController.dispose();
    normalSeatItem.descriptionController.dispose();
    super.dispose();
  }

  /// Builds the main UI structure of the screen.
  @override
  Widget build(BuildContext context) {
    if (selectedCategory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
    }

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
            isFromEdit ? "Edit Restaurant" : "Add Restaurant",
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: GetBuilder<CategoryController>(builder: (controller){

          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary_1,),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Category",style: AppTextStyle.c_regular_12(),),
                SizedBox(height: 8.h),
                _buildDropdownField(
                  hint: "Select Category",
                  items: foodCategory,
                  selectedValue: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;

                      final selectedCategoryObj = categoryController.categories.firstWhere(
                            (cat) => cat.name == value,
                        orElse: () => ServiceCategory(id: '', name: '', categoryPhoto: ''),
                      );

                      selectedCategoryId = selectedCategoryObj.id.isNotEmpty ? selectedCategoryObj.id : null;
                    });
                    _checkForChanges();
                  },
                ),

                SizedBox(height: 24.h),

                // Main Restaurant Photo
                Text("Add a Photo", style: AppTextStyle.c_light_12()),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 130.h,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.3),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity)
                          : (selectedImageUrl != null && selectedImageUrl!.isNotEmpty
                          ? Image.network(
                        selectedImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : const Center(
                        child: Icon(Icons.upload, size: 28, color: Colors.black54),
                      )),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  (selectedImage != null || (selectedImageUrl != null && selectedImageUrl!.isNotEmpty))
                      ? "Restaurant Photo Selected"
                      : "Not Selected (Restaurant Photo)",
                  style: AppTextStyle.p_medium_12().copyWith(
                    fontWeight: FontWeight.w700,
                    color: (selectedImage != null || (selectedImageUrl != null && selectedImageUrl!.isNotEmpty))
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 8.h),
                Text("Clear, professional photos help customers trust your service",
                    style: AppTextStyle.c_regular_12()),
                SizedBox(height: 24.h),

                // Restaurant Name
                Text("Restaurant Name", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildTextField("Write Name", restaurantNameTEController),
                SizedBox(height: 24.h),

                // Open/Close Time
                Row(
                  children: [
                    Expanded(child: _buildTimePickerField("Open Time", openTime, true)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTimePickerField("Close Time", closeTime, false)),
                  ],
                ),
                SizedBox(height: 24.h),

                // Location
                Text("Location", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildTextField("Set Location", locationTEController, isLocation: true),
                SizedBox(height: 24.h),

                // --- Fixed Two Seat Items Cards (VIP and Normal) ---
                _buildItemCard(vipSeatItem, "VIP"),
                SizedBox(height: 16.h),
                _buildItemCard(normalSeatItem, "Normal"),
                // -----------------------------------------------

                SizedBox(height: 24.h),

                // Add Slot Time
                Text("Add Slot Time", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(child: _buildSlotTimePickerField("Start Time", startSlotTime, true)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildSlotTimePickerField("End Time", endSlotTime, false)),
                  ],
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAddButton(),
                ),
                SizedBox(height: 16.h),

                // Display Time Slots
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(timeSlots.length, (index) {
                    return _buildTimeSlotChip(timeSlots[index], index);
                  }),
                ),
                SizedBox(height: 30.h),

                /// save button
                GetBuilder<AddNewRestaurantController>(
                    builder: (controller) {
                      return _buildSubmitButton(
                        label: isFromEdit ? "Update" : "Save",
                        isEnabled: isValid && !controller.isLoading,
                        isLoading: controller.isLoading,
                        onPressed: _saveRestaurant,
                      );
                    }
                ),

                SizedBox(height: 40.h),
              ],
            ),
          );

        })
    );
  }

  /// ============================ Seat Card =============================
  /// Builds the UI card for a single seat type (VIP or Normal).
  Widget _buildItemCard(SeatItem item, String seatType) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$seatType Seat",
                      style: AppTextStyle.p_medium_12().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: seatType == "VIP" ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(seatType,
                          style: AppTextStyle.p_medium_12().copyWith(
                            color: seatType == "VIP" ? Colors.amber : Colors.blue,
                          )),
                    )
                  ],
                ),
                SizedBox(height: 12.h),

                // Total Seat
                _buildTextField("Total Seats", item.totalSeatController, keyboardType: TextInputType.number),
                SizedBox(height: 8.h),

                // Price per Seat
                _buildTextField("Price per Seat", item.pricePerSeatController, keyboardType: TextInputType.number),
                SizedBox(height: 8.h),

                // Description
                _buildTextField("Description", item.descriptionController, maxLines: 2),
                SizedBox(height: 8.h),

                // Seat Image
                GestureDetector(
                  onTap: () => _showSeatImagePickerDialog(item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 120.h,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.2),
                      child: item.selectedSeatImage != null
                          ? Image.file(item.selectedSeatImage!, fit: BoxFit.cover)
                          : (item.seatImageUrl != null && item.seatImageUrl!.isNotEmpty
                          ? Image.network(item.seatImageUrl!, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.upload, size: 28))),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  (item.selectedSeatImage != null || (item.seatImageUrl != null && item.seatImageUrl!.isNotEmpty))
                      ? "Seat Photo Selected"
                      : "Not Selected (Seat Photo)",
                  style: AppTextStyle.p_medium_12().copyWith(
                    fontWeight: FontWeight.w700,
                    color: (item.selectedSeatImage != null || (item.seatImageUrl != null && item.seatImageUrl!.isNotEmpty))
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================ Helper Widgets ===========================
  /// Builds a standard text input field.
  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool isLocation = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => _checkForChanges(),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      ),
    );
  }

  /// Builds the category dropdown selection field.
  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hint),
        value: selectedValue,
        items: items.map((e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        )).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  /// Builds a clickable field for selecting open/close time.
  Widget _buildTimePickerField(String label, TimeOfDay? time, bool isOpening) {
    return GestureDetector(
      onTap: () => _selectTime(context, isOpening),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)
        ),
        child: Text(time != null ? time.format(context) : label, style: AppTextStyle.c_regular_12()),
      ),
    );
  }

  /// Builds a clickable field for selecting time slot start/end time.
  Widget _buildSlotTimePickerField(String label, TimeOfDay? time, bool isStart) {
    return GestureDetector(
      onTap: () => _selectSlotTime(context, isStart),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)
        ),
        child: Text(time != null ? time.format(context) : label, style: AppTextStyle.c_regular_12()),
      ),
    );
  }

  /// Builds the 'Add Slot Time' button.
  Widget _buildAddButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary_1),
        onPressed: _addSlotTime,
        child: const Text("Add Slot Time"));
  }

  /// Builds a chip for displaying and deleting a time slot.
  Widget _buildTimeSlotChip(String text, int index) {
    return Chip(
      label: Text(text),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _removeSlotTime(index),
    );
  }

  /// Builds the primary 'Save/Update' button at the bottom of the form.
  Widget _buildSubmitButton({required String label, required bool isEnabled, required bool isLoading, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary_1 : Colors.grey.shade300,
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(label),
      ),
    );
  }
}