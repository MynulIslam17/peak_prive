import 'package:harry_service_app/app/core/utils/toast_host.dart';
import 'package:harry_service_app/app/core/constants/app_theme.dart';

  
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/bindings/app_bindings.dart';
import 'package:harry_service_app/app/core/constants/env_config.dart';

import 'package:harry_service_app/app/routes/app_pages.dart';

import 'gen/assets.gen.dart';

Future<void> _initStripe() async {
  for (final problem in EnvConfig.problems) {
    debugPrint('⚠️ [Config] $problem');
  }
  if (!EnvConfig.hasStripePublishableKey) return;

  Stripe.publishableKey = EnvConfig.stripePublishableKey;
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    // Payments will report a clear error; the rest of the app still works.
    debugPrint('⚠️ [Stripe] Initialisation failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initStripe();

  runApp(HarryServiceApp());
}





  class HarryServiceApp extends StatelessWidget {
    const HarryServiceApp({super.key});

    @override
    Widget build(BuildContext context) {

      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_ , child) {
          return GetMaterialApp(
           initialBinding: AppBindings(),
            debugShowCheckedModeBanner: false,
            title: 'Peak Privee',
            // One theme for the whole app: gold, DM Sans, cream background.
            // Without it Flutter falls back to its purple Material default.
            theme: AppTheme.light,
            initialRoute: AppPages.initialRoutes,
            getPages: AppPages.routes,
            // An error from the last screen shouldn't sit over the next one.
            routingCallback: (_) => ToastHost.onRouteChanged(),
          );
        },

      );
    }
  }




