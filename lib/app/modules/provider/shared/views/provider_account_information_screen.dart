import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_profile_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_image_container.dart';
import '../../../../data/models/user_model.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

class ProviderAccountInformationScreen extends StatefulWidget {
  const ProviderAccountInformationScreen({super.key});

  @override
  State<ProviderAccountInformationScreen> createState() =>
      _ProviderAccountInformationScreenState();
}

class _ProviderAccountInformationScreenState
    extends State<ProviderAccountInformationScreen> {
  final icons = Assets.icons;
  final images = Assets.images;

  /// finds controllers
  final authController = Get.find<AuthController>();
  final profileController = Get.find<GetProfileController>();
  final updateProfileController = Get.find<UpdateProfileController>();

  late final TextEditingController nameTEController;
  late final TextEditingController emailTEController;
  late final TextEditingController phoneTEController;
  late final TextEditingController addressTEController;

  /// Helper to handle null or empty values
  /// Empty for missing values and the backend's "N/A" placeholder, so the
  /// placeholder is never saved back as a real phone number or address.
  String safeText(String? value) {
    final v = value?.trim() ?? '';
    return v.toUpperCase() == 'N/A' ? '' : v;
  }

  @override
  void initState() {
    super.initState();

    /// gets user model from local saves
    final UserModel? user = authController.userModel;

    /// add local saved value first
    nameTEController = TextEditingController(text: safeText(user?.fullName));
    emailTEController = TextEditingController(text: safeText(user?.email));
    phoneTEController = TextEditingController(text: safeText(user?.phone));
    addressTEController = TextEditingController(text: safeText(user?.address));

    _fetchProfileInfo();
  }

  void _fetchProfileInfo() async {
    bool success = await profileController.fetchProfile();
    if (!mounted) return; // ensure widget is still in tree

    if (success) {
      final UserModel? user = profileController.userModel;

      setState(() {
        nameTEController.text = safeText(user?.fullName);
        emailTEController.text = safeText(user?.email);
        phoneTEController.text = safeText(user?.phone);
        addressTEController.text = safeText(user?.address);
      });
    }
  }

  /// update button event
  Future<void> _updateButton() async {
    String name = nameTEController.text.trim();
    String phone = phoneTEController.text.trim();
    String address = addressTEController.text.trim();

    // Validate inputs
    if (name.isEmpty) {
      _showSnackBar("Name cannot be empty", Colors.red);
      return;
    }

    bool success = await updateProfileController.updateProfile(
      fullName: name,
      phoneNumber: phone,
      address: address,
      ApiUrl: AppUrls.updateProfileUrl,
    );

    if (!mounted) return;

    if (success) {
      // Update text controllers with new values
      if (mounted) {
        setState(() {
          nameTEController.text = name;
          phoneTEController.text = phone;
          addressTEController.text = address;
        });
      }

      _showSnackBar("Profile updated successfully", Colors.green);
    } else {
      _showSnackBar(
        updateProfileController.errorMessage ?? "Failed to update profile",
        Colors.red,
      );
    }
  }

  /// Helper method to show snackbar safely
  void _showSnackBar(String message, Color bgColor) {
    final ok = bgColor == Colors.green;
    showAppToast(type: ok ? ToastType.success : ToastType.error, title: ok ? "Saved" : "Couldn't save", message: message);
  }

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    phoneTEController.dispose();
    addressTEController.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: AppTextStyle.sub_h3_regular_14(
              color: readOnly ? AppColors.textTertiary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTextStyle.sub_h3_regular_14(color: AppColors.textDisabled),
              prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.textDisabled)
                  : null,
              filled: true,
              fillColor: readOnly ? AppColors.surfaceAlt : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary_1, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomAppBar(title: "Account information"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  GetBuilder<AuthController>(
                    builder: (authCtrl) {
                      final user = authCtrl.userModel;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CustomCachedImage(
                              width: 56,
                              height: 56,
                              imageUrl: user?.profilePic ?? '',
                              isCircle: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    safeText(user?.fullName).isEmpty
                                        ? 'Your name'
                                        : safeText(user?.fullName),
                                    style: AppTextStyle.sub_h2_medium_16(),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Change your photo from the Profile tab.',
                                    style: AppTextStyle.p_regular_12(
                                        color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: 'Full name',
                    controller: nameTEController,
                    icon: Icons.person_outline_rounded,
                    hint: 'Your name',
                  ),
                  _field(
                    label: 'Email',
                    controller: emailTEController,
                    icon: Icons.mail_outline_rounded,
                    readOnly: true,
                  ),
                  _field(
                    label: 'Phone',
                    controller: phoneTEController,
                    icon: Icons.phone_outlined,
                    hint: '+33 6 12 34 56 78',
                    keyboardType: TextInputType.phone,
                  ),
                  _field(
                    label: 'Address',
                    controller: addressTEController,
                    icon: Icons.home_outlined,
                    hint: 'Street, city',
                    keyboardType: TextInputType.streetAddress,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GetBuilder<UpdateProfileController>(
                builder: (controller) => SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : _updateButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      disabledBackgroundColor:
                          AppColors.primary_1.withValues(alpha: 0.6),
                      foregroundColor: AppColors.textOnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save changes',
                            style: AppTextStyle.sub_h2_medium_16(
                                color: AppColors.textOnPrimary)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
