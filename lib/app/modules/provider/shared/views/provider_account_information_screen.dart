

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/profile_field_box.dart';

class ProviderAccountInformationScreen extends StatefulWidget {
  const ProviderAccountInformationScreen({super.key});

  @override
  State<ProviderAccountInformationScreen> createState() => _ProviderAccountInformationScreenState();
}

class _ProviderAccountInformationScreenState extends State<ProviderAccountInformationScreen> {

  final icons=Assets.icons;
  final images=Assets.images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBarWithTitle(icons: icons,title: "Account  Information", onTap: (){
        Get.back();
      }),



      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [


            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    SizedBox(height: 25),

                    /// profile image/ name section
                    Container(
                      height: 160,

                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          SizedBox(width: 24,),
                          CircleAvatar(
                            backgroundImage: images.user2.provider(),
                            radius: 50,
                          ),

                          const SizedBox(width: 10),
                          Flexible(child: Text("Azzan Mahmud", style: AppTextStyle.h3_medium_20(),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                        ],
                      ),
                    ),


                    SizedBox(height: 20),

                    /// profile indo filed
                    ProfileFieldBox(
                      leadingIcon: icons.user,


                      onTap: () {

                      },
                      title: 'Azzan MahmudMahmudMahmud',
                    ),
                    SizedBox(height: 16),

                    /// wallets
                    ProfileFieldBox(
                      leadingIcon: icons.mail,

                      onTap: () {},
                      title: "akash245@gmail.com",
                    ),

                    /// phone
                    SizedBox(height: 16),

                    ProfileFieldBox(
                      leadingIcon: icons.phone,


                      onTap: () {},
                      title: "(480) 555-3434",
                    ),

                    /// location
                    SizedBox(height: 16),

                    ProfileFieldBox(
                      leadingIcon: icons.phone,


                      onTap: () {},
                      title: "2955 washterimer RD. santa area, sans Fransicco",
                    ),


                  ],
                ),
              ),
            ),



            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: SizedBox(
                height: 55,
                child: CustomButton(onTap: (){}, text: "Edit",

                    backgroundColor: AppColors.primary_1),
              ),
            )








          ],),
        ),
      ),







    );
  }
}
