import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        elevation: 0, // Remove shadow
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // --- Profile Picture Section ---
            _buildProfileAvatar(context),

            SizedBox(height: 10.h),

            // --- User Name ---
            Text(
              'Ankon Akash',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 40.h),

            // --- Menu Items ---
            _buildProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Account Information',
              onTap: () {
                // Handle navigation to Account Information
              },
            ),

            SizedBox(height: 15.h),

            _buildProfileMenuItem(
              icon: Icons.wallet_outlined,
              title: 'Wallet',
              onTap: () {
                // Handle navigation to Wallet
              },
            ),

            SizedBox(height: 15.h),

            _buildProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                // Handle navigation to Settings
              },
            ),

            SizedBox(height: 100.h),

            // --- Log Out Button ---
            _buildLogoutButton(),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // Helper widget for the Profile Avatar and Camera Icon
  Widget _buildProfileAvatar(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // The main Circular Image (Placeholder)
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const AssetImage('assets/images/placeholder_profile.png'), // Replace with actual image asset
            // You can use a NetworkImage or a proper Asset Image here
          ),
          // Positioned Camera Icon Button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the interactive menu items
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
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18.r),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the Log Out button
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.transparent, // Background is white/transparent
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD32F2F), width: 1.5.w), // Red border
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle Log Out logic
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  color: const Color(0xFFD32F2F), // Red icon
                  size: 20.r,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: const Color(0xFFD32F2F), // Red text
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