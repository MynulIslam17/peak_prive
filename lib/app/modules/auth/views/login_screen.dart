import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/modules/auth/controllers/login_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';

import '../../../core/controllers/nav_controller.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTEController = TextEditingController();
  final passwordTEController = TextEditingController();

  final loginController = Get.find<LoginController>();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTEController.dispose();
    passwordTEController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (loginController.loginProgress) return; // a request is already running
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final model = LoginRequestModel(email: emailTEController.text.trim(), password: passwordTEController.text.trim());
    final isSuccess = await loginController.login(model);
    if (!mounted) return;

    if (isSuccess) {
      final role = loginController.getUserModel!.role;
      Get.put(NavController()).changeIndex(0);
      Get.offAllNamed(role == 'User' ? Routes.service : Routes.providerNavScreen);
    } else {
      showAppToast(
        type: ToastType.error,
        title: 'Login failed',
        message: loginController.errorMessage ?? 'Login failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        showBack: false,
        title: 'Welcome back',
        subtitle: 'Sign in to book and manage your Peak Privee services.',
        footer: AuthSwitchLine(
          question: 'New here?',
          action: 'Create an account',
          onTap: () => Get.toNamed(Routes.signup),
        ),
        children: [
          AppFormField(
            label: 'Email',
            hint: 'you@example.com',
            controller: emailTEController,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return "Email can't be empty";
              if (!EmailValidator.validate(v)) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Password',
            hint: 'Your password',
            controller: passwordTEController,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) => (value == null || value.isEmpty) ? "Password can't be empty" : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.emailVerify),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9A7A12),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text('Forgot password?', style: AppTextStyle.p_medium_12(color: const Color(0xFF9A7A12))),
            ),
          ),
          const SizedBox(height: 12),
          GetBuilder<LoginController>(
            builder: (c) => AppPrimaryButton(label: 'Sign in', loading: c.loginProgress, onPressed: _handleLogin),
          ),
        ],
      ),
    );
  }
}
