import 'dart:io';
import 'package:flutter/material.dart';
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

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class SeatItem {
  String? sId;
  String? selectedSeatType;
  TextEditingController totalSeatController = TextEditingController();
  TextEditingController pricePerSeatController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? selectedSeatImage;
  String? seatImageUrl;

  SeatItem({this.selectedSeatType, this.seatImageUrl, this.sId});
}

class TimeSlotItem {
  String? sId;
  String timeString;

  TimeSlotItem({required this.timeString, this.sId});
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {

  // ── Controllers ──
  final _restaurantController = Get.put(AddNewRestaurantController());
  final _categoryController   = Get.put(CategoryController());
  final _nameTEC      = TextEditingController();
  final _locationTEC  = TextEditingController();

  // ── State ──
  late final bool isFromEdit;
  Result? restaurantModel;

  final List<String>       foodCategory = [];
  final List<TimeSlotItem> timeSlots    = [];

  String?    selectedCategory;
  String?    selectedCategoryId;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  TimeOfDay? startSlotTime;
  TimeOfDay? endSlotTime;

  File?   selectedImage;
  String? selectedImageUrl;

  late SeatItem vipSeatItem;
  late SeatItem normalSeatItem;

  bool isValid = false;

  // originalData is only meaningful in edit mode
  Map<String, dynamic> originalData = {};

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    isFromEdit      = args["isEdit"] ?? false;
    restaurantModel = args["restaurant"] as Result?;

    vipSeatItem    = SeatItem(selectedSeatType: "VIP");
    normalSeatItem = SeatItem(selectedSeatType: "Normal");

    _addSeatListeners();
    _nameTEC.addListener(_validateForm);
    _locationTEC.addListener(_validateForm);

    // Populate fields first so originalData captures correct values
    if (isFromEdit && restaurantModel != null) {
      _populateEditFields();
    }

    // Fetch categories, then set selectedCategory + store original data
    _categoryController.fetchCategories(AppUrls.restaurantCategoryUrl).then((_) {
      setState(() {
        foodCategory
          ..clear()
          ..addAll(_categoryController.categories.map((e) => e.name));

        if (isFromEdit && restaurantModel != null) {
          selectedCategory = restaurantModel!.category!.name;
          selectedCategoryId = _resolveCategory(selectedCategory)?.id;
        }
      });

      // Store baseline AFTER categories are loaded so categoryId comparison works
      if (isFromEdit && restaurantModel != null) {
        _storeOriginalData();
      }

      _validateForm();
    });
  }

