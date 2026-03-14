import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/chats/chat_list_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/controllers/nav_controller.dart';

import 'booking_screen.dart';
import 'home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final navController = Get.find<NavController>();
  final icon = Assets.icons;

  final List<Widget> _screens = [
    HomeScreen(),
    BookingScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      builder: (controller) {
        return Scaffold(
          body: _screens[controller.getIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.getIndex,
            onTap: navController.changeIndex,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary_1,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: "Booking",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_outlined),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),

            ],
          ),
        );
      },
    );
  }
}
