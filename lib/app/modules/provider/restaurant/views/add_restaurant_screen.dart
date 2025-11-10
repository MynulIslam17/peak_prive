import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Assuming this path is correct
import 'package:harry_service_app/app/core/constants/text-style.dart';
import '../../../../../gen/assets.gen.dart';
// Assuming this path is correct
import '../../../../core/constants/app_colors.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  // --- Controllers ---
  final restaurantNameTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final capacityTEController = TextEditingController();

  // --- Dropdown States ---
  String? selectedCategory;
  String? selectedMealType;
  String? selectedPriceRange;

  // --- Time States ---
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  // --- Dynamic Service Input Fields ---
  final List<Map<String, TextEditingController>> serviceFields = [
    {
      "title": TextEditingController(),
      "service": TextEditingController(),
    }
  ];

  @override
  void dispose() {
    restaurantNameTEController.dispose();
    locationTEController.dispose();
    capacityTEController.dispose();

    for (var field in serviceFields) {
      field["title"]?.dispose();
      field["service"]?.dispose();
    }
    super.dispose();
  }

  // Helper to format TimeOfDay for display
  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  // Time Picker Function
  Future<void> _selectTime(bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  // Add Dynamic Service Field
  void _addServiceField() {
    setState(() {
      serviceFields.add({
        "title": TextEditingController(),
        "service": TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy AppColors class (since it's not provided)
    const primaryColor = Color(0xFFD6B25E); // Using a gold color for primary
    const AppColors = (primary_1: primaryColor);

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
          "Add Restaurant",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Category Dropdown
            Text("Category", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField(
              "Select Category",
              ["Chinese Food", "German Food", "Italian Food", "Fast Food"],
              selectedCategory,
                  (value) => setState(() => selectedCategory = value),
            ),
            SizedBox(height: 20.h),

            /// Add a Service Photo
            Text("Add a Service Photo", style: AppTextStyle.c_light_12()),
            SizedBox(height: 10.h),
            _buildImagePickerContainer(),
            SizedBox(height: 12.h),
            Text(
              "Clear, professional photos help customers trust your service",
              style: AppTextStyle.c_regular_12(),
            ),
            SizedBox(height: 24.h),

            /// Restaurant Name
            Text("Restaurant Name", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("Restaurant Name", restaurantNameTEController),
            SizedBox(height: 20.h),

            /// Open Time / Close Time (Side by Side)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Open Time", style: AppTextStyle.c_regular_12()),
                      SizedBox(height: 8.h),
                      _buildTimePickerField(true, openTime),
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
                      _buildTimePickerField(false, closeTime),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            /// Location (Map Picker)
            Text("Location", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildLocationField("Select Location", locationTEController),
            SizedBox(height: 20.h),

            /// Meal Type Dropdown
            Text("Meal Type", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField(
              "Available Type",
              ["Breakfast", "Lunch", "Dinner", "Snacks"],
              selectedMealType,
                  (value) => setState(() => selectedMealType = value),
            ),
            SizedBox(height: 20.h),

            /// Price Range Dropdown
            Text("Price Range", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildDropdownField(
              "\$\$\$",
              ["\$ (Low)", "\$\$ (Medium)", "\$\$\$ (High)"],
              selectedPriceRange,
                  (value) => setState(() => selectedPriceRange = value),
            ),
            SizedBox(height: 20.h),

            /// Capacity
            Text("total Seat", style: AppTextStyle.c_regular_12()),
            SizedBox(height: 8.h),
            _buildTextField("Capacity", capacityTEController),
            SizedBox(height: 20.h),

            /// Dynamic Service Fields
            for (int i = 0; i < serviceFields.length; i++) ...[
              Text("Service Title", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("Service Title (e.g. Free Wi-Fi)", serviceFields[i]["title"]!),
              SizedBox(height: 16.h),
              Text("Service Detail", style: AppTextStyle.c_regular_12()),
              SizedBox(height: 8.h),
              _buildTextField("Detail (e.g. High-Speed 5G)", serviceFields[i]["service"]!),
              SizedBox(height: 20.h),
            ],

            _buildAddMoreButton(),
            SizedBox(height: 24.h),

            /// Save Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary_1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  /// --- Reusable Widgets ---

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
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

  Widget _buildImagePickerContainer() {
    return Container(
      height: 54.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.upload, size: 28, color: Colors.black54),
    );
  }

  /// Dropdown field for strings
  Widget _buildDropdownField(
      String hint,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: selectedValue,
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
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Time picker field
  Widget _buildTimePickerField(bool isOpening, TimeOfDay? time) {
    return InkWell(
      onTap: () => _selectTime(isOpening),
      child: Container(
        height: 48.h, // Adjusted height for visibility
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(time),
              style: TextStyle(
                color: time == null ? Colors.grey : Colors.black87,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.access_time, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Location field with map icon
  Widget _buildLocationField(String hint, TextEditingController controller) {
    return InkWell(
      onTap: () {
        // Simulating map selection as in the previous screen.
        setState(() {
          controller.text = "123 Main Street, City Centre";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location selected (Simulated)')),
        );
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: controller.text.isEmpty ? hint : controller.text,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFD6B25E)),
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

  /// Add more button for dynamic service fields
  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: _addServiceField,
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