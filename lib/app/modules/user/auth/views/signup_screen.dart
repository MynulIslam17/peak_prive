import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart'
    hide CustomButton;

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/appbar_with_title.dart';
import '../../../../core/widgets/custome_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final icons = Assets.icons;
  final image = Assets.images;
  bool _isAgree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,

        title: "Signup",
        onTap: () {
          Get.back();
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              image.skiPass9.image(width: double.infinity),

              SizedBox(height: 5.h),

              Text(
                "Create Account",
                style: AppTextStyle.c_regular_12(
                  color: AppColors.primary_1,
                ).copyWith(fontSize: 20),
              ),
              SizedBox(height: 6.h),
              Text(
                "Enter this information properly and get excited service properly! ",
                style: AppTextStyle.c_regular_12(
                  color: AppColors.primary_1,
                ).copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h),

              CustomTextField(
                hintText: "User Name",
                prefixIcon: Icons.person,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 9.h),

              CustomTextField(
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 9.h),
              CustomTextField(
                hintText: "Password",
                prefixIcon: Icons.lock,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
              ),
              SizedBox(height: 9.h),
              CustomTextField(
                hintText: "Confirm Password",
                prefixIcon: Icons.lock,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
              ),

              SizedBox(height: 10.h),

              Row(
                children: [
                  Checkbox(
                    activeColor: AppColors.primary_1,
                    value: _isAgree,
                    onChanged: (value) {
                      setState(() {
                        _isAgree = value!;
                      });
                    },
                  ),

                  Text(
                    "Agree terms and condition Sign In",
                    style: AppTextStyle.p_medium_12(),
                  ),

                  Spacer(),

                  Text(
                    "Sign in",
                    style: AppTextStyle.p_medium_12(color: AppColors.primary_1),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              CustomButton(
                height: 30.h,

                onTap: () {},
                text: "Submit",
                backgroundColor: AppColors.primary_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
