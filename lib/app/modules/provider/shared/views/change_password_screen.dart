import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/core/widgets/app_toast.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/change_pass_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/change_pass_request_model.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/custom_appbar.dart';

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

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final model = ChangePassRequestModel(
      newPassword: newPassController.text,
      currentPassword: oldPassController.text,
    );
    final success = await passController.changePassword(model);
    if (!mounted) return;

    if (success) {
      AppToast.success('Your password has been updated.',
          title: 'Password changed');
      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
      _formKey.currentState?.reset();
    } else {
      AppToast.error(
        passController.errorMessage ?? 'Please try again.',
        title: "Couldn't change password",
      );
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
      backgroundColor: AppColors.scaffold,
      appBar: const CustomAppBar(title: "Change password"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF3DC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: Color(0xFF9A7A12)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use at least 6 characters, different from your current password.',
                              style: AppTextStyle.p_regular_12(
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppFormField(
                      label: 'Current password',
                      controller: oldPassController,
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your current password'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'New password',
                      controller: newPassController,
                      icon: Icons.key_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a new password';
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (v == oldPassController.text) {
                          return 'Choose a password different from the current one';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'Confirm new password',
                      controller: confirmPassController,
                      icon: Icons.key_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your new password';
                        }
                        if (v != newPassController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.emailVerify),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyle.p_medium_12(
                              color: const Color(0xFF9A7A12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GetBuilder<ChangePasswordController>(
                builder: (controller) => AppPrimaryButton(
                  label: 'Update password',
                  loading: controller.isLoading,
                  onPressed: _changePassword,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
