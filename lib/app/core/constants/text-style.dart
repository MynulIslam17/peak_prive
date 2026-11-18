import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';

/// Typography scale.
///
/// Every style is DM Sans. The 20/22/24 styles previously used raw `fontSize`
/// while everything 18 and below used `.sp`, so headings did not scale with
/// `flutter_screenutil` and looked oversized on small devices. They all use
/// `.sp` now so the whole scale moves together.
abstract class AppTextStyle {
  static TextStyle _dmSans({
    required FontWeight fontWeight,
    required double fontSize,
    Color? color,
  }) =>
      GoogleFonts.dmSans(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color ?? AppColors.textPrimary,
      );

  /// h1 regular & semibold
  static TextStyle h1_medium_24({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 24.sp, color: color);

  static TextStyle h1_smibold({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w600, fontSize: 24.sp, color: color);

  /// h2 regular & semibold
  static TextStyle h2_medium_22({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 22.sp, color: color);

  static TextStyle h2_semibold_22({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w600, fontSize: 22.sp, color: color);

  /// h3 regular & semibold
  static TextStyle h3_medium_20({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 20.sp, color: color);

  static TextStyle h3_semibold_20({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w600, fontSize: 20.sp, color: color);

  /// sub header regular & medium
  static TextStyle sub_h1_regular_18({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 18.sp, color: color);

  static TextStyle sub_h1_medium_18({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 18.sp, color: color);

  /// sub h2
  static TextStyle sub_h2_regular_16({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 16.sp, color: color);

  static TextStyle sub_h2_medium_16({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 16.sp, color: color);

  /// sub h3
  static TextStyle sub_h3_regular_14({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 14.sp, color: color);

  static TextStyle sub_h3_medium_14({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 14.sp, color: color);

  static TextStyle sub_h3_semibold_14({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w600, fontSize: 14.sp, color: color);

  /// paragraph
  static TextStyle p_regular_12({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 12.sp, color: color);

  static TextStyle p_medium_12({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w500, fontSize: 12.sp, color: color);

  /// caption
  static TextStyle c_regular_10({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 10.sp, color: color);

  static TextStyle c_light_10({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w300, fontSize: 10.sp, color: color);

  static TextStyle c_light_12({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w300, fontSize: 12.sp, color: color);

  static TextStyle c_regular_12({Color? color}) =>
      _dmSans(fontWeight: FontWeight.w400, fontSize: 12.sp, color: color);
}
