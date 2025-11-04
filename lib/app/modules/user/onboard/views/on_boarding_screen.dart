import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../routes/app_routes.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final images = Assets.images;
  final controller = PageController();

  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2; // update exactly when page changes
              });
            },
            children: [
              _buildPage(
                title: "Find and connect with trusted service!",
                description: "",
                imagePath: "assets/images/onboard1.png",
              ),
              _buildPage(
                title: "Recharge your body. Refresh your mind!",
                description: "",
                imagePath: "assets/images/onboard2.png",
              ),
              _buildPage(
                title: "Hit the slopes — your next adventure starts here!",
                description: "",
                imagePath: "assets/images/onboard3.png",
              ),
            ],
          ),

          Container(
            alignment: Alignment(0, 0.78),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: isLastPage
                  ? SizedBox(
                      height: 52,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          /// go it login screen
                          Get.offAllNamed(Routes.login);


                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        child: Text(
                          "Get Started",
                          style: AppTextStyle.sub_h2_medium_16(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => controller.jumpToPage(2),
                          child: Text(
                            "Next",
                            style: AppTextStyle.h3_semibold_20().copyWith(
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SmoothPageIndicator(
                          controller: controller,
                          count: 3,
                          effect: WormEffect(
                            activeDotColor: Colors.white,
                            dotColor: Colors.orange,
                          ),
                        ),

                        TextButton(
                          onPressed: () => controller.jumpToPage(2),
                          child: Text(
                            "Skip",
                            style: AppTextStyle.h3_semibold_20().copyWith(
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),


    );
  }

  /// building page design
  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Stack(
      children: [
        /// Background image that covers full screen
        Positioned.fill(
          child: Image.asset(
            imagePath,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        /// Foreground text inside SafeArea to avoid cut-off
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 82, left: 24),
            child: SizedBox(
              width: 300,
              child: Text(
                title,
                style: AppTextStyle.h3_semibold_20().copyWith(
                  fontSize: 36,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
