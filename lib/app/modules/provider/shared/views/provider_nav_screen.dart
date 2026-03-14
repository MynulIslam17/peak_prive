import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';

import 'package:harry_service_app/app/modules/provider/shared/views/Provider_service_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/chats/chat_list_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_home_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_profile_secreen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';

import '../../../../../gen/assets.gen.dart';

class ProviderNavScreen extends StatefulWidget {
  const ProviderNavScreen({super.key});

  @override
  State<ProviderNavScreen> createState() => _ProviderNavScreenState();
}

class _ProviderNavScreenState extends State<ProviderNavScreen> {
  final icons = Assets.icons;
  final images = Assets.images;

  final navController = Get.find<NavController>();

  final List<Widget> _screens = [
    ProviderHomeScreen(),
    ProviderServiceScreen(),
    ProviderBookingRequestScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<NavController>(
        builder: (controller) {
          return _screens[controller.getIndex];
        },
      ),

      bottomNavigationBar: GetBuilder<NavController>(
        builder: (controller) {
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: AppColors.primary_1,

            currentIndex: navController.getIndex,
            onTap: (index) {
              navController.changeIndex(index);
            },

            items: [
              BottomNavigationBarItem(
                icon: icons.home.svg(color: Colors.grey, width: 20, height: 20),
                activeIcon: icons.home.svg(
                  color: AppColors.primary_1,
                  width: 20,
                  height: 20,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: icons.service.svg(width: 20, height: 20),
                activeIcon: icons.service.svg(
                  color: AppColors.primary_1,
                  width: 20,
                  height: 20,
                ),
                label: "Service",
              ),

              BottomNavigationBarItem(
                icon: icons.notepad.svg(width: 20, height: 20),
                activeIcon: icons.notepad.svg(
                  color: AppColors.primary_1,
                  width: 20,
                  height: 20,
                ),
                label: "Booking",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, size: 20, color: Colors.grey),
                activeIcon: Icon(
                  Icons.chat,
                  size: 20,
                  color: AppColors.primary_1,
                ),
                label: "Chats",
              ),

              BottomNavigationBarItem(
                icon: icons.profile.svg(width: 20, height: 20),
                activeIcon: icons.profile.svg(
                  color: AppColors.primary_1,
                  width: 20,
                  height: 20,
                ),
                label: "Profile",
              ),
            ],
          );
        },
      ),
    );
  }
}
