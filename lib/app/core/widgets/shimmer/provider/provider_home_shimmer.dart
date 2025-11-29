import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';

import 'package:harry_service_app/app/core/controllers/auth_controller.dart';

import '../../../../modules/provider/shared/controllers/provider_home_controller.dart';

class ProviderHomeShimmer extends StatelessWidget {
  const ProviderHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<ProviderHomeController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  SizedBox(height: 20),

                  /// Profile shimmer
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 120, height: 15, color: Colors.grey),
                          SizedBox(height: 6),
                          Container(width: 80, height: 12, color: Colors.grey),
                        ],
                      ),
                      Spacer(),
                      Container(width: 30, height: 30, 
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12)
                      ),)
                    ],
                  ),

                  SizedBox(height: 20),

                  /// Pending requests shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                          (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 85,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  /// My service shimmer
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Container(
                       width: 110,
                       height: 20,
                       color: Colors.grey,
                     ),  Container(
                       width: 60,
                       height: 20,
                       color: Colors.grey,
                     ),
                   ],
                 ),
                  SizedBox(height: 11),
                  SizedBox(
                    height: 255,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  /// Booking management shimmer
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
