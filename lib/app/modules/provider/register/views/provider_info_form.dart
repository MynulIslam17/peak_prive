import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/appbar_with_title.dart';
import '../../../../core/widgets/cusom_text_fiield.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../routes/app_routes.dart';


class ProviderSignUp extends StatefulWidget {
  const ProviderSignUp({super.key});

  @override
  State<ProviderSignUp> createState() => _ProviderSignUpState();
}

class _ProviderSignUpState extends State<ProviderSignUp> {

  final icons = Assets.icons;


  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController phoneTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmConfirmTEController = TextEditingController();

  final List<String> _serviceList = [
    "Ski Pass",
    "Ski Hire",
    "Transport",
    "Restaurant Booking",
    "Massage",
  ];

  String? _selectedService;
  bool _isAgreed = false;

  final _formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        title: "Personal Info",
        onTap: () {},
      ),

      body: SafeArea(

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  /// --- Profile Photo Section ---
                  Text("Add a Profile Photo", style: AppTextStyle.c_regular_12()),
                  SizedBox(height: 8.h),
                  Container(
                    height: 54.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.upload, size: 25, color: AppColors.black_2),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Clear, professional photos help customers trust your service",
                    style: AppTextStyle.c_regular_12(),
                  ),
                  SizedBox(height: 10.h), // Separator

                  /// --- Full Name ---
                  buildLabel("Full Name"),
                  SizedBox(height: 14.h),
                  textFormField(hint: "Name", controller: nameTEController, type: TextInputType.name),
                  SizedBox(height: 10.h),

                  ///--- Email ---
                  buildLabel("Email Address"),
                  SizedBox(height: 14.h),
                  textFormField(hint: "Email", controller: emailTEController, type: TextInputType.emailAddress),
                  SizedBox(height: 10.h),

                  /// --- Phone ---
                  buildLabel("Phone"),
                  SizedBox(height: 14.h),
                  textFormField(hint: "Phone", controller: phoneTEController, type: TextInputType.phone),
                  SizedBox(height: 10.h),

                  /// --- Service Type ---
                  buildLabel("Service Type"),
                  SizedBox(height: 14.h),
                  Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.black_3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _selectedService,
                      hint: const Text("Select One"),
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFFFFFAFA),
                      items: _serviceList.map((service) {
                        return DropdownMenuItem(
                          value: service,
                          child: Text(service, style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// --- New Password ---
                  buildLabel("New Password"),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 50,
                    child: CustomTextField(

                      hintText: "Password",
                      controller: passwordTEController,
                      isPassword: true,
                      prefixIcon: Icons.lock,
                      filledColor: Colors.transparent,
                      borderColors: AppColors.black_2,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// --- Confirm Password ---
                  buildLabel("Confirm Password"),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 50,
                    child: CustomTextField(
                      hintText: "Confirm Password",
                      controller: confirmConfirmTEController,
                      isPassword: true,
                      prefixIcon: Icons.lock,
                      filledColor: Colors.transparent,
                      borderColors: AppColors.black_2,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// --- Checkbox Row ---
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.primary_1,
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value!;
                          });
                        },
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          "Agree terms and conditions",
                          style: AppTextStyle.c_regular_12(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  /// --- Submit Button ---
                  CustomButton(
                    width: double.infinity,
                    onTap: _handleSubmit,
                    text: "Submit",
                    backgroundColor: AppColors.primary_1,
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// method for style text
  Widget buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyle.c_regular_12().copyWith(fontSize: 14),
    );
  }

  /// method for make textField
  SizedBox textFormField({
    TextInputType? type,
    required String hint,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: type ?? TextInputType.text,
        style: AppTextStyle.c_regular_12(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.black_2),
          ),
        ),
      ),
    );
  }

  /// method for submit handle
  void _handleSubmit(){

    Get.snackbar(" success", "Register success please log in first");


    /// go to login screen
    Get.offAllNamed(Routes.login);


  }
}