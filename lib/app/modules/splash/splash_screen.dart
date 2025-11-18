import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  final authController=Get.find<AuthController>();

  /// move  to next screen

  void moveToNextScreen() async{

   await Future.delayed(Duration(seconds: 2)); /// add delay

   /// check if onboard seen or not
    final prefs=await SharedPreferences.getInstance();
    bool seen=prefs.getBool("onboarding_seen") ?? false;

    if(!seen){ /// if onboarding not seen
      Get.offAllNamed(Routes.onBoarding);
      return;
    }

/// if onboarding seen then first load user then check if he login in or not
    await authController.loadUserData();

    if(!authController.isLoggedIn){ /// if not login then show role selection

      Get.offAllNamed(Routes.role);
      return;
    }

    if (authController.role == "provider") { /// if login then check the role then based on the role shows page
      Get.offAllNamed(Routes.providerNavScreen);
    } else {
      Get.offAllNamed(Routes.service);
    }
  }





  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      moveToNextScreen();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Logo", style: AppTextStyle.h2_semibold_22())),
        ],
      ),
    );
  }
}
