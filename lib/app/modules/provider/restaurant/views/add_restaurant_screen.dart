import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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

class SeatItem {
  String? selectedSeatType;
  TextEditingController totalSeatController = TextEditingController();
  TextEditingController pricePerSeatController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? selectedSeatImage;

  SeatItem({this.selectedSeatType});
}

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final icons = Assets.icons;

  final AddNewRestaurantController _restaurantController = Get.put(AddNewRestaurantController());

  final restaurantNameTEController = TextEditingController();
  final categoryController=Get.put(CategoryController());

  final List<String> foodCategory = [];
  final List<String> seatTypes = ["VIP", "Normal"];

  String ? selectedCategoryId;

   Result ? restaurantModel;

  String? selectedCategory;
  String? selectedDescriptionType;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  TimeOfDay? startSlotTime;
  TimeOfDay? endSlotTime;

  final List<String> timeSlots = [];
  /// main image thumbnail
  File? selectedImage;

  late SeatItem vipSeatItem;
  late SeatItem normalSeatItem;

  bool isValid = false;
  late final bool isFromEdit;


  @override
  void initState() {
    super.initState();

    // Get arguments safely
    final arguments = Get.arguments ?? {};
    isFromEdit = arguments["isEdit"] ?? false;
    restaurantModel = arguments["restaurant"] as Result?;

    // Initialize seat items
    vipSeatItem = SeatItem(selectedSeatType: "VIP");
    normalSeatItem = SeatItem(selectedSeatType: "Normal");

    // Setup listeners
    _setupInitialListeners();
    restaurantNameTEController.addListener(_checkForChanges);

    // Prefill data if editing
    if (isFromEdit && restaurantModel != null) {
      print("${restaurantModel!.title}");


      print("${restaurantModel!.title}=>>>>>>>>>>>>>>>>>>>");
    }

    // Fetch categories
    categoryController.fetchCategories(AppUrls.restaurantCategoryUrl).then((_) {
      setState(() {
        foodCategory.clear();
        foodCategory.addAll(categoryController.categories.map((e) => e.name));
      });
      _checkForChanges();
    });
  }



  void _setupInitialListeners() {
    vipSeatItem.totalSeatController.addListener(_checkForChanges);
    vipSeatItem.pricePerSeatController.addListener(_checkForChanges);
    vipSeatItem.descriptionController.addListener(_checkForChanges);

    normalSeatItem.totalSeatController.addListener(_checkForChanges);
    normalSeatItem.pricePerSeatController.addListener(_checkForChanges);
    normalSeatItem.descriptionController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    _validateForm();
  }

  void _validateForm() {
    bool timeSlotsAdded = timeSlots.isNotEmpty;

    bool vipValid = vipSeatItem.selectedSeatType != null &&
        vipSeatItem.totalSeatController.text.trim().isNotEmpty &&
        vipSeatItem.pricePerSeatController.text.trim().isNotEmpty &&
        vipSeatItem.descriptionController.text.trim().isNotEmpty &&
        vipSeatItem.selectedSeatImage != null;

    bool normalValid = normalSeatItem.selectedSeatType != null &&
        normalSeatItem.totalSeatController.text.trim().isNotEmpty &&
        normalSeatItem.pricePerSeatController.text.trim().isNotEmpty &&
        normalSeatItem.descriptionController.text.trim().isNotEmpty &&
        normalSeatItem.selectedSeatImage != null;

    bool allFilled = selectedImage != null &&
        selectedCategory != null &&
        openTime != null &&
        closeTime != null &&
        restaurantNameTEController.text.trim().isNotEmpty &&
        timeSlotsAdded &&
        vipValid &&
        normalValid;

    setState(() {
      isValid = allFilled;
    });
  }


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

  Future<void> pickImage(ImageSource source, {required bool isSeatImage, SeatItem? seatItem}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        if (isSeatImage && seatItem != null) {
          seatItem.selectedSeatImage = File(picked.path);
        } else {
          selectedImage = File(picked.path);
        }
      });
      _checkForChanges();
    }
  }

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

  void _removeSlotTime(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
    _checkForChanges();
  }

  void _saveRestaurant() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!isValid || selectedImage == null) {
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields, including the restaurant photo, all seat details, and time slots.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      Get.snackbar("Error", "Category ID is missing!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    List<SeatItem> seatItems = [vipSeatItem, normalSeatItem];

    int totalCapacity = seatItems.fold(
      0,
          (sum, item) =>
      sum + (int.tryParse(item.totalSeatController.text.trim()) ?? 0),
    );

    const restaurantDescription = "Experience our VIP and Normal seating areas with varied price points and exclusive services.";

    if (restaurantDescription.isEmpty) {
      Get.snackbar("Error", "Restaurant description is required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    bool success = await _restaurantController.createRestaurant(
      restaurantName: restaurantNameTEController.text.trim(),
      categoryId: selectedCategoryId!,
      openTime: openTime?.format(context) ?? "",
      closeTime: closeTime?.format(context) ?? "",
      foodType: "Thai Food",
      serviceArea: "Thailand",
      thumbnailImage: selectedImage!,
      timeSlots: timeSlots,
      seatItems: seatItems,
      apiUrl: AppUrls.createRestaurantUrl,
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        "Error",
        _restaurantController.errorMessage ?? "Failed to create restaurant",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }



  @override
  void dispose() {
    restaurantNameTEController.dispose();
    vipSeatItem.totalSeatController.dispose();
    vipSeatItem.pricePerSeatController.dispose();
    vipSeatItem.descriptionController.dispose();
    normalSeatItem.totalSeatController.dispose();
    normalSeatItem.pricePerSeatController.dispose();
    normalSeatItem.descriptionController.dispose();
    super.dispose();
  }

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
                      child: selectedImage == null
                          ? const Center(
                        child: Icon(Icons.upload, size: 28, color: Colors.black54),
                      )
                          : Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  selectedImage == null ? "Not Selected (Restaurant Photo)" : "Restaurant Photo Selected",
                  style: AppTextStyle.p_medium_12().copyWith(
                    fontWeight: FontWeight.w700,
                    color: selectedImage == null ? Colors.red : Colors.green,
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
                _buildTextField("Set Location", null, isLocation: true),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        seatType,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: seatType == "VIP" ? Colors.amber[800] : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Total Seat & Price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Seat", style: AppTextStyle.c_regular_12()),
                          SizedBox(height: 8.h),
                          _buildNumberTextField("0", item.totalSeatController),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price/per seat (\$)", style: AppTextStyle.c_regular_12()),
                          SizedBox(height: 8.h),
                          _buildPriceTextField("0", item.pricePerSeatController),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Seat Image Picker
                Text("Seat Layout/Photo", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                _buildSeatImagePicker(item),
                SizedBox(height: 8.h),
                Text(
                  item.selectedSeatImage == null ? "Not Selected (Seat Photo)" : "Seat Photo Selected",
                  style: AppTextStyle.p_medium_12().copyWith(
                    fontWeight: FontWeight.w700,
                    color: item.selectedSeatImage == null ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 24.h),

                // Description
                Text("Description", style: AppTextStyle.c_regular_12()),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: item.descriptionController,
                  maxLines: 4,
                  minLines: 3,
                  onChanged: (_) => _checkForChanges(),
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: AppTextStyle.c_regular_12(color: AppColors.black_3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSeatImagePicker(SeatItem item) {
    return GestureDetector(
      onTap: () => _showSeatImagePickerDialog(item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: item.selectedSeatImage == null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 28, color: AppColors.primary_1),
                SizedBox(height: 4.h),
                const Text(
                  "Upload Seat Photo",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
              : Image.file(
            item.selectedSeatImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
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
          backgroundColor: isEnabled ? AppColors.primary_1 : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController? controller, {bool isLocation = false}) {
    return TextField(
      controller: controller,
      onChanged: (_) => _checkForChanges(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: isLocation ? const Icon(Icons.location_on_outlined, color: Colors.black54) : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary_1, width: 2)),
      ),
    );
  }

  Widget _buildNumberTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => _checkForChanges(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary_1, width: 2)),
      ),
    );
  }

  Widget _buildPriceTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: (_) => _checkForChanges(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixText: '\$ ',
        prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary_1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary_1, width: 2)),
      ),
    );
  }

  Widget _buildTimePickerField(String hint, TimeOfDay? time, bool isOpening) {
    return GestureDetector(
      onTap: () => _selectTime(context, isOpening),
      child: Container(
        height: 50.h,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                time != null ? time.format(context) : hint,
                style: TextStyle(
                    color: time != null ? Colors.black : Colors.grey,
                    fontSize: 14),
              ),
            ),
          ],
        ),
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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary_1, width: 2)),
      ),
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: (value) {
        onChanged(value);
        _validateForm();
      },
    );
  }

  Widget _buildSlotTimePickerField(String hint, TimeOfDay? time, bool isStart) {
    return GestureDetector(
      onTap: () => _selectSlotTime(context, isStart),
      child: Container(
        height: 50.h,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                time != null ? time.format(context) : hint,
                style: TextStyle(
                    color: time != null ? Colors.black : Colors.grey,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: 120.w,
      height: 40.h,
      child: ElevatedButton(
        onPressed: startSlotTime != null && endSlotTime != null ? _addSlotTime : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: Colors.white),
            SizedBox(width: 4),
            Text(
              "Add",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip(String label, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary_1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.primary_1, fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => _removeSlotTime(index),
            child: const Icon(Icons.close, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }
}