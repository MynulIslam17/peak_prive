import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/modules/auth/controllers/otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/resend_otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/otp_request_model.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custome_button.dart';
import '../../../routes/app_routes.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final icons = Assets.icons;
  final image = Assets.images;

  final otpTEController = TextEditingController();

  late final bool fromSignup;
  late final String email;

  final otpController = Get.find<OtpController>();
  final resendController = Get.find<ResendOtpController>();

  bool isResendEnabled = true; // /Flag to check if resend is allowed
  int resendTimer = 30;

  /// Timer duration in seconds
  late String resendText;

  @override
  void initState() {
    super.initState();

    var arguments = Get.arguments;
    fromSignup = arguments["isFromSignUp"];
    email = arguments["email"];
    resendText = "Resend"; // Initial resend text

    /// Start countdown for resend
    _startResendTimer();
  }

  /// Function to start the resend timer========
  void _startResendTimer() {
    if (!isResendEnabled) {
      setState(() {
        resendText = "Resend in $resendTimer seconds"; // Update resend text
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (resendTimer > 0) {
          setState(() {
            resendTimer--;
            resendText =
                "Resend in $resendTimer seconds"; // Update text dynamically
          });
          _startResendTimer(); // Recurse every second
        } else {
          setState(() {
            isResendEnabled = true;
            resendText = "Resend"; // Allow resend once timer completes
          });
        }
      });
    }
  }

  /// Function to handle resendOTP logic==============
  void _resendOtp() async {
    otpTEController.clear();
    if (isResendEnabled) {
      /// Disable the resend button for the duration of the timer
      setState(() {
        otpTEController.clear();
        isResendEnabled = false;
        resendTimer = 30; // Reset timer to 30 seconds
        _startResendTimer(); // Start the resend timer
      });

      /// call the resend api

      bool response = await resendController.resendOtp(email);

      if (response) {
        // Successfully sent OTP
        Get.snackbar(
          "Success",
          "OTP sent successfully to $email",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary_1,
          colorText: Colors.black,
        );
      } else {
        // If API returns false (unsuccessful)
        Get.snackbar(
          "Failed",
          "Failed to resend OTP. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.black,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        onTap: () => Navigator.pop(context),
        title: "OTP Verification",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top illustration or info text
                Text(
                  "Enter the 6-digit verification code sent to your email or phone.",
                  style: AppTextStyle.c_regular_12(
                    color: Colors.black.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),

                // PIN CODE TEXT FIELD
                PinCodeTextField(
                  controller: otpTEController,
                  appContext: context,
                  length: 6,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.primary_1,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8.r),
                    fieldHeight: 50.h,
                    fieldWidth: 45.w,
                    inactiveColor: AppColors.black_3 ?? Colors.grey.shade300,
                    selectedColor: AppColors.primary_1,
                    activeColor: AppColors.primary_1,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  onCompleted: (v) {
                    debugPrint("Completed: $v");
                  },
                  onChanged: (value) {},
                  textStyle: AppTextStyle.sub_h2_medium_16(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return "Enter the 6-digit code";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),

                // Verify Button
                GetBuilder<OtpController>(
                  builder: (controller) {
                    return otpController.otpProgress
                        ? CircularProgressIndicator(color: AppColors.primary_1)
                        : CustomButton(
                            width: double.infinity,
                            height: 50,
                            onTap: _verifyOtpButton,
                            text: "Verify",
                            backgroundColor: AppColors.primary_1,
                          );
                  },
                ),

                SizedBox(height: 20.h),

                // Resend option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn’t receive the code? ",
                      style: AppTextStyle.c_regular_12(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendOtp, // Call the resend OTP function
                      child: Text(
                        resendText,
                        style: AppTextStyle.c_regular_12(
                          color: isResendEnabled
                              ? AppColors.primary_1
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Verify OTP event
  void _verifyOtpButton() async {


    /// hide the keyboard
    FocusScope.of(context).unfocus();

    String otp=otpTEController.text;

    if(otp.length<6){
      Get.snackbar("Error", "Otp must be 6 character",backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);
      return;
    }





    /// Create model with the necessary value
    OtpRequestModel model = OtpRequestModel(otp: otp, email: email);

    /// Call OTP verification
    bool response = await otpController.otpVerify(model);

    /// If success, navigate to the next page
    if (response) {
      if (fromSignup == false) {

        Get.toNamed(
            Routes.passReset,        /// Navigate to password reset
            arguments: {"email": email}
        );


      } else {
        Get.toNamed(Routes.login); ///  Navigate to login
      }
    }
    else { /// is unsuccessful
      Get.snackbar(
        "Error",
        otpController.errorMessage!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }




}
