import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/data/models/booking_details_model.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/appText.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/available_service.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../routes/app_routes.dart';

class ProviderBookingDetails extends StatefulWidget {
  const ProviderBookingDetails({super.key});

  @override
  State<ProviderBookingDetails> createState() => _ProviderBookingDetailsState();
}

class _ProviderBookingDetailsState extends State<ProviderBookingDetails> {
  final image = Assets.images;
  final icon = Assets.icons;

  List<BookingDetailItem> items = Get.arguments ?? [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            image.skiDetails.image(
              height: size.height * 0.48,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            /// overlap card
            Positioned(
              top: size.height * 0.3,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      /// line image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: image.line.image(width: 87.w, height: 9.h),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// The scrollable section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// profile section
                              ProviderInfo(
                                onTapCall: () {},
                                onTapMessage: () {},
                              ),

                              SizedBox(height: 30.h),

                              /// Aligned booking details in 2 columns
                              _buildDetailsGrid(),

                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),

                      /// Fixed bottom button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: CustomButton(
                          onTap: () {},
                          text: "Book Ski Pass",
                          backgroundColor: AppColors.primary_1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// app bar Back button
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

  /// Build a 2-column grid layout for details
  Widget _buildDetailsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Row(
                children: [
                  // First column
                  Expanded(
                    child: _buildLabel(
                      label: items[i].label,
                      value: items[i].value,
                      iconPath: items[i].iconPath,
                      labelColor: items[i].labelColor,
                      valueColor: items[i].valueColor,
                    ),
                  ),

                  SizedBox(width: 20.w),

                  // Second column (if exists)
                  Expanded(
                    child: i + 1 < items.length
                        ? _buildLabel(
                      label: items[i + 1].label,
                      value: items[i + 1].value,
                      iconPath: items[i + 1].iconPath,
                      labelColor: items[i + 1].labelColor,
                      valueColor: items[i + 1].valueColor,
                    )
                        : SizedBox(), // Empty space if odd number of items
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Single label-value pair with optional icon
  Widget _buildLabel({
    required String label,
    required String value,
    SvgGenImage? iconPath,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        Row(children: [
          if (iconPath != null) ...[
            iconPath.svg(
              width: 15.w,
              height: 15.h,
              color: labelColor ?? Colors.grey[600],
            ),
            SizedBox(width: 8.h),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: labelColor ?? Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
          ],


        ],),
        // Icon (if provided)



        SizedBox(height: 6.h),

        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}