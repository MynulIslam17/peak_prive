import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text-style.dart';
import 'blury_container.dart';
import 'custome_button.dart';

class CancelDialog extends StatelessWidget {
  final VoidCallback onTap;

  const CancelDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(height: 10.h),
          Text(
            "Reason of cancel & refund",
            style: AppTextStyle.h3_semibold_20(color: Colors.white),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: TextField(
              maxLines: 4,
              style: TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Reason of Cancel",
                hintStyle: AppTextStyle.c_regular_12(color: Colors.white),


                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: CustomButton(
                text: "Done",
                width: 123.w,
                height: 30.h,
                onTap: onTap,
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