  @override
  void dispose() {
    _nameTEC.dispose();
    _locationTEC.dispose();
    vipSeatItem.totalSeatController.dispose();
    vipSeatItem.pricePerSeatController.dispose();
    vipSeatItem.descriptionController.dispose();
    normalSeatItem.totalSeatController.dispose();
    normalSeatItem.pricePerSeatController.dispose();
    normalSeatItem.descriptionController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SETUP HELPERS
  // ─────────────────────────────────────────────

  void _addSeatListeners() {
    for (final ctrl in [
      vipSeatItem.totalSeatController,
      vipSeatItem.pricePerSeatController,
      vipSeatItem.descriptionController,
      normalSeatItem.totalSeatController,
      normalSeatItem.pricePerSeatController,
      normalSeatItem.descriptionController,
    ]) {
      ctrl.addListener(_validateForm);
    }
  }

  void _populateEditFields() {
    final r = restaurantModel!;
    selectedCategory   = r.category!.name;
    _nameTEC.text      = r.title;
    _locationTEC.text  = r.serviceArea;
    selectedImageUrl   = r.thumbnail;
    openTime           = _parseTime(r.openTime);
    closeTime          = _parseTime(r.closeTime);

    timeSlots
      ..clear()
      ..addAll(r.slots.map((s) =>
          TimeSlotItem(timeString: "${s.startTime} - ${s.endTime}", sId: s.sId)));

    for (final item in r.items) {
      final seat = item.seat == "VIP" ? vipSeatItem : normalSeatItem;
      seat.sId = item.sId;
      seat.descriptionController.text    = item.description;
      seat.pricePerSeatController.text   = item.price.toString();
      seat.totalSeatController.text      = item.totalQty.toString();
      seat.seatImageUrl                  = item.photo;
    }
  }

  void _storeOriginalData() {
    final sortedSlots = timeSlots.map((e) => e.timeString).toList()..sort();
    originalData = {
      "restaurantName": restaurantModel!.title,
      "categoryId"    : selectedCategoryId,
      "openTime"      : restaurantModel!.openTime,
      "closeTime"     : restaurantModel!.closeTime,
      "serviceArea"   : restaurantModel!.serviceArea,
      "thumbnail"     : restaurantModel!.thumbnail,
      "timeSlots"     : sortedSlots,
      "vipSeat": {
        "totalSeat"  : vipSeatItem.totalSeatController.text,
        "price"      : vipSeatItem.pricePerSeatController.text,
        "description": vipSeatItem.descriptionController.text,
        "photo"      : vipSeatItem.seatImageUrl,
      },
      "normalSeat": {
        "totalSeat"  : normalSeatItem.totalSeatController.text,
        "price"      : normalSeatItem.pricePerSeatController.text,
        "description": normalSeatItem.descriptionController.text,
        "photo"      : normalSeatItem.seatImageUrl,
      },
    };
  }

  // ─────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────

  void _validateForm() {
    final bool hasMainImage =
        selectedImage != null || (selectedImageUrl?.isNotEmpty ?? false);

    final bool vipValid = _isSeatValid(vipSeatItem);
    final bool normalValid = _isSeatValid(normalSeatItem);

    final bool allFilled = hasMainImage &&
        selectedCategory != null &&
        openTime != null &&
        closeTime != null &&
        _nameTEC.text.trim().isNotEmpty &&
        _locationTEC.text.trim().isNotEmpty &&
        timeSlots.isNotEmpty &&
        vipValid &&
        normalValid;

    // In edit mode, also require at least one field to have changed
    final bool hasChanges = !isFromEdit || _detectChanges();

    setState(() => isValid = allFilled && hasChanges);
  }

  bool _isSeatValid(SeatItem item) =>
      item.selectedSeatType != null &&
          item.totalSeatController.text.trim().isNotEmpty &&
          item.pricePerSeatController.text.trim().isNotEmpty &&
          item.descriptionController.text.trim().isNotEmpty &&
          (item.selectedSeatImage != null ||
              (item.seatImageUrl?.isNotEmpty ?? false));

  // Returns true if anything changed compared to originalData
  bool _detectChanges() {
    if (originalData.isEmpty) return false;

    if (_nameTEC.text.trim() != originalData["restaurantName"])  return true;
    if (selectedCategoryId    != originalData["categoryId"])     return true;
    if (_formatTime(openTime) != originalData["openTime"])       return true;
    if (_formatTime(closeTime) != originalData["closeTime"])     return true;
    if (_locationTEC.text.trim() != originalData["serviceArea"]) return true;
    if (selectedImage != null)                                   return true;

    final currentSlots = timeSlots.map((e) => e.timeString).toList()..sort();
    final origSlots    = List<String>.from(originalData["timeSlots"] ?? [])..sort();
    if (currentSlots.join(',') != origSlots.join(','))           return true;

    if (_seatChanged(vipSeatItem,    originalData["vipSeat"]))    return true;
    if (_seatChanged(normalSeatItem, originalData["normalSeat"])) return true;

    return false;
  }

  bool _seatChanged(SeatItem item, Map<String, dynamic>? orig) {
    if (orig == null) return true;
    return item.totalSeatController.text    != orig["totalSeat"]   ||
        item.pricePerSeatController.text != orig["price"]       ||
        item.descriptionController.text  != orig["description"] ||
        item.selectedSeatImage           != null;
  }

  // ─────────────────────────────────────────────
  // TIME HELPERS
  // ─────────────────────────────────────────────

  /// Formats a TimeOfDay to 12-hour string e.g. "6:05 AM"
  String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour   = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final min    = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$min $period";
  }

