import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/controllers/nav_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authController = Get.find<AuthController>();
  final updateProfileController = Get.put(UpdateProfileController());
  final picker = ImagePicker();

  File? _selectedImageFile;

  /// --- Show bottom sheet to pick image ---
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose Profile Image", style: AppTextStyle.h3_medium_20()),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// --- Pick image from camera/gallery ---
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
      source: source,
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _selectedImageFile = File(pickedFile.path);

      /// Upload and update profile
      bool success = await updateProfileController.updateProfile(
        profileImage: _selectedImageFile,
        fullName: authController.userModel?.fullName ?? "",
        phoneNumber: authController.userModel?.phone ?? "",
        address: authController.userModel?.address ?? "",
        ApiUrl: AppUrls.updateProfileUrl,
        method: "PATCH",
      );

      if (success) {
        _selectedImageFile = null;
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

      setState(() {}); // refresh UI for local image preview
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Profile",
        onBackPressed: () {
          Get.find<NavController>().changeIndex(0);
        },
      ),
      body: GetBuilder<UpdateProfileController>(
        builder: (controller) {
          final user = authController.userModel;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                /// Profile Image Section
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          /// Profile Image
                          CustomCachedImage(
                            width: 100,
                            height: 100,
                            imageFile: _selectedImageFile,
                            imageUrl: user?.profilePic ?? "",
                            isCircle: true,
                          ),

                          /// Camera Icon Overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImagePickerSheet,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.camera_alt_outlined,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),

                          /// Loading indicator
                          if (controller.isLoading)
                            Positioned.fill(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                                child: SpinKitCircle(
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        user?.fullName ?? "Your Name",
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
                  onTap: () => Get.toNamed(Routes.providerInfoScreen),
                ),
                SizedBox(height: 15.h),
                _buildProfileMenuItem(
                  icon: Icons.wallet_outlined,
                  title: 'Wallet',
                  onTap: () => Get.toNamed(Routes.userWallet),
                ),
                SizedBox(height: 15.h),
                _buildProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Get.toNamed(Routes.providerSettingsScreen),
                ),
                SizedBox(height: 100.h),

                // --- Logout Button ---
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
            offset: Offset(0, 5),
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
                        color: Colors.black87),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey.shade400, size: 18.r),
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
        border: Border.all(color: Color(0xFFD32F2F), width: 1.5.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            authController.logout();
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Color(0xFFD32F2F), size: 20.r),
                SizedBox(width: 10.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}