import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/collapsing_header.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
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
    final pickedFile = await picker.pickImage(source: source, maxHeight: 600, maxWidth: 600, imageQuality: 80);

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
        showAppToast(type: ToastType.success, title: "Success", message: "Profile image updated successfully");
      } else if (updateProfileController.errorMessage != null) {
        showAppToast(type: ToastType.error, title: "Error", message: updateProfileController.errorMessage!);
      }

      setState(() {}); // refresh UI for local image preview
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CollapsingHeaderLayout(
        expandedHeight: 76,
        collapsedHeight: 56,
        header: (_, t) => LargeTitleHeader(title: 'Profile', t: t, onBack: canPop ? Get.back : null),
        body: (_, insets) => GetBuilder<UpdateProfileController>(
          builder: (controller) {
            final user = authController.userModel;
            final isProvider = (user?.role ?? '').toLowerCase() == 'provider' || (user?.providerType ?? '').isNotEmpty;
            final type = (user?.providerType ?? '').replaceAll('_', ' ').trim();
            final email = (user?.email ?? '').trim();

            return ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h) + insets,
              children: [
                // --- Header card ---
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary_3, width: 2),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomCachedImage(
                                  width: 92,
                                  height: 92,
                                  imageFile: _selectedImageFile,
                                  imageUrl: user?.profilePic ?? "",
                                  isCircle: true,
                                ),
                                if (controller.isLoading)
                                  Container(
                                    width: 92,
                                    height: 92,
                                    decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                    child: const SpinKitCircle(color: Colors.white, size: 28),
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: -2,
                            child: Material(
                              color: AppColors.primary_1,
                              shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: controller.isLoading ? null : _showImagePickerSheet,
                                child: const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.textOnPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        const {'', 'N/A'}.contains((user?.fullName ?? '').trim().toUpperCase())
                            ? "Your name"
                            : user!.fullName.trim(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.h3_semibold_20(),
                      ),
                      if (email.isNotEmpty && email != 'N/A') ...[
                        SizedBox(height: 2.h),
                        Text(email, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                      ],
                      if (isProvider && type.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF3DC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$type provider',
                            style: AppTextStyle.p_medium_12(color: const Color(0xFF9A7A12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // --- Menu ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Account information',
                        onTap: () => Get.toNamed(Routes.providerInfoScreen),
                      ),
                      const Divider(height: 1, indent: 60, color: AppColors.border),
                      // Same screen: providers get balance + withdrawals,
                      // customers their booking payments and refunds.
                      authController.userModel?.role != "User"
                          ? _buildProfileMenuItem(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Wallet',
                              onTap: () => Get.toNamed(Routes.userWallet),
                            )
                          : _buildProfileMenuItem(
                              icon: Icons.receipt_long_outlined,
                              title: 'Payments',
                              onTap: () => Get.toNamed(Routes.userWallet),
                            ),
                      const Divider(height: 1, indent: 60, color: AppColors.border),
                      _buildProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => Get.toNamed(Routes.providerSettingsScreen),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // --- Logout ---
                _buildLogoutButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: const Color(0xFFFBF3DC), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 19, color: const Color(0xFF9A7A12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyle.sub_h3_medium_14(color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => authController.logout(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: const Color(0xFFFBEAEA), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, size: 19, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Text('Log out', style: AppTextStyle.sub_h3_medium_14(color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
