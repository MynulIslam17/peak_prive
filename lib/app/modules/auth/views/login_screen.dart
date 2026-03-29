import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/role_controller.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:harry_service_app/app/modules/auth/controllers/login_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/nav_controller.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// find crontroller
  final roleController = Get.find<RoleController>();


  /// text editing controllers
  final emailTEController = TextEditingController();
  final passwordTEController = TextEditingController();

  /// getx loginController

  final loginController = Get.find<LoginController>();
  /// getx auth controllers

    final authController=Get.find<AuthController>();

  final icon = Assets.icons;

  final images = Assets.images;

  /// form key

  final _formKey = GlobalKey<FormState>();



  /// click event on login

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      String email = emailTEController.text.trim();
      String password = passwordTEController.text.trim();

      LoginRequestModel model = LoginRequestModel(email: email, password: password);

      bool isSuccess = await loginController.login(model);

      if (isSuccess) {



        final role = loginController.getUserModel!.role;
        if (role == "User") {
          final navController = Get.put(NavController());
          navController.changeIndex(0);
          Get.offAllNamed(Routes.service);
        } else {
          final navController = Get.put(NavController());
          navController.changeIndex(0);
          Get.offAllNamed(Routes.providerNavScreen);
        }
      } else {
        Get.snackbar(
          "Failed",
          loginController.errorMessage ?? "Login failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    }
  }



  /// forget pass  text button
  void _handleForgotPassword() {

    Get.toNamed(Routes.emailVerify);

  }

  /// go to signup textButton
  void _navigateToSignUp() {
    if (roleController.getRole == "Provider") {
      /// provider signup
      Get.toNamed(Routes.providerSignUp);
    } else {
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
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
             
              ClipRRect(

                borderRadius: BorderRadius.circular(12),
                child: Image.asset(

                    height: 100,
                    width: 260,
                    "assets/images/app_logo2.png"),
                
              ),
              
              SizedBox(height: 100.h),

              // Email Field
              CustomTextField(
                controller: emailTEController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email can't be empty";
                  } else if (!EmailValidator.validate(value)) {
                    return "Invalid email";
                  }

                  return null;
                },
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),

              // Password Field
              CustomTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Can't be empty";
                  }

                  return null;
                },
                controller: passwordTEController,
                hintText: "password",
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

              GetBuilder<LoginController>(
                builder: (controller) {
                  return controller.loginProgress
                      ? CircularProgressIndicator(
                    color: AppColors.primary_1,
                  )
                      : CustomAuthButton(
                          onTap: _handleLogin,
                          text: 'Lets go!!',
                        );
                },
              ),

              SizedBox(height: 30.h),

              RichText(
                text: TextSpan(
                  text: "Don't have an account ? ",
                  style: AppTextStyle.c_regular_12(),
                  children: [
                    TextSpan(
                      text: " SignUp",
                      style: AppTextStyle.c_regular_12().copyWith(
                        fontSize: 14,
                        color: AppColors.primary_1,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ///  Navigate to sign-up screen
                          _navigateToSignUp();
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
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
