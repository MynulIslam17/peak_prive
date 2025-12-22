import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_profile_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../data/models/user_model.dart';

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
  String safeText(String? value) {
    if (value == null || value.trim().isEmpty) return "N/A";
    return value;
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    phoneTEController.dispose();
    addressTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          Get.back();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithTitle(
          icons: icons,
          title: "Account Information",
          onTap: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 25),

                        /// Profile Header
                        GetBuilder<AuthController>(
                          builder: (authCtrl) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: authCtrl.userModel?.profilePic.isNotEmpty == true
                                        ? NetworkImage(authCtrl.userModel!.profilePic) as ImageProvider
                                        : const AssetImage("assets/images/profile_img.jpg") as ImageProvider,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      safeText(authCtrl.userModel?.fullName),
                                      style: AppTextStyle.h3_medium_20(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        /// Name Field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Name",
                            style: AppTextStyle.c_regular_12(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameTEController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// Email Field (Read-only)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: AppTextStyle.c_regular_12(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailTEController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.mail,
                              color: Colors.grey,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// Phone Field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Phone",
                            style: AppTextStyle.c_regular_12(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneTEController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.12),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),

                        /// Address Field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Address",
                            style: AppTextStyle.c_regular_12(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: addressTEController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.location_city,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.12),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                /// Save Button
                GetBuilder<UpdateProfileController>(
                  builder: (controller) {
                    return controller.isLoading
                        ? CircularProgressIndicator(color: AppColors.primary_1)
                        : SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: CustomButton(
                        text: "Save Changes",
                        backgroundColor: AppColors.primary_1,
                        onTap: _updateButton,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}