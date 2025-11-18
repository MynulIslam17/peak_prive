import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/make_clickable.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/blury_container.dart';


class AllServiceScreen extends StatefulWidget {
  const AllServiceScreen({super.key});

  @override
  State<AllServiceScreen> createState() => _AllServiceScreenState();
}

class _AllServiceScreenState extends State<AllServiceScreen> {
  List<String> serviceList = [
    "Ski Pass",
    "Ski Hire",
    "Transport",
    "Restaurant Booking",
    "Message",
  ];


  final navController=Get.find<NavController>();

  final image = Assets.images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// whole app background
          image.opening.image(height: double.infinity, fit: BoxFit.cover),

          /// blury container
          Center(
            child: BlurryContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(serviceList.length, (index) {
                  String serviceName = serviceList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: MakeClickable(
                      onTap:(){

                        ///tips :  one controller used add service type of recognize use mode is on
                        switch(index){
                          case 0:
                            navController.resetIndex(); /// reset the index
                            navController.addType("ski_pass");
                           Get.toNamed(Routes.bottomNav);
                            break;
                          case 1:

                            navController.resetIndex();
                            navController.addType("ski_hire");
                             Get.toNamed(Routes.bottomNav);
                            break;
                          case 2:
                            navController.resetIndex();
                            navController.addType("transport");
                            Get.toNamed(Routes.bottomNav);
                            break;
                          case 3:
                            navController.resetIndex();
                            navController.addType("restaurant");
                            Get.toNamed(Routes.bottomNav);
                            break;
                          case 4 :
                            navController.resetIndex();
                            navController.addType("massage");
                            Get.toNamed(Routes.bottomNav);
                          default:
                            print("execute default conditions");
                            break;
                        }


                      } ,
                      child: Container(
                        height: 44.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppColors.primary_1 : null,
                          borderRadius: BorderRadius.circular(8),
                          border: index != 0
                              ? Border.all(color: AppColors.primary_1, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            serviceName,
                            style: AppTextStyle.sub_h1_medium_18(
                              color: index != 0
                                  ? AppColors.primary_3
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
