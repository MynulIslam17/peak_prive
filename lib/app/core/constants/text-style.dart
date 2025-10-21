

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';

abstract class AppTextStyle {


  /// h1 regular & simibol

  static  TextStyle h1_medium_24({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 24,
    color: color ?? AppColors.black_1
  );

static  TextStyle h1_smibold({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: color ?? AppColors.black_1
  );

/// regylar & semibol
static  TextStyle h2_medium_22({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 22,
    color: color ?? AppColors.black_1
  );

static  TextStyle h2_semibold_22({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: color ?? AppColors.black_1
  );


/// h3 regular & semibold
static  TextStyle h3_medium_20({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: color ?? AppColors.black_1
  );

static  TextStyle h3_semibold_20({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: color ?? AppColors.black_1
  );


/// sub header regular & medium
static  TextStyle sub_h1_regular_18({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 18.sp,
    color: color ?? AppColors.black_1
  );

static  TextStyle sub_h1_medium_18({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 18.sp,
    color: color ?? AppColors.black_1
  );


/// sub h2

static  TextStyle sub_h2_regular_16({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 16.sp,
    color: color ?? AppColors.black_1
  );

static  TextStyle sub_h2_medium_16({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 16.sp,
    color: color ?? AppColors.black_1
  );


/// sub h3

static  TextStyle sub_h3_regular_14({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
    color: color ?? AppColors.black_1
  );

static  TextStyle sub_h3_medium_14({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
    color: color ?? AppColors.black_1
  );






/// paragraph

static  TextStyle p_regular_12({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
    color: color ?? AppColors.black_1
  );

static  TextStyle p_medium_12({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
    color: color ?? AppColors.black_1
  );



/// caption
static  TextStyle c_regular_10({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 10.sp,
    color: color ?? AppColors.black_1
  );
static  TextStyle c_light_10({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w300,
    fontSize: 10.sp,
    color: color ?? AppColors.black_1
  );


static  TextStyle c_light_12({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w300,
    fontSize: 12.sp,
    color: color ?? AppColors.black_1
  );


static  TextStyle c_regular_12({Color ? color})=>GoogleFonts.dmSans(

    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
    color: color ?? AppColors.black_1
  );











}