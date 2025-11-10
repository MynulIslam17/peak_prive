

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/appbar_with_title.dart';

class ProviderPassScreen extends StatefulWidget {
  const ProviderPassScreen({super.key});

  @override
  State<ProviderPassScreen> createState() => _ProviderPassScreenState();
}

class _ProviderPassScreenState extends State<ProviderPassScreen> {

  final icons=Assets.icons;
  final images=Assets.icons;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBarWithTitle(icons: icons,title: "Account  Information", onTap: (){
        Get.back();
      }),
      
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      CustomTextField(hintText: "Old Password",isPassword: true,),
                      SizedBox(height: 20,),
                      CustomTextField(hintText: "Set New Password",isPassword: true,),
                      SizedBox(height: 20,),
                      CustomTextField(hintText: "Re-type New Password",isPassword: true,),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text("Forgot password?",style: AppTextStyle.p_regular_12(),),
                      ),


                      SizedBox(height: 20,),




                    ],
                  ),
                ),
              ),



              SizedBox(
                  height: 55,
                  child: CustomButton(onTap: (){}, text: "Update Password", backgroundColor: AppColors.primary_1))




            ],
          ),
        ),
      ),

      




    );
  }

}
