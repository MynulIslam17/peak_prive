import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/profile_field_box.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../routes/app_routes.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  final icons = Assets.icons;
  final images = Assets.images;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBarWithTitle(icons: icons, onTap: () {}, title: "Settings"),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              ProfileFieldBox(
                leadingIcon: icons.lock,
                onTap: () {
                  Get.toNamed(Routes.providerPassScreen);
                },
                title: "Change Password",
                actionIcons: icons.careRight,
              ),
              SizedBox(height: 20),

              ProfileFieldBox(
                leadingIcon: icons.privacy2,
                onTap: () {},
                title: "Privacy Policy",
                actionIcons: icons.careRight,
              ),
              SizedBox(height: 20),
              ProfileFieldBox(
                leadingIcon: icons.error,
                onTap: () {},
                title: "Terms & Conditions",
                actionIcons: icons.careRight,
              ),
              SizedBox(height: 20),
              ProfileFieldBox(
                leadingIcon: icons.info,
                onTap: () {},
                title: "About Us",
                actionIcons: icons.careRight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
