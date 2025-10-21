import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/make_clickable.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/widgets/blury_container.dart';

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

                        switch(index){
                          case 0:
                           Get.toNamed(Routes.pass_nav_screen);
                            break;
                          case 1:
                            print("Ski Hire"); // Second container action
                            break;
                          case 2:
                            print("Transport"); // Third container action
                            break;
                          case 3:
                            print("Restaurant Booking"); // Fourth container action
                            break;
                          default:
                            print("Message"); // Fifth container or any other
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
