import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/chats/chat_list_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/lazy_tab_stack.dart';
import '../../../booking/controllers/my_bookings_controller.dart';
import '../../../chats/controllers/chat_list_controller.dart';
import '../../../../core/controllers/nav_controller.dart';

import 'booking_screen.dart';
import 'package:harry_service_app/app/modules/chats/widgets/chat_unread_badge.dart';
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

  /// Coming back to a tab: show what's there and refresh it quietly.
  void _refreshTab(int i) {
    switch (i) {
      case 1:
        if (Get.isRegistered<MyBookingsController>()) Get.find<MyBookingsController>().refreshFetched();
      case 2:
        if (Get.isRegistered<ChatListController>()) Get.find<ChatListController>().refreshSoon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      builder: (controller) {
        return Scaffold(
          // Content scrolls under the floating bar.
          extendBody: true,
          body: LazyTabStack(
            index: controller.getIndex,
            onRevisit: _refreshTab,
            children: _screens,
          ),
          bottomNavigationBar: FloatingNavBar(
            index: controller.getIndex,
            onTap: navController.changeIndex,
            items: const [
              FloatingNavItem(label: 'Home', icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded)),
              FloatingNavItem(
                label: 'Booking',
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
              ),
              FloatingNavItem(
                label: 'Chat',
                icon: ChatUnreadBadge(Icons.chat_bubble_outline_rounded),
                activeIcon: ChatUnreadBadge(Icons.chat_bubble_rounded),
              ),
              FloatingNavItem(label: 'Profile', icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded)),
            ],
          ),
        );
      },
    );
  }
}
