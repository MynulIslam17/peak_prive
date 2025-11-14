import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  final images = Assets.images;
  final controller = PageController();
  bool isLastPage = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
        );
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      isLastPage = index == 2;
    });

    if (isLastPage) {
      _animationController.forward();
    } else {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: controller,
              onPageChanged: _onPageChanged,
              children: [
                _buildPage(
                  title: "Chase the Snow 🏔️",
                  description:
                  "Experience the excitement of skiing down breathtaking slopes. Every ride brings a new rush and unforgettable views.",
                  imagePath: "assets/animations/Snow Beard.json",
                ),
                _buildPage(
                  title: "Your Ride, Right on Time ⏰",
                  description:
                  "Whether it’s to the mountains or the massage studio, we’ve got your transport covered — quick, easy, and reliable.",
                  imagePath: "assets/animations/carpool.json",
                ),
                _buildPage(
                  title: "Long day on the slopes? 🏂",
                  description:
                  "Treat your muscles to the recovery they deserve.\nBook a deep tissue or sports massage and feel the tension melt away.",
                  imagePath: "assets/animations/Massage.json",
                ),
              ],
            ),
        
            /// Bottom Section
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: isLastPage
                    ? SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {  /// move to role selection


                        ///  check if onboard seen or not
                        final prefs=await SharedPreferences.getInstance();
                       await prefs.setBool("onboarding_seen",true);
                        
                        
                        Get.offAllNamed(Routes.role);
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
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Next Button (above dots)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Skip + Dots Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => controller.jumpToPage(2),
                          child: Text(
                            "Skip",
                            style:
                            AppTextStyle.h3_semibold_20().copyWith(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),


                        SmoothPageIndicator(
                          controller: controller,
                          count: 3,
                          effect: WormEffect(
                            activeDotColor: Colors.black,
                            dotColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build single onboarding page
  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// Lottie animation
            Lottie.asset(
              imagePath,
              width: 270,
              height: 270,
              repeat: true,
            ),
            const SizedBox(height: 20),

            /// Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            /// Description
            Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
