import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authController = Get.find<AuthController>();
  final updateProfileController = Get.put(UpdateProfileController());

  File? _imagePath;
  final picker = ImagePicker();

  /// Pick image and automatically upload
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imagePath = File(pickedFile.path);
      });

      /// Call API only if user selected an image
      bool success = await updateProfileController.updateProfile(
        profileImage: _imagePath,
        fullName: authController.userModel?.fullName ?? "",
        phoneNumber: authController.userModel?.phone ?? "",
        address: authController.userModel?.address ?? "",
        method: "PATCH",
        ApiUrl: AppUrls.updateProfileUrl,
      );

      if (success) {
        // Clear local image path after successful upload
        setState(() {
          _imagePath = null;
        });

        Get.snackbar(
          "Success",
          "Profile image updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (updateProfileController.errorMessage != null) {
        Get.snackbar(
          "Error",
          updateProfileController.errorMessage!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      debugPrint("No image selected, API not called");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: GetBuilder<UpdateProfileController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                /// Profile image - NOW REACTIVE
                Container(
                  height: 249,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Show loading indicator while uploading
                          if (controller.isLoading)
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _imagePath != null
                                  ? FileImage(_imagePath!) as ImageProvider
                                  : (authController.userModel?.profilePic.isNotEmpty == true
                                  ? NetworkImage(authController.userModel!.profilePic)
                                  : const AssetImage("assets/images/profile_img.jpg")) as ImageProvider,
                            ),

                          // Only show camera button when not loading
                          if (!controller.isLoading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 18,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authController.userModel?.fullName ?? "Your Name",
                        style: AppTextStyle.h3_medium_20(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // --- Menu Items ---
                _buildProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Account Information',
                  onTap: () {
                    Get.toNamed(Routes.providerInfoScreen);
                  },
                ),
                SizedBox(height: 15.h),
                _buildProfileMenuItem(
                  icon: Icons.wallet_outlined,
                  title: 'Wallet',
                  onTap: () {
                    Get.toNamed(Routes.userWallet);
                  },
                ),
                SizedBox(height: 15.h),
                _buildProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Get.toNamed(Routes.providerSettingsScreen);
                  },
                ),
                SizedBox(height: 100.h),

                // --- Log Out Button ---
                _buildLogoutButton(),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade700, size: 24.r),
                SizedBox(width: 15.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 18.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFD32F2F),
          width: 1.5.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async{

            authController.logout();


          },
          borderRadius: BorderRadius.circular(10.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  color: const Color(0xFFD32F2F),
                  size: 20.r,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: const Color(0xFFD32F2F),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}