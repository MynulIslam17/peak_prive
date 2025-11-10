import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/role_controller.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';


class LoginScreen extends StatelessWidget {

  /// find crontroller
  final roleController=Get.find<RoleController>();


  final icon = Assets.icons;
  final images = Assets.images;

   LoginScreen({super.key});

  void _handleLogin() {

       if(roleController.getRole=="Provider"){

         /// provider screen
         Get.toNamed(Routes.providerNavScreen);

       }else{
         /// user screen
         Get.toNamed(Routes.service);
       }

  }

  void _handleForgotPassword() {
    debugPrint('Forgot Password tapped');
  }

  void _navigateToSignUp() {


     if(roleController.getRole=="Provider"){
       /// provider signup
       Get.toNamed(Routes.providerSignUp);
     }else{
       /// user signup
       Get.toNamed(Routes.signup);
     }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


       appBar: AppBarWithTitle(
         icons: icon,
         showBack: false,
         title: "Login",
         onTap: () {

           Get.back();
         },

       ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.h),
            images.skiPass9.image(),
            SizedBox(height: 100.h),

            // Email Field
            CustomTextField(hintText: "Email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.h),

            // Password Field
            CustomTextField(hintText: "password",
              prefixIcon: Icons.lock,
              keyboardType: TextInputType.emailAddress,
              isPassword: true,
            ),

            SizedBox(height: 10.h),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _handleForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary_1,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),

            CustomAuthButton(
              onTap: _handleLogin,
              text: 'Lets go!!',
            ),
            SizedBox(height: 30.h),


            RichText(text: TextSpan(

              text: "Don't have an account ? ",
              style: AppTextStyle.c_regular_12(),
              children: [
                TextSpan(
                  text: " SignUp",style: AppTextStyle.c_regular_12().copyWith(
                  fontSize: 14,
                  color: AppColors.primary_1
                ),
                recognizer: TapGestureRecognizer()
              ..onTap = () {
                ///  Navigate to sign-up screen
               _navigateToSignUp();
              },


                )
              ]

            ))



          ],
        ),
      ),
    );
  }
}

/// ---------------- Custom Auth Button -----------------
class CustomAuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color backgroundColor;

  const CustomAuthButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor = AppColors.primary_1,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        minimumSize: Size(double.infinity, 52.h),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}






