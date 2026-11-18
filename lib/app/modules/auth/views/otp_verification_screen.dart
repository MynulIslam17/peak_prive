import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/modules/auth/controllers/otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/resend_otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/otp_request_model.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

/// The 6-digit code sent by email, after signup (then sign in) or for a
/// forgotten password (then a new password).
class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  static const _resendAfter = 30;

  final otpTEController = TextEditingController();

  late final bool fromSignup;
  late final String email;

  final otpController = Get.find<OtpController>();
  final resendController = Get.find<ResendOtpController>();

  /// Seconds until "Resend" works again. A code was just sent, so it starts
  /// counting down straight away.
  int _wait = _resendAfter;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    fromSignup = arguments['isFromSignUp'] == true;
    email = '${arguments['email'] ?? ''}';
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _wait = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  void _resendOtp() async {
    if (_wait > 0 || resendController.resendOtpProgress) return;
    otpTEController.clear();
    _startCountdown();
    final response = await resendController.resendOtp(email);
    if (!mounted) return;
    if (response) {
      showAppToast(type: ToastType.success, title: 'Code sent', message: 'A new code was sent to $email');
    } else {
      setState(() => _wait = 0); // let them try again now
      showAppToast(type: ToastType.error, title: 'Failed', message: 'Failed to resend the code. Please try again.');
    }
  }

  void _verifyOtpButton() async {
    if (otpController.otpProgress) return; // a request is already running
    FocusScope.of(context).unfocus();

    final otp = otpTEController.text;
    if (otp.length < 6) {
      showAppToast(type: ToastType.error, title: 'Error', message: 'The code must be 6 digits.');
      return;
    }

    final response = await otpController.otpVerify(OtpRequestModel(otp: otp, email: email));
    if (!mounted) return;

    if (!response) {
      showAppToast(type: ToastType.error, title: 'Error', message: otpController.errorMessage ?? 'Invalid code.');
      return;
    }
    if (fromSignup) {
      // Account verified: start fresh on the sign-in screen (no signup or
      // code screens left underneath).
      showAppToast(type: ToastType.success, title: 'Email verified', message: 'Your account is ready. Please sign in.');
      Get.offAllNamed(Routes.login);
    } else {
      Get.toNamed(Routes.passReset, arguments: {'email': email});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'Enter the 6-digit code we sent to\n$email',
      children: [
        // Boxes sized to the width, so six always fit (small phones too).
        LayoutBuilder(
          builder: (context, c) {
            final box = ((c.maxWidth - 5 * 8) / 6).clamp(36.0, 52.0);
            return PinCodeTextField(
              controller: otpTEController,
              appContext: context,
              length: 6,
              autoFocus: true,
              animationType: AnimationType.scale,
              keyboardType: TextInputType.number,
              cursorColor: AppColors.primary_1,
              enableActiveFill: true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: box + 8,
                fieldWidth: box,
                borderWidth: 1.2,
                inactiveColor: AppColors.border,
                inactiveFillColor: AppColors.surfaceAlt,
                selectedColor: AppColors.primary_1,
                selectedFillColor: Colors.white,
                activeColor: AppColors.primary_1,
                activeFillColor: Colors.white,
              ),
              animationDuration: const Duration(milliseconds: 200),
              textStyle: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary),
              // All 6 digits typed: verify straight away.
              onCompleted: (_) => _verifyOtpButton(),
              onChanged: (_) {},
            );
          },
        ),
        const SizedBox(height: 16),
        GetBuilder<OtpController>(
          builder: (c) => AppPrimaryButton(label: 'Verify', loading: c.otpProgress, onPressed: _verifyOtpButton),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Didn't get the code? ", style: AppTextStyle.sub_h3_regular_14(color: AppColors.textSecondary)),
            if (_wait > 0)
              Text(
                'Resend in 0:${_wait.toString().padLeft(2, '0')}',
                style: AppTextStyle.sub_h3_medium_14(color: AppColors.textTertiary),
              )
            else
              TextButton(
                onPressed: _resendOtp,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9A7A12),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 36),
                ),
                child: Text('Resend', style: AppTextStyle.sub_h3_semibold_14(color: const Color(0xFF9A7A12))),
              ),
          ],
        ),
      ],
    );
  }
}
