import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:harry_service_app/app/modules/auth/controllers/email_verify_controller.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';

import '../../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {


  /// textEditingController

  final emailTEController=TextEditingController();

  ///getx controllers
  final emailController=Get.find<EmailVerifyController>();

  @override
  void dispose() {
    // TODO: implement dispose

    emailTEController.dispose();

    super.dispose();

  }


  final icons = Assets.icons;
  final images = Assets.images;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithTitle(
        icons: icons,
        onTap: () {},
        title: "E-mail Verification",
      ),



      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(

          children: [

            images.skiAccories3.image(),


            SizedBox(height: 50,),

            CustomTextField(
              controller: emailTEController,
              hintText: "Email",
              filledColor: Color(0xffF0F0F0),
              prefixIcon: Icons.email,


            ),
            SizedBox(height: 40,),
            
            /// send otp button
            GetBuilder<EmailVerifyController>(builder: (controller){

              return controller.emailVerifyProgress
                  ?CircularProgressIndicator(color: AppColors.primary_1,)
                  :Flexible(
                child: CustomButton(

                    onTap: _verifyEmailHandler, text: "Send OTP", backgroundColor:AppColors.primary_1),
              );

            })


          ],
        ),
      ),
    );
  }
  
  
  /// send otp handler event
  
  void _verifyEmailHandler()async {
    final email = emailTEController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Email field can't be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.black,
      );
      return;
    }

    if(!EmailValidator.validate(email)){
      Get.snackbar(
        "Error",
        "Not a valid email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.black,
      );
      return;
    }


    /// if everyThings ok call api

    bool response = await emailController.emailVerify(email);

    if(response){ /// if successful
      Get.snackbar("Otp", "A Otp send to your email",snackPosition: SnackPosition.TOP,backgroundColor: AppColors.primary_1);

      Get.toNamed(
        Routes.otpVerify,
        /// pass email and flag to otp verify class
        arguments: {
          "isFromSignUp": false,
          "email" : email
        },
      );
    }else{ /// if Umsuccessful

      Get.snackbar("Error","${emailController.errorMessage},",snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.red);

    }



  }



  
}
