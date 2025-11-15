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

    final prefs=await SharedPreferences.getInstance();
    bool seen=prefs.getBool("onboarding_seen") ?? false;

    if(!seen){
      Get.offAllNamed(Routes.onBoarding);
      return;
    }


    await authController.loadUserData();

    if(!authController.isLoggedIn){

      Get.offAllNamed(Routes.role);
      return;
    }

    if (authController.role == "provider") {
      Get.offAllNamed(Routes.providerNavScreen);
    } else {
      Get.offAllNamed(Routes.bottomNav);
    }
  }





  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      moveToNextScreen();
    });
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
