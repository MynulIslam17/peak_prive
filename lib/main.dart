
  
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/bindings/app_bindings.dart';
import 'package:harry_service_app/app/core/constants/env_config.dart';

import 'package:harry_service_app/app/routes/app_pages.dart';

import 'gen/assets.gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with compile-time injected publishable key
  Stripe.publishableKey = EnvConfig.stripePk;

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
            title: 'Service App',
            initialRoute: AppPages.initialRoutes,
            getPages: AppPages.routes,
          );
        },

      );
    }
  }




