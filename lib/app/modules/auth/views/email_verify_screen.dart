import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/modules/auth/controllers/email_verify_controller.dart';

import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

/// Forgot password, step 1: the account email; a 6-digit code is sent to it.
class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final emailTEController = TextEditingController();
  final emailController = Get.find<EmailVerifyController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTEController.dispose();
    super.dispose();
  }

  void _verifyEmailHandler() async {
    if (emailController.emailVerifyProgress) return; // a request is already running
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = emailTEController.text.trim();
    final response = await emailController.emailVerify(email);
    if (!mounted) return;

    if (response) {
      Get.toNamed(Routes.otpVerify, arguments: {'isFromSignUp': false, 'email': email});
    } else {
      showAppToast(
        type: ToastType.error,
        title: 'Error',
        message: emailController.errorMessage ?? 'Something went wrong.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Forgot password?',
        subtitle: "Enter your account email and we'll send you a 6-digit code to reset it.",
        footer: AuthSwitchLine(question: 'Remembered it?', action: 'Sign in', onTap: () => Get.back()),
        children: [
          AppFormField(
            label: 'Email',
            hint: 'you@example.com',
            controller: emailTEController,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Please enter your email address.';
              if (!EmailValidator.validate(v)) return 'Please enter a valid email address.';
              return null;
            },
          ),
          const SizedBox(height: 24),
          GetBuilder<EmailVerifyController>(
            builder: (c) =>
                AppPrimaryButton(label: 'Send code', loading: c.emailVerifyProgress, onPressed: _verifyEmailHandler),
          ),
        ],
      ),
    );
  }
}
