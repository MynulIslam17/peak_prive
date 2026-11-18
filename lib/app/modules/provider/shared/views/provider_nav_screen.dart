import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/floating_nav_bar.dart';
import 'package:harry_service_app/app/core/widgets/lazy_tab_stack.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_list_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/all_booking_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/my_listings_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';

import 'package:harry_service_app/app/modules/provider/shared/views/Provider_service_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/chats/chat_list_screen.dart';
import 'package:harry_service_app/app/modules/chats/widgets/chat_unread_badge.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_home_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';
import 'package:harry_service_app/app/core/widgets/exit_app_guard.dart';

class ProviderNavScreen extends StatefulWidget {
  const ProviderNavScreen({super.key});

  @override
  State<ProviderNavScreen> createState() => _ProviderNavScreenState();
}

class _ProviderNavScreenState extends State<ProviderNavScreen> {
  final navController = Get.find<NavController>();

  final List<Widget> _screens = [
    ProviderHomeScreen(),
    ProviderServiceScreen(),
    ProviderBookingRequestScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  /// Coming back to a tab: show what's there and refresh it quietly.
  void _refreshTab(int i) {
    switch (i) {
      case 0:
        if (Get.isRegistered<ProviderHomeController>()) Get.find<ProviderHomeController>().refreshData();
      case 1:
        if (Get.isRegistered<MyListingsController>()) Get.find<MyListingsController>().load(showLoader: false);
      case 2:
        if (Get.isRegistered<ProviderBookingsController>()) Get.find<ProviderBookingsController>().refreshBookings();
      case 3:
        if (Get.isRegistered<ChatListController>()) Get.find<ChatListController>().refreshSoon();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The provider app's last screen: back first returns to Home, then asks
    // before closing the app.
    return ExitAppGuard(
      onBack: () {
        final nav = Get.find<NavController>();
        if (nav.getIndex == 0) return false;
        nav.changeIndex(0);
        return true;
      },
      child: Scaffold(
        // Content scrolls under the floating bar.
        extendBody: true,
        body: GetBuilder<NavController>(
          builder: (controller) {
            return LazyTabStack(index: controller.getIndex, onRevisit: _refreshTab, children: _screens);
          },
        ),

        bottomNavigationBar: GetBuilder<NavController>(
          builder: (controller) {
            return FloatingNavBar(
              index: controller.getIndex,
              onTap: controller.changeIndex,
              items: const [
                FloatingNavItem(label: 'Home', icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded)),
                FloatingNavItem(
                  label: 'Services',
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront_rounded),
                ),
                FloatingNavItem(
                  label: 'Bookings',
                  icon: _RequestsBadge(Icons.calendar_month_outlined),
                  activeIcon: _RequestsBadge(Icons.calendar_month_rounded),
                ),
                FloatingNavItem(
                  label: 'Chats',
                  icon: ChatUnreadBadge(Icons.chat_bubble_outline_rounded),
                  activeIcon: ChatUnreadBadge(Icons.chat_bubble_rounded),
                ),
                FloatingNavItem(
                  label: 'Profile',
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bookings tab icon with the number of requests waiting for approval.
class _RequestsBadge extends StatelessWidget {
  const _RequestsBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProviderHomeController>()) return Icon(icon);
    return GetBuilder<ProviderHomeController>(
      builder: (c) {
        final n = c.requestCount;
        return Badge(
          isLabelVisible: n > 0,
          backgroundColor: AppColors.error,
          label: Text(n > 99 ? '99+' : '$n'),
          child: Icon(icon),
        );
      },
    );
  }
}
