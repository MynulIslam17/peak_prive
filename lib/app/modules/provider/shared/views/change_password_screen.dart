import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/change_pass_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/change_pass_request_model.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/appbar_with_title.dart';
import '../../../../core/widgets/custome_button.dart';

class ProviderPassScreen extends StatefulWidget {
  const ProviderPassScreen({super.key});

  @override
  State<ProviderPassScreen> createState() => _ProviderPassScreenState();
}

class _ProviderPassScreenState extends State<ProviderPassScreen> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  // Find AuthController
  final authController = Get.find<AuthController>();
  final passController = Get.find<ChangePasswordController>();

  final icons = Assets.icons;

  // --------------------------
  /// Change Password Function
  // --------------------------
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPass = oldPassController.text;
      String newPass = newPassController.text;
      String confirmPass = confirmPassController.text;


      ChangePassRequestModel model=ChangePassRequestModel(newPassword: confirmPass, currentPassword: oldPass);


      bool success=await passController.changePassword(model);


      if(success){

        /// show success message
        Get.snackbar(
          "Success",
          "Password changed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP
        );


        // Clear fields after successful update
        oldPassController.clear();
        newPassController.clear();
        confirmPassController.clear();

      }else{
        Get.snackbar(
            "Failed",
            passController.errorMessage!,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM
        );


      }




    }
  }

  @override
  void dispose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        title: "Change Password",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: oldPassController,
                          hintText: "Old Password",
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter old password";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          controller: newPassController,
                          hintText: "New Password",
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter new password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          controller: confirmPassController,
                          hintText: "Confirm New Password",
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm new password";
                            }
                            if (value != newPassController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            "Forgot password?",
                            style: AppTextStyle.p_regular_12(),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              GetBuilder<ChangePasswordController>(builder: (controller){
                return controller.isLoading
                    ?CircularProgressIndicator(
                  color: AppColors.primary_1,
                )
                    :  SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: CustomButton(
                    onTap: _changePassword,
                    text: "Update Password",
                    backgroundColor: AppColors.primary_1,
                  ),
                );
              })


            ],
          ),
        ),
      ),
    );
  }
}
