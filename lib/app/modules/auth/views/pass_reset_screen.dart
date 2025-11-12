import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/pass_reset_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/reset_pass_request_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../../core/widgets/appbar_with_title.dart';
import '../../../core/widgets/cusom_text_fiield.dart';
import '../../../core/widgets/custome_button.dart';
import '../../../routes/app_routes.dart';

class PassResetScreen extends StatefulWidget {
  const PassResetScreen({super.key});

  @override
  State<PassResetScreen> createState() => _PassResetScreenState();
}

class _PassResetScreenState extends State<PassResetScreen> {
  final icons = Assets.icons;
  final images = Assets.images;

  /// TextEditing controller
  final passTEController = TextEditingController();
  final confirmPassTEController = TextEditingController();
  
  
   late final String email;


  /// GETx controller

   final resetController=Get.find<PassResetController>();

  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    /// gets email from previous class
    var argument=Get.arguments;
    
    email=argument["email"];
    
    
  }
  
  

  @override
  void dispose() {
    passTEController.dispose();
    confirmPassTEController.dispose();
    super.dispose();
  }

  /// Reset password button
  void _resetPasswordHandler() async {
    if (_formKey.currentState!.validate()) {

      String password = confirmPassTEController.text;

      // Create model with necessary values
      ResetPassRequestModel model = ResetPassRequestModel(email: email, newPassword: password);

      // Call the reset password API
      bool response = await resetController.resetPassword(model);

      if (response) {
        /// If the password reset is successful
        Get.snackbar(
          "Success",
          "Password reset successfully", // You can customize the success message here
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary_1,
          colorText: Colors.black,
        );

        // Redirect to login page after success
        Get.offAllNamed(Routes.login);
      } else {
        ///  If the API call fails
        Get.snackbar(
          "Error",
           resetController.errorMessage!, // Error message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
        onTap: () => Get.back(),
        title: "Reset Password",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [


                /// New Password
                CustomTextField(
                  controller: passTEController,
                  hintText: "New Password",
                  filledColor: const Color(0xffF0F0F0),
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password can't be empty";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),


                SizedBox(height: 20.h),

                /// Confirm Password
                CustomTextField(
                  controller: confirmPassTEController,
                  hintText: "Confirm Password",
                  filledColor: const Color(0xffF0F0F0),
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    } else if (value != passTEController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),

                /// Reset Button
                ///
               GetBuilder<PassResetController>(builder: (controller){
                 return  resetController.resetProgress
                     ? CircularProgressIndicator(color: AppColors.primary_1,)
                     : CustomButton(
                   width: double.infinity,
                   onTap: _resetPasswordHandler,
                   text: "Reset Password",
                   backgroundColor: AppColors.primary_1,
                 );
               })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
