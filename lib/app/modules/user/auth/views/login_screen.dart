import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';


class LoginScreen extends StatelessWidget {
  final icon = Assets.icons;
  final images = Assets.images;

  const LoginScreen({super.key});

  void _handleLogin() {
    Get.offAllNamed(Routes.service);
  }

  void _handleForgotPassword() {
    debugPrint('Forgot Password tapped');
  }

  void _navigateToSignUp() {

    Get.toNamed(Routes.signup);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.black_3,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToSignUp,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppColors.primary_1,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Custom Auth Button -----------------
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






