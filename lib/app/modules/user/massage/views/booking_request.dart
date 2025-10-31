import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';

class BookingRequest extends StatefulWidget {
  const BookingRequest({super.key});

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  final images = Assets.images;
  final icons = Assets.icons;

  List<double> durations = [30, 60, 90];

  double? selectedDuration;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController requestTEController=TextEditingController();

  /// show date picker method
  Future<void> showDatePick() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// show time picker method
  Future<void> showTimePick() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// appbar
      appBar: AppBar(
        title: Text("Booking Request "),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: icons.caretLeft.svg(color: Colors.black, width: 30, height: 30),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// selectable duration
            Text(
              "Duration",
              style: AppTextStyle.c_regular_12(color: AppColors.black_3),
            ),

            Row(
              children: [
                ...durations.map((time) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedDuration = time;
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 105,
                        decoration: BoxDecoration(
                          color: time == selectedDuration
                              ? AppColors.primary_1
                              : Colors.black.withOpacity(0.2),

                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 7,
                            ),
                            child: Center(
                              child: Text(
                                "${time} mins (\$115)",
                                style: AppTextStyle.c_regular_12().copyWith(
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),

            /// choose date
            Text(
              "Select Date",
              style: AppTextStyle.c_regular_12(color: AppColors.black_3),
            ),

            SizedBox(height: 10.h),

            InkWell(
              /// date picker
              onTap: showDatePick,
              child: Container(
                height: 35.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: icons.calendarDots.svg(height: 25, width: 25),
                    ),

                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                      style: AppTextStyle.sub_h3_regular_14().copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10.h),

            /// time picker
            Text(
              "Select Time",
              style: AppTextStyle.c_regular_12(color: AppColors.black_3),
            ),
            SizedBox(height: 10.h,),
            InkWell(
              /// time picker
              onTap: showTimePick,
              child: Container(
                height: 35.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: icons.time.svg(height: 25, width: 25),
                    ),


                    Text(
                      selectedTime == null
                          ? "Select time"
                          : "${selectedTime!.hourOfPeriod.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')} ${selectedTime!.hour >= 12 ? 'PM' : 'AM'}",
                      style: AppTextStyle.sub_h3_regular_14().copyWith(fontSize: 13),
                    )




                  ],
                ),
              ),
            ),

            SizedBox(height: 10.h,),
            Text(
              "Enter Your Special Request (optional)",
              style: AppTextStyle.c_regular_12(color: AppColors.black_3),
            ),

            SizedBox(height: 10.h,),

            TextField(

              maxLines: 4,
              controller: requestTEController,

              decoration: InputDecoration(

                hintText: "Your Request",
                hintStyle: AppTextStyle.sub_h3_regular_14().copyWith(color: Colors.black.withOpacity(0.4)),


                border: OutlineInputBorder(

                  borderSide: BorderSide(
                   color: Colors.black.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8)
                )
              ),


            ),


            Spacer(),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(children: [

                Text("\$9.99",style: AppTextStyle.sub_h1_medium_18(),),
                SizedBox(width: 10.w,),

                Expanded(child: CustomButton(text: "Book Now"))


              ],),
            )




          ],
        ),
      ),
    );
  }





}
