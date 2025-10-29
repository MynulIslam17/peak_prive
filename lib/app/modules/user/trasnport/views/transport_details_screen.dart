import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/app/core/widgets/provider_info.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/custome_back_button.dart';

class TransportDetailsScreen extends StatefulWidget {
  const TransportDetailsScreen({super.key});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  final image = Assets.images;
  final icon = Assets.icons;

  bool _isRentClicked = false;
  DateTime? selectedDate;

  /// Pick date and time
  Future<void> _datePicker() async {
    // Pick date first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Pick time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    // Combine date and time
    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            /// Background image
            image.carImg1.image(height: size.height * 0.4,width: double.infinity, fit: BoxFit.cover),

            /// Overlay card
            Positioned(
              top:size.height * 0.33,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  color:  Color(0xffFDFAF6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      /// line image
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: image.line.image(),
                      ),

                      /// hide this whole section when click on rent car
                      if (_isRentClicked) ...[

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(


                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "CHR 100XL",
                                      style: AppTextStyle.sub_h1_medium_18(),
                                    ),
                                    Text(
                                      "\$100",
                                      style: AppTextStyle.sub_h3_medium_14(
                                        color: AppColors.primary_1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),

                                Card(
                                  color: const Color(0xFFFDFAF6),
                                  child: SizedBox(
                                    height: 100.h,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            // Start Date
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Select Start Date & Time",
                                                    style:
                                                    AppTextStyle.sub_h3_medium_14()
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: _datePicker,
                                                    child: Container(
                                                      width: 155.w,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                      ),
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          icon.calendarDots.svg(
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          SizedBox(width: 5.w),
                                                          Text(
                                                            selectedDate == null
                                                                ? "Select Date & Time"
                                                                : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                                                "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                                                "${selectedDate!.year} "
                                                                "${selectedDate!.hour.toString().padLeft(2, '0')}:"
                                                                "${selectedDate!.minute.toString().padLeft(2, '0')}",
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            // End Date
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Select End Date & Time",
                                                    style:
                                                    AppTextStyle.sub_h3_medium_14()
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: _datePicker,
                                                    child: Container(
                                                      width: 155.w,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                      ),
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          icon.calendarDots.svg(
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          SizedBox(width: 5.w),
                                                          Text(
                                                            selectedDate == null
                                                                ? "Select Date & Time"
                                                                : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                                                "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                                                "${selectedDate!.year} "
                                                                "${selectedDate!.hour.toString().padLeft(2, '0')}:"
                                                                "${selectedDate!.minute.toString().padLeft(2, '0')}",
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),


                              ],
                            ),
                          ),
                        ),

                        /// checkout info fixed at bottom======

                        Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Color(0xffE7E7E7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Time
                                icon.time.svg(width: 16.w, height: 16.h),
                                SizedBox(width: 6.w),
                                Text(
                                  "30 min",
                                  style: AppTextStyle.p_regular_12(),
                                ),

                                SizedBox(width: 12.w),
                                Container(
                                  height: 20.h,
                                  width: 2.w,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12.w),

                                // Car count
                                icon.carProfile.svg(
                                  width: 16.w,
                                  height: 16.h,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "1 Car",
                                  style: AppTextStyle.p_regular_12(),
                                ),

                                SizedBox(width: 12.w),
                                Container(
                                  height: 20.h,
                                  width: 2.w,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12.w),

                                // Price
                                icon.currencyCircleDollar.svg(
                                  width: 16.w,
                                  height: 16.h,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "\$10",
                                  style: AppTextStyle.p_regular_12(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: CustomButton(
                            text: "Checkout",
                            width: double.infinity,
                            onTap: () {},
                          ),
                        )




                      ] else ...[

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ///provider Info part
                                ProviderInfo(
                                  onTapCall: () {},
                                  onTapMessage: () {},
                                ),
                                SizedBox(height: 10.h),

                                Text(
                                  "The sleek car roared to life, its engine hummingleek car roared to life, its engine humming with power as it glided effortlesleek car roared to life, its engine humming with power as it glided effortlesleek car roared to life, its engine humming with power as it glided effortlesleek car roared to life, its engine humming with power as it glided effortles with power as it glided effortlessly down the road, embodying speed, elegance, and precision.",
                                  style: AppTextStyle.p_regular_12().copyWith(
                                    fontSize: 14.sp,
                                    color: AppColors.black_2,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        /// upfront cost
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Upfront Cost",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                            Text(
                                              "\$100",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                          ],
                                        ),

                                        /// insurance
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Insurance Fees",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                            Text(
                                              "\$200",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Maintain  Charge",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                            Text(
                                              "\$40",
                                              style:
                                              AppTextStyle.sub_h3_medium_14(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        /// rent options Button fixed
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: Row(
                            children: [
                              Text(
                                "\$120",
                                style: AppTextStyle.sub_h1_medium_18(
                                  color: AppColors.primary_1,
                                ),
                              ),
                              SizedBox(width: 30.w),

                              Expanded(
                                child: CustomButton(
                                  text: "Rent Car",
                                  onTap: () {
                                    setState(() {
                                      _isRentClicked = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),



                      ],
                    ],
                  ),
                ),
              ),
            ),

            /// Back button (optional)
            CustomBackButton(
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
