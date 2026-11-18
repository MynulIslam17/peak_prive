import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/widgets/profile_field_box.dart';
import '../../../../routes/app_routes.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                    
                      children: [
                        SizedBox(height: 25),
                    
                        /// profile image/ name section
                        Container(
                          height: 249,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Profile", style: AppTextStyle.h3_medium_20()),
                              const SizedBox(height: 20),
                    
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: images.user2.provider(),
                                    radius: 50,
                                  ),
                    
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text("Azzan Mahmud", style: AppTextStyle.h3_medium_20()),
                            ],
                          ),
                        ),

                    
                        SizedBox(height: 20),
                    
                        /// profile indo filed
                        ProfileFieldBox(
                          leadingIcon: icons.user,
                          actionIcons: icons.careRight,
                          onTap: () {
                            Get.toNamed(Routes.providerInfoScreen);
                          },
                          title: 'Account Information',
                        ),
                        SizedBox(height: 16),

                        /// wallets
                        ProfileFieldBox(
                          leadingIcon: icons.wallet,
                          actionIcons: icons.careRight,
                          onTap: () {



                          },
                          title: "Wallet",
                        ),
                    
                        /// settings
                        SizedBox(height: 16),
                    
                        ProfileFieldBox(
                          leadingIcon: icons.settings,
                          actionIcons: icons.careRight,
                          onTap: () {
                            Get.toNamed(Routes.providerSettingsScreen);
                          },
                          title: "Settings",
                        ),
                    
                    
                      ],
                    ),
                  ),
                ),
         


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: InkWell(
                  onTap: () => Get.find<AuthController>().logout(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration:BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                      icons.logout.svg(),
                      SizedBox(width: 10,),
                      Text("LogOut",style: AppTextStyle.sub_h3_medium_14(),),
                    ],),
                  ),
                ),
              )





            ],
          ),
        ),
      ),
    );
  }
}
