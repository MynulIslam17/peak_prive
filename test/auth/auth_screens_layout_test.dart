import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/email_verify_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/login_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/pass_reset_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/resend_otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';
import 'package:harry_service_app/app/modules/auth/views/email_verify_screen.dart';
import 'package:harry_service_app/app/modules/auth/views/login_screen.dart';
import 'package:harry_service_app/app/modules/auth/views/otp_verification_screen.dart';
import 'package:harry_service_app/app/modules/auth/views/pass_reset_screen.dart';
import 'package:harry_service_app/app/modules/auth/views/signup_screen.dart';

/// Every auth screen lays out without overflow on a small phone with large
/// text, and on a normal one.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(Get.reset);

  final screens = <String, Widget Function()>{
    'login': () => const LoginScreen(),
    'signup': () => const SignupScreen(),
    'forgot password': () => const EmailVerifyScreen(),
    'code': () => const OtpVerification(),
    'new password': () => const PassResetScreen(),
  };

  for (final size in const [Size(320, 640), Size(390, 844)]) {
    for (final scale in const [1.0, 1.3]) {
      for (final e in screens.entries) {
        testWidgets('${e.key} fits ${size.width.toInt()}×${size.height.toInt()} at text ×$scale', (tester) async {
          tester.view
            ..physicalSize = size * 3
            ..devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          Get
            ..put(AuthController())
            ..put(LoginController())
            ..put(UserSignupController())
            ..put(EmailVerifyController())
            ..put(OtpController())
            ..put(ResendOtpController())
            ..put(PassResetController());

          await tester.pumpWidget(ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => GetMaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Builder(builder: (_) {
                Get.routing.args = {'email': 'guest@example.com', 'isFromSignUp': true};
                return e.value();
              }),
            ),
          ));
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox()); // stops the code countdown
        });
      }
    }
  }
}
