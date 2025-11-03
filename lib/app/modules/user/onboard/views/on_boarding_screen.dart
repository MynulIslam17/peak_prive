import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: PageView(
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
      ),

      // Bottom Section
      bottomSheet: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLastPage
              ? Center(
            child: ElevatedButton(
              onPressed: () {

                Get.offAllNamed(Routes.service);

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: Text(
                "Get Started",
                style: AppTextStyle.h3_semibold_20()
                    .copyWith(fontSize: 18, color: Colors.white),
              ),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.jumpToPage(2),
                child: Text(
                  "Skip",
                  style: AppTextStyle.h3_semibold_20()
                      .copyWith(fontSize: 16),
                ),
              ),
              Center(
                child: SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect: const WormEffect(
                    activeDotColor: Colors.black,
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                  onDotClicked: (index) => controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                ),
                child: Text(
                  "Next",
                  style: AppTextStyle.h3_semibold_20()
                      .copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page UI builder
  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 82, left: 24),
          child: SizedBox(
            width: 300,
            child: Text(
              title,
              style: AppTextStyle.h3_semibold_20()
                  .copyWith(fontSize: 36, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }
}
