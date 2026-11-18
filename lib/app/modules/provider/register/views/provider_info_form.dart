import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/signup_request_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/appbar_with_title.dart';
import '../../../../core/widgets/cusom_text_fiield.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../routes/app_routes.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

class ProviderSignUp extends StatefulWidget {
  const ProviderSignUp({super.key});

  @override
  State<ProviderSignUp> createState() => _ProviderSignUpState();
}

class _ProviderSignUpState extends State<ProviderSignUp> {
  final icons = Assets.icons;

  /// finds controllers
  final signUpController = Get.find<UserSignupController>();

  /// by default role for
  final String role = "Provider";

  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController phoneTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  final List<String> _serviceList = [
    "Ski Pass",
    "Ski Hire",
    "Transport",
    "Restaurant Booking",
    "Massage",
  ];

  String? _selectedService;
  bool _isAgreed = false;
  String? _phoneNumber;
  bool _isPhoneValid = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    phoneTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        title: "Personal Info",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  /// --- Full Name ---
                  _buildLabel("Full Name"),
                  SizedBox(height: 8.h),
                  _buildTextFormField(
                    hint: "Enter your full name",
                    controller: nameTEController,
                    type: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your full name";
                      }
                      if (value.trim().length < 3) {
                        return "Name must be at least 3 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  /// --- Email ---
                  _buildLabel("Email Address"),
                  SizedBox(height: 8.h),
                  _buildTextFormField(
                    hint: "Enter your email",
                    controller: emailTEController,
                    type: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your email";
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  /// --- Phone ---
                  _buildLabel("Phone Number"),
                  SizedBox(height: 8.h),
                  IntlPhoneField(
                    controller: phoneTEController,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.primary_1,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.red.shade400),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 2,
                        ),
                      ),
                      errorStyle: TextStyle(fontSize: 12.sp, height: 0.8),
                    ),
                    initialCountryCode: 'US',
                    dropdownTextStyle: TextStyle(fontSize: 14.sp),
                    style: TextStyle(fontSize: 14.sp),
                    onChanged: (phone) {
                      _phoneNumber = phone.completeNumber;
                      _isPhoneValid = phone.isValidNumber();
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return "Please enter your phone number";
                      }
                      if (!_isPhoneValid) {
                        return "Please enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  /// --- Service Type ---
                  _buildLabel("Service Type"),
                  SizedBox(height: 8.h),
                  _buildServiceDropdown(),
                  SizedBox(height: 16.h),

                  /// --- New Password ---
                  _buildLabel("Password"),
                  SizedBox(height: 8.h),
                  _buildPasswordField(
                    hintText: "Enter password",
                    controller: passwordTEController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  /// --- Confirm Password ---
                  _buildLabel("Confirm Password"),
                  SizedBox(height: 8.h),
                  _buildPasswordField(
                    hintText: "Re-enter password",
                    controller: confirmPasswordTEController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != passwordTEController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  /// --- Checkbox Row ---
                  _buildTermsCheckbox(),
                  SizedBox(height: 24.h),

                  /// --- Submit Button ---
                  GetBuilder<UserSignupController>(builder: (controller){
                    return controller.signupProgress ?Center(child: CircularProgressIndicator(color: AppColors.primary_1,)): CustomButton(
                      width: double.infinity,
                      onTap: _handleSubmit,
                      text: "Create Account",
                      backgroundColor: AppColors.primary_1,
                    );

                  }),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build label widget
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyle.c_regular_12().copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  /// Build text form field with consistent styling
  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    TextInputType? type,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type ?? TextInputType.text,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey.shade600, size: 20.sp)
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16.w),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary_1, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        errorStyle: TextStyle(fontSize: 12.sp, height: 0.8),
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }

  /// Build password field
  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      hintText: hintText,
      controller: controller,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      filledColor: Colors.grey.shade50,
      borderColors: Colors.grey.shade300,
      validator: validator,
    );
  }

  /// Build service dropdown
  Widget _buildServiceDropdown() {
    return FormField<String>(
      validator: (value) {
        if (_selectedService == null) {
          return "Please select a service type";
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: state.hasError
                      ? Colors.red.shade400
                      : Colors.grey.shade300,
                  width: state.hasError ? 1.5 : 1,
                ),
                color: Colors.grey.shade50,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedService,
                  hint: Text(
                    "Select service type",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                  dropdownColor: Colors.white,
                  items: _serviceList.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                    state.didChange(value);
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(left: 12.w, top: 8.h),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12.sp),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build terms checkbox
  Widget _buildTermsCheckbox() {
    return FormField<bool>(
      validator: (value) {
        if (!_isAgreed) {
          return "You must agree to the terms and conditions";
        }
        return null;
      },
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: Checkbox(
                    activeColor: AppColors.primary_1,
                    value: _isAgreed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: BorderSide(
                      color: state.hasError
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isAgreed = value!;
                      });
                      state.didChange(value);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                      });
                      state.didChange(_isAgreed);
                    },
                    child: Text(
                      "I agree to the Terms and Conditions and Privacy Policy",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(left: 36.w, top: 4.h),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12.sp),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Handle form submission
  void _handleSubmit() async {

    // Hide the keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // All validations passed
      String type;

      if (_selectedService == "Ski Hire") {
        type = "Ski_Hire";
      } else if (_selectedService == "Ski Pass") {
        type = "Ski_Pass";
      } else {
        type = _selectedService!;
      }

      String name = nameTEController.text.trim();
      String email = emailTEController.text.trim();
      String phoneNumber = phoneTEController.text.trim();
      String password = passwordTEController.text;
      String confirmPassword = confirmPasswordTEController.text;

      /// call the api for create account

      SignupRequestModel model = SignupRequestModel(
        fullName: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        providerType: type,
        phoneNumber: phoneNumber

      );

      bool success = await signUpController.signup(model);

      if (success) {
        Get.offAllNamed(  Routes.otpVerify,
            arguments: {
              "isFromSignUp" : true,
              "email" : email,
            }
            );


      } else {
        showAppToast(type: ToastType.error, title: "Error", message: signUpController.errorMessage!);


      }
    } else {
      // Show error message
      showAppToast(type: ToastType.warning, title: "Validation Error", message: "Please fill in all required fields correctly");
    }
  }
}
