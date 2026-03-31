// lib/core/controllers/auth_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/data/services/socket/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../modules/chats/controllers/chat_list_controller.dart';
import '../../routes/app_routes.dart';
import '../constants/api_urls.dart';

/// AuthController manages user authentication, token storage,
/// user profile, and socket initialization for real-time communication.
///
/// Responsibilities:
/// 1. Save and load user data (token, role, provider type).
/// 2. Initialize and reset SocketService for real-time chat.
/// 3. Update user profile.
/// 4. Handle logout and cleanup.
/// 5. Provide authentication status.
class AuthController extends GetxController {
  // -------------------------
  // KEYS FOR SHARED PREFERENCES
  // -------------------------
  static const String _tokenKey = 'access-token';
  static const String _userDataKey = 'user-model';
  static const String _roleKey = 'role';
  static const String _providerTypeKey = 'providerType';

  // -------------------------
  // VARIABLES
  // -------------------------
  String? accessToken;
  String? role;
  UserModel? userModel;

  // -------------------------
  // SAVE USER DATA + TOKEN + ROLE
  // -------------------------
  /// Save user information and token in local storage
  /// and initialize or reset [SocketService] for chat.
  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save data in SharedPreferences
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));
    await prefs.setString(_roleKey, model.role);
    if (model.providerType != null) {
      await prefs.setString(_providerTypeKey, model.providerType!);
    }

    // Update local variables
    accessToken = token;
    userModel = model;
    role = model.role;

    // -------------------------
    // Socket initialization
    // -------------------------
    if (Get.isRegistered<SocketService>()) {
      // Reset existing socket for a different user login
      Get.find<SocketService>().reset(
        userId: model.id,
        token: token,
        baseUrl: AppUrls.socketBaseUrl,
      );
    } else {
      // Create a new socket for the first time
      await Get.putAsync<SocketService>(
            () => SocketService().init(
          userId: model.id,
          token: token,
          baseUrl: AppUrls.socketBaseUrl,
        ),
        permanent: true,
      );
    }

    // Setup chat list socket listener if controller exists
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().setSocketListener();
    }
  }

  // -------------------------
  // LOAD USER DATA
  // -------------------------
  /// Load user data from local storage on app start or restart.
  /// Re-initialize the socket if user is already logged in.
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString(_tokenKey);
    role = prefs.getString(_roleKey);

    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      userModel = UserModel.fromJson(jsonDecode(userJson));
    }

    // Re-initialize socket after app restart
    if (accessToken != null && userModel != null) {
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().reset(
          userId: userModel!.id,
          token: accessToken!,
          baseUrl: AppUrls.socketBaseUrl,
        );
      } else {
        await Get.putAsync<SocketService>(
              () => SocketService().init(
            userId: userModel!.id,
            token: accessToken!,
            baseUrl: AppUrls.socketBaseUrl,
          ),
          permanent: true,
        );
      }
    }

    // Setup chat list socket listener if controller exists
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().setSocketListener();
    }
  }

  // -------------------------
  // UPDATE PROFILE
  // -------------------------
  /// Update locally stored user profile and SharedPreferences.
  Future<void> updateUser(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    userModel = updatedUser;
    await prefs.setString(_userDataKey, jsonEncode(updatedUser.toJson()));
  }

  // -------------------------
  // LOGOUT
  // -------------------------
  /// Logout the user, clear all local data, and disconnect the socket.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear stored data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerTypeKey);

    accessToken = null;
    userModel = null;
    role = null;

    // Disconnect socket
    if (Get.isRegistered<SocketService>()) {
      Get.find<SocketService>().helper.dispose();
    }

    // Navigate to login screen
    Get.offAllNamed(Routes.login);
  }

  // -------------------------
  // HELPER
  // -------------------------
  /// Check if the user is currently logged in
  bool get isLoggedIn => accessToken != null;
}