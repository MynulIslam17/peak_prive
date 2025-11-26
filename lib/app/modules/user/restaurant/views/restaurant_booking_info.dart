import 'package:flutter/material.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';

class RestaurantBookingInfo extends StatefulWidget {
  const RestaurantBookingInfo({super.key});

  @override
  State<RestaurantBookingInfo> createState() => _RestaurantBookingInfoState();
}

class _RestaurantBookingInfoState extends State<RestaurantBookingInfo> {
  String? _selectedSeatType = 'VIP';
  final TextEditingController _bookingSeatController = TextEditingController(text: '10');

  String? _selectedDate ;
  String? _selectedTime ;
  String? _selectedSlot;

  final Color goldColor = const Color(0xFFD4AF37);
  final Color lightGoldColor = const Color(0xFFFAF6EB);
  final Color textColor = Colors.black;
  final Color greyTextColor = Colors.grey[600]!;
  final Color whiteColor = Colors.white; // Explicit white color

  // Example backend slot data, now matching the format in the image
  final List<String> backendSlots = [
    '10:00 AM - 12:00 PM',
    '10:00 AM - 3:00 PM',
    '10:00 AM - 5:00 PM',
    '10:00 AM - 5:00 PM',
    '10:00 AM - 8:00 PM',
    '10:00 AM - 9e`:00 PM',
  ];

  // --- Date/Time Picker Methods ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.day}/${picked.month}/${picked.year % 100}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context);
      });
    }
  }

  // --- Widget Builder Methods ---

  Widget _buildSeatDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedSeatType,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: TextStyle(fontSize: 16, color: textColor),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSeatType = newValue;
            });
          },
          items: <String>['VIP', 'Standard', 'Window Seat']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingSeatField() {
    return TextField(
      controller: _bookingSeatController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: goldColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(fontSize: 16, color: textColor),
    );
  }

  Widget _buildDateTimeSelector() {
    final String dateText = _selectedDate ?? 'Select Date';
    final String timeText = _selectedTime ?? 'Select Time';

    return GestureDetector(
      onTap: () async {
        await _selectDate(context);
        if (mounted) {
          await _selectTime(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  dateText,
                  style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate == null ? Colors.grey : textColor),
                ),
              ],
            ),
            Text(
              timeText,
              style: TextStyle(
                  fontSize: 16,
                  color: _selectedTime == null ? Colors.grey : textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid(List<String> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 3.5, // Adjusted to better fit content
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final String slot = slots[index];
        final bool isSelected = _selectedSlot == slot;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSlot = isSelected ? null : slot;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // Added horizontal padding
            alignment: Alignment.centerLeft, // Align content to start
            decoration: BoxDecoration(
              color: whiteColor, // Always white background for the slot box itself
              border: Border.all(
                color: Colors.grey.shade300, // Light grey border
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Keep row content compact
              children: [
                Container(
                  width: 24, // Size of the radio circle
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary_1 : Colors.grey.shade400, // Border color
                      width: 1.5,
                    ),
                    color: whiteColor,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isSelected ? 12 : 0, // Inner dot size
                      height: isSelected ? 12 : 0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goldColor, // Inner dot color
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7), // Space between circle and text
                Text(
                  slot,
                  style: TextStyle(
                    color: textColor, // Slot text is always black
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? goldColor : textColor,
          ),
        ),
      ],
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Choose Seat Type
                  Text(
                    'Choose seat',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildSeatDropdown(),
                  const SizedBox(height: 20),

                  // Booking Seat
                  Text(
                    'Booking seat',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildBookingSeatField(),
                  const SizedBox(height: 20),

                  // Select Start Date & Time
                  Text(
                    'Select Start Date & Time',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTimeSelector(),
                  const SizedBox(height: 20),

                  // Slot Book Section (using the grid method for UI)
                  Text(
                    'Slot Book',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeSlotGrid(backendSlots), // Slot UI is generated here
                  const SizedBox(height: 30),

                  // Booking Summary
                  Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                  ),
                    child:Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      child: Column(
                        children: [
                          _buildSummaryRow('Total Seat', '\$250.00'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Services Fee', '\$25.00'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Total', '\$275.00', isTotal: true),
                        ],
                      ),
                    ),
                  )


                ],
              ),
            ),
          ),

          // Booking Confirm Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Booking Confirm logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Booking Confirm',
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bookingSeatController.dispose();
    super.dispose();
  }
}