  /// Parses "10:30 AM" → TimeOfDay
  TimeOfDay _parseTime(String s) {
    try {
      final parts  = s.split(RegExp(r'[:\s]'));
      if (parts.length < 2) return TimeOfDay.now();
      int hour     = int.parse(parts[0]);
      final minute = int.parse(parts[1].replaceAll(RegExp(r'\D'), ''));
      if (s.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (s.toUpperCase().contains('AM') && hour == 12) hour  = 0;
      return TimeOfDay(hour: hour % 24, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  /// Returns true if [end] is strictly after [begin]
  bool _isTimeAfter(TimeOfDay begin, TimeOfDay end) =>
      end.hour * 60 + end.minute > begin.hour * 60 + begin.minute;

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  ServiceCategory? _resolveCategory(String? name) {
    if (name == null) return null;
    try {
      return _categoryController.categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage({required bool isSeat, SeatItem? seatItem}) async {
    ImagePickerDialogService.show(
      context: context,
      title: isSeat ? "Add Seat Photo/Layout" : "Add Restaurant Photo",
      subtitle: "Choose from gallery or take a new photo",
      galleryLabel: "Gallery",
      gallerySubtitle: "Choose from your photos",
      cameraLabel: "Camera",
      cameraSubtitle: "Take a new photo",
      primaryColor: AppColors.primary_1,
      galleryIconColor: Colors.blue,
      cameraIconColor: Colors.orange,
      onImageSourceSelected: (source) async {
        final picked = await ImagePicker().pickImage(source: source);
        if (picked == null) return;
        setState(() {
          if (isSeat && seatItem != null) {
            seatItem.selectedSeatImage = File(picked.path);
            seatItem.seatImageUrl      = null;
          } else {
            selectedImage    = File(picked.path);
            selectedImageUrl = null;
          }
        });
        _validateForm();
      },
    );
  }

  Future<void> _selectOpenCloseTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isOpen ? openTime : closeTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;

    // Validate: closeTime must be after openTime
    if (!isOpen && openTime != null && !_isTimeAfter(openTime!, picked)) {
      _showError("Close time must be after open time.");
      return;
    }
    if (isOpen && closeTime != null && !_isTimeAfter(picked, closeTime!)) {
      _showError("Open time must be before close time.");
      return;
    }

    setState(() => isOpen ? openTime = picked : closeTime = picked);
    _validateForm();
  }

  Future<void> _selectSlotTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? startSlotTime : endSlotTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => isStart ? startSlotTime = picked : endSlotTime = picked);
  }

  void _addSlot() {
    if (startSlotTime == null || endSlotTime == null) return;

    if (!_isTimeAfter(startSlotTime!, endSlotTime!)) {
      _showError("End time must be after start time.");
      return;
    }

    setState(() {
      timeSlots.add(TimeSlotItem(
        timeString: "${_formatTime(startSlotTime)} - ${_formatTime(endSlotTime)}",
      ));
      startSlotTime = null;
      endSlotTime   = null;
    });
    _validateForm();
  }

  void _removeSlot(int index) {
    setState(() => timeSlots.removeAt(index));
    _validateForm();
  }

  void _showError(String msg) {
    Get.snackbar("Validation", msg,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  // ─────────────────────────────────────────────
  // SAVE / UPDATE
  // ─────────────────────────────────────────────

  void _save() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!isValid) {
      _showError("Please fill all required fields.");
      return;
    }

    final slots = timeSlots.map((s) {
      final parts = s.timeString.split(' - ');
      final m = <String, dynamic>{"startTime": parts[0], "endTime": parts[1]};
      if (isFromEdit && s.sId != null) m["_id"] = s.sId!;
      return m;
    }).toList();

    final items = [
      _buildSeatMap(vipSeatItem,    "VIP"),
      _buildSeatMap(normalSeatItem, "Normal"),
    ];

    bool success;

    if (isFromEdit) {
      final payload = <String, dynamic>{};

      if (_nameTEC.text.trim()     != originalData["restaurantName"]) payload["title"]       = _nameTEC.text.trim();
      if (selectedCategoryId       != originalData["categoryId"])     payload["categoryId"]  = selectedCategoryId;
      if (_formatTime(openTime)    != originalData["openTime"])       payload["openTime"]    = _formatTime(openTime);
      if (_formatTime(closeTime)   != originalData["closeTime"])      payload["closeTime"]   = _formatTime(closeTime);
      if (_locationTEC.text.trim() != originalData["serviceArea"])    payload["serviceArea"] = _locationTEC.text.trim();
      if (selectedImage != null)                                      payload["thumbnail"]   = selectedImage;

      payload["slots"] = slots;
      payload["items"] = items;

      success = await _restaurantController.updateRestaurant(
        payload: payload,
        restaurantId: restaurantModel!.sId,
        apiUrl: AppUrls.updateRestaurantUrl(restaurantModel!.sId),
      );
    } else {
      success = await _restaurantController.createRestaurant(
        restaurantName: _nameTEC.text.trim(),
        categoryId:     selectedCategoryId!,
        foodType:       selectedCategory!,
        openTime:       _formatTime(openTime),
        closeTime:      _formatTime(closeTime),
        serviceArea:    _locationTEC.text,
        thumbnailImage: selectedImage ?? File(''),
        timeSlots:      timeSlots.map((e) => e.timeString).toList(),
        seatItems:      [vipSeatItem, normalSeatItem],
        apiUrl:         AppUrls.createRestaurantUrl,
      );
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError(_restaurantController.errorMessage ?? "Failed to save restaurant.");
    }
  }

  Map<String, dynamic> _buildSeatMap(SeatItem item, String type) => {
    "seat"    : type,
    if (isFromEdit && item.sId != null) "_id": item.sId,
    "totalQty": item.totalSeatController.text,
    "price"   : item.pricePerSeatController.text,
    "description": item.descriptionController.text,
    "photo"   : item.selectedSeatImage ?? item.seatImageUrl,
  };

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

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
          isFromEdit ? "Edit Restaurant" : "Add Restaurant",
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<CategoryController>(builder: (catCtrl) {
        if (catCtrl.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary_1));
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Category"),
              SizedBox(height: 8.h),
              _buildDropdown(),

              SizedBox(height: 24.h),
              _label("Add a Photo"),
              SizedBox(height: 10.h),
              _buildImagePicker(
                image: selectedImage,
                imageUrl: selectedImageUrl,
                onTap: () => _pickImage(isSeat: false),
                label: "Restaurant Photo",
              ),

              SizedBox(height: 24.h),
              _label("Restaurant Name"),
              SizedBox(height: 8.h),
              _buildTextField("Write Name", _nameTEC),

              SizedBox(height: 24.h),
              Row(children: [
                Expanded(child: _buildTimePicker("Open Time",  openTime,  true)),
                SizedBox(width: 16.w),
                Expanded(child: _buildTimePicker("Close Time", closeTime, false)),
              ]),

              SizedBox(height: 24.h),
              _label("Location"),
              SizedBox(height: 8.h),
              _buildTextField("Set Location", _locationTEC),

              SizedBox(height: 24.h),
              _buildSeatCard(vipSeatItem,    "VIP"),
              SizedBox(height: 16.h),
              _buildSeatCard(normalSeatItem, "Normal"),

              SizedBox(height: 24.h),
              _label("Add Slot Time"),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(child: _buildSlotTimePicker("Start Time", startSlotTime, true)),
                SizedBox(width: 16.w),
                Expanded(child: _buildSlotTimePicker("End Time",   endSlotTime,   false)),
              ]),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: _buildAddSlotButton(),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(timeSlots.length,
                        (i) => _buildSlotChip(timeSlots[i], i)),
              ),

              SizedBox(height: 30.h),
              GetBuilder<AddNewRestaurantController>(builder: (ctrl) {
                return _buildSubmitButton(
                  label:     isFromEdit ? "Update" : "Save",
                  isEnabled: isValid && !ctrl.isLoading,
                  isLoading: ctrl.isLoading,
                  onPressed: _save,
                );
              }),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET BUILDERS
  // ─────────────────────────────────────────────

  Widget _label(String text) =>
      Text(text, style: AppTextStyle.c_regular_12());

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => _validateForm(),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
            border: InputBorder.none, contentPadding: EdgeInsets.zero),
        hint: Text("Select Category",
            style: AppTextStyle.c_regular_12()
                .copyWith(color: Colors.grey.shade600)),
        value: selectedCategory,
        items: foodCategory
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedCategory   = val;
            selectedCategoryId = _resolveCategory(val)?.id;
          });
          _validateForm();
        },
      ),
    );
  }

  Widget _buildImagePicker({
    required File? image,
    required String? imageUrl,
    required VoidCallback onTap,
    required String label,
  }) {
    final hasImage = image != null || (imageUrl?.isNotEmpty ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130.h,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.3),
              child: image != null
                  ? Image.file(image, fit: BoxFit.cover, width: double.infinity)
                  : (imageUrl?.isNotEmpty ?? false)
                  ? Image.network(imageUrl!, fit: BoxFit.cover,
                  width: double.infinity)
                  : const Center(
                  child: Icon(Icons.upload, size: 28,
                      color: Colors.black54)),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          hasImage ? "$label Selected" : "Not Selected ($label)",
          style: AppTextStyle.p_medium_12().copyWith(
            fontWeight: FontWeight.w700,
            color: hasImage ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, bool isOpen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectOpenCloseTime(isOpen),
          child: Container(
            height: 45.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              time != null ? _formatTime(time) : "Select Time",
              style: AppTextStyle.c_regular_12().copyWith(
                color: time == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotTimePicker(String label, TimeOfDay? time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectSlotTime(isStart),
          child: Container(
            height: 45.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              time != null ? _formatTime(time) : "Select Time",
              style: AppTextStyle.c_regular_12().copyWith(
                color: time == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton() {
    final enabled = startSlotTime != null && endSlotTime != null;
    return SizedBox(
      height: 45.h,
      width: 100.w,
      child: ElevatedButton(
        onPressed: enabled ? _addSlot : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("Add Slot",
            style: AppTextStyle.c_regular_12()
                .copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildSlotChip(TimeSlotItem slot, int index) {
    return Chip(
      label: Text(slot.timeString,
          style: AppTextStyle.c_regular_12()
              .copyWith(color: AppColors.primary_1)),
      backgroundColor: AppColors.primary_1.withOpacity(0.1),
      deleteIcon:
      const Icon(Icons.close, size: 16, color: AppColors.primary_1),
      onDeleted: () => _removeSlot(index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.primary_1.withOpacity(0.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    );
  }

  Widget _buildSeatCard(SeatItem item, String seatType) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$seatType Seat",
                    style: AppTextStyle.p_medium_12()
                        .copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (seatType == "VIP"
                        ? Colors.amber
                        : Colors.blue)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(seatType,
                      style: AppTextStyle.p_medium_12().copyWith(
                        color: seatType == "VIP"
                            ? Colors.amber
                            : Colors.blue,
                      )),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            _buildTextField("Total Seats",    item.totalSeatController,
                keyboardType: TextInputType.number),
            SizedBox(height: 8.h),
            _buildTextField("Price per Seat", item.pricePerSeatController,
                keyboardType: TextInputType.number),
            SizedBox(height: 8.h),
            _buildTextField("Description",   item.descriptionController,
                maxLines: 2),
            SizedBox(height: 8.h),

            _buildImagePicker(
              image:    item.selectedSeatImage,
              imageUrl: item.seatImageUrl,
              onTap:    () => _pickImage(isSeat: true, seatItem: item),
              label:    "Seat Photo",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isEnabled,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary_1
              : AppColors.primary_1.withOpacity(0.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}