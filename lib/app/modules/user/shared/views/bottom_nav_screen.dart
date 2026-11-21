import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/chats/chat_list_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/exit_app_guard.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/lazy_tab_stack.dart';
import '../../../booking/controllers/my_bookings_controller.dart';
import '../../../chats/controllers/chat_list_controller.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../routes/app_routes.dart';

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

  final List<Widget> _screens = [HomeScreen(), BookingScreen(), ChatListScreen(), ProfileScreen()];

  /// Coming back to a tab: show what's there and refresh it quietly.
  void _refreshTab(int i) {
    switch (i) {
      case 1:
        if (Get.isRegistered<MyBookingsController>()) Get.find<MyBookingsController>().refreshFetched();
      case 2:
        if (Get.isRegistered<ChatListController>()) Get.find<ChatListController>().refreshSoon();
    }
  }

  /// System back: from another tab, go to Home first. From Home, go back to
  /// the service picker; when this screen was opened as the root (after a
  /// checkout or a password reset) the picker is opened in its place, and
  /// its own guard asks before closing the app.
  bool _onBack() {
    if (navController.getIndex != 0) {
      navController.changeIndex(0);
      return true;
    }
    if (!Navigator.of(context).canPop()) {
      Get.offAllNamed(Routes.service);
      return true;
    }
    return false; // ExitAppGuard pops back to the picker
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppGuard(
      onBack: _onBack,
      child: GetBuilder<NavController>(
        builder: (controller) {
          return Scaffold(
            // Content scrolls under the floating bar.
            extendBody: true,
            body: LazyTabStack(index: controller.getIndex, onRevisit: _refreshTab, children: _screens),
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
                FloatingNavItem(
                  label: 'Profile',
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
