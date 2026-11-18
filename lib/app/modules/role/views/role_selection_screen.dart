import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/role_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';


class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  final roleController = Get.find<RoleController>();
  final icons = Assets.icons;

  void onContinue() {
    if (roleController.getRole.isEmpty) {
      showAppToast(type: ToastType.warning, title: "Select a Role", message: "Please choose one option to continue.");
      return;
    }

    print("Selected Role: ${roleController.getRole}");
    Get.toNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Select Role",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),

      /// Scrollable body
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: GetBuilder<RoleController>(
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How are you going to use this app?",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Choose the account type that fits you best.",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 32.h),

              /// Provider Card
              RoleCard(
                title: "Provider",
                subtitle: "I want to offer my services (e.g. ski, massage)",
                icon: icons.service2,
                selected: roleController.getRole == "Provider",
                onTap: () => roleController.changeRole("Provider"),
              ),
              SizedBox(height: 16.h),

              /// Customer Card
              RoleCard(
                title: "Customer",
                subtitle: "I want to book services (e.g. transport, massage)",
                icon: icons.user,
                selected: roleController.getRole == "Customer",
                onTap: () => roleController.changeRole("Customer"),
              ),
              SizedBox(height: 100.h), // spacing before button
            ],
          ),
        ),
      ),

      /// Fixed Bottom Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 32.h),
        child: SizedBox(
          height: 55.h,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary_1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}




class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final SvgGenImage icon;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary_1 : Colors.grey.shade300,
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            icon.svg(width: 30, height: 30),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4,),
            if (selected)
              Icon(Icons.check_circle, color: Colors.black, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

