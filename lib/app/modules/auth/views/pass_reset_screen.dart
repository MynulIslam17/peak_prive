import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/modules/auth/controllers/pass_reset_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/reset_pass_request_model.dart';

import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

/// Forgot password, last step: the new password.
class PassResetScreen extends StatefulWidget {
  const PassResetScreen({super.key});

  @override
  State<PassResetScreen> createState() => _PassResetScreenState();
}

class _PassResetScreenState extends State<PassResetScreen> {
  final authController = Get.find<AuthController>();
  final resetController = Get.find<PassResetController>();

  final passTEController = TextEditingController();
  final confirmPassTEController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final String email = '${Get.arguments?['email'] ?? ''}';

  @override
  void dispose() {
    passTEController.dispose();
    confirmPassTEController.dispose();
    super.dispose();
  }

  void _resetPasswordHandler() async {
    if (resetController.resetProgress) return; // a request is already running
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final model = ResetPassRequestModel(email: email, newPassword: confirmPassTEController.text);
    final response = await resetController.resetPassword(model);
    if (!mounted) return;

    if (response) {
      showAppToast(type: ToastType.success, title: 'Password changed', message: 'Password reset successfully');
      if (authController.isLoggedIn) {
        Get.find<NavController>().changeIndex(3);
        Get.offAllNamed(Routes.bottomNav);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } else {
      showAppToast(
        type: ToastType.error,
        title: 'Error',
        message: resetController.errorMessage ?? 'Something went wrong.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Set a new password',
        subtitle: 'Choose a password you haven\'t used before, at least 6 characters.',
        children: [
          AppFormField(
            label: 'New password',
            hint: 'At least 6 characters',
            controller: passTEController,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return "Password can't be empty";
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Confirm password',
            hint: 'Type it again',
            controller: confirmPassTEController,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != passTEController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          GetBuilder<PassResetController>(
            builder: (c) =>
                AppPrimaryButton(label: 'Reset password', loading: c.resetProgress, onPressed: _resetPasswordHandler),
          ),
        ],
      ),
    );
  }
}
