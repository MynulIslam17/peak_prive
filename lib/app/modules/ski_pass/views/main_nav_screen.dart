import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/modules/ski_pass/controllers/nav_controller.dart';
import 'package:harry_service_app/app/modules/ski_pass/views/home_screen.dart';

import '../../../../gen/assets.gen.dart';

class PassNavScreen extends StatefulWidget {
  const PassNavScreen({super.key});

  @override
  State<PassNavScreen> createState() => _PassNavScreenState();
}

class _PassNavScreenState extends State<PassNavScreen> {
  final icons = Assets.icons;

  final navController = Get.find<NavController>();

  final List<Widget> _screens = [
    HomeScreen(),
    Center(child: Text("booking")),
    Center(child: Text("profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<NavController>(
          builder: (controller) {
            return _screens[navController.getIndex];
          },
        ),
      ),

      bottomNavigationBar: GetBuilder<NavController>(
        builder: (controller) {
          return BottomNavigationBar(
            currentIndex: navController.getIndex,
            onTap: (index) {
              navController.changeIndex(index);
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "hone"),

              BottomNavigationBarItem(
                icon: icons.calendarDots.svg(),
                label: "booking",
              ),
              BottomNavigationBarItem(icon: icons.user.svg(), label: "profile"),





            ],
          );
        },
      ),
    );
  }
}
