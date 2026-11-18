import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/signup_request_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../../core/widgets/appbar_with_title.dart';
import '../../../core/widgets/cusom_text_fiield.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../core/widgets/custome_button.dart';
import '../../../routes/app_routes.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final icons = Assets.icons;
  final image = Assets.images;

  String phoneNumber = "";

  bool _isAgree = false;

  final nameTEController = TextEditingController();
  final emailTEController = TextEditingController();
  final passwordTEController = TextEditingController();
  final confirmTEController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final String role = "User";

  final signUpController = Get.find<UserSignupController>();

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    passwordTEController.dispose();
    confirmTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        title: "Signup",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      height: 100,
                      width: 260,
                      "assets/images/app_logo2.png",
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Create Account",
                    style: AppTextStyle.c_regular_12(
                      color: AppColors.primary_1,
                    ).copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Enter this information properly and get excited service properly!",
                    style: AppTextStyle.c_regular_12(
                      color: AppColors.primary_1,
                    ).copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),

                  /// Name
                  CustomTextField(
                    controller: nameTEController,
                    hintText: "User Name",
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name can't be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 9.h),

                  /// Email
                  CustomTextField(
                    controller: emailTEController,
                    hintText: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email can't be empty";
                      }
                      if (!EmailValidator.validate(value)) {
                        return "Not a valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 9.h),

                  IntlPhoneField(
                    initialCountryCode: 'CA',
                    decoration: InputDecoration(
                      labelText: 'Phone Number',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),

                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                    },

                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return "Phone number required";
                      }

                      if (!phone.isValidNumber()) {
                        return "Invalid phone number";
                      }

                      return null;
                    },
                  ),

                  /// Password
                  CustomTextField(
                    controller: passwordTEController,
                    hintText: "Password",
                    prefixIcon: Icons.lock,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password can't be empty";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 9.h),

                  /// Confirm Password
                  CustomTextField(
                    controller: confirmTEController,
                    hintText: "Confirm Password",
                    prefixIcon: Icons.lock,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm Password can't be empty";
                      }
                      if (value != passwordTEController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),

                  /// Terms & Sign In Row
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.primary_1,
                        value: _isAgree,
                        onChanged: (value) {
                          setState(() {
                            _isAgree = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Agree to terms and conditions",
                          style: AppTextStyle.p_medium_12(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Sign In page
                          Get.back();
                        },
                        child: Text(
                          "Sign in",
                          style: AppTextStyle.p_medium_12(
                            color: AppColors.primary_1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),

                  /// Submit Button
                  GetBuilder<UserSignupController>(
                    builder: (controller) {
                      return controller.signupProgress
                          ? CircularProgressIndicator(
                              color: AppColors.primary_1,
                            )
                          : SizedBox(
                              height: 67,
                              width: double.infinity,
                              child: CustomButton(
                                onTap: _submit,
                                text: "Submit",
                                backgroundColor: AppColors.primary_1,
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Submit logic
  void _submit() async {
    if (signUpController.signupProgress) return; // a request is already running

    /// Validate all form fields
    if (!_formKey.currentState!.validate()) {
      return; // stop if any field has error
    }

    /// Check phone number
    if (phoneNumber.isEmpty) {
      showAppToast(type: ToastType.warning, title: "Phone Required", message: "Please enter a valid phone number");
      return;
    }

    /// Check terms agreement
    if (!_isAgree) {
      showAppToast(type: ToastType.warning, title: "Terms Required", message: "Please agree to terms and conditions");
      return;
    }

    /// get user input
    String name = nameTEController.text.trim();
    String email = emailTEController.text.trim();
    String password = passwordTEController.text.trim();
    String confirmPassword = confirmTEController.text.trim();

    /// create request model
    SignupRequestModel model = SignupRequestModel(
      fullName: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
    );

    /// call API
    bool isSuccess = await signUpController.signup(model);

    /// check result
    if (isSuccess) {
      showAppToast(type: ToastType.success, title: "Code sent", message: "We sent a code to your email.");

      /// navigate to OTP screen
      Get.toNamed(
        Routes.otpVerify,
        arguments: {"isFromSignUp": true, "email": email},
      );

    } else {
      showAppToast(type: ToastType.error, title: "Error", message: signUpController.errorMessage!);
    }
  }
}
