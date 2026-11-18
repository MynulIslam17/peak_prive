// lib/core/controllers/auth_controller.dart

import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/native_loader_dialog.dart';
import 'package:harry_service_app/app/data/models/auth_tokens.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
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
  static const String _refreshTokenKey = 'refresh-token';
  static const String _userDataKey = 'user-model';
  static const String _roleKey = 'role';
  static const String _providerTypeKey = 'providerType';

  // -------------------------
  // VARIABLES
  // -------------------------
  String? accessToken;
  String? refreshToken;
  String? role;
  UserModel? userModel;
  bool _loggingOut = false;
  OverlayEntry? _loaderEntry;

  // -------------------------
  // SAVE USER DATA + TOKEN + ROLE
  // -------------------------
  /// Save user information and token in local storage
  /// and initialize or reset [SocketService] for chat.
  Future<void> saveUserData({
    required UserModel model,
    required String token,
    String? refreshToken,
    bool storeRefreshToken = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save data in SharedPreferences
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));
    await prefs.setString(_roleKey, model.role);
    if (model.providerType != null) {
      await prefs.setString(_providerTypeKey, model.providerType!);
    }
    if (storeRefreshToken) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await prefs.setString(_refreshTokenKey, refreshToken);
        this.refreshToken = refreshToken;
      } else {
        await prefs.remove(_refreshTokenKey);
        this.refreshToken = null;
      }
    }

    // Update local variables
    accessToken = token;
    userModel = model;
    role = model.role;
    _resumeSession();

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
    refreshToken = prefs.getString(_refreshTokenKey);
    role = prefs.getString(_roleKey);

    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      // A partially written or schema-changed cache would otherwise throw here,
      // on the splash screen, before any error UI exists to report it.
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          userModel = UserModel.fromJson(decoded);
        }
      } catch (_) {
        await prefs.remove(_userDataKey);
        userModel = null;
      }
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
  /// Asks the server to drop this session, then clears the device.
  ///
  /// The native loader stays up for the whole logout request.
  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    await _showLoader();
    try {
      final refresh = refreshToken;
      final access = accessToken;
      if (Get.isRegistered<NetworkCaller>() &&
          ((refresh != null && refresh.isNotEmpty) || (access != null && access.isNotEmpty))) {
        await Get.find<NetworkCaller>().postRequest(
          url: AppUrls.logoutUrl,
          body: {'refreshToken': refresh ?? ''},
          recoverAuth: false,
        );
      }
    } catch (_) {
      // The device session still ends if the server cannot be reached.
    }

    final prefs = await SharedPreferences.getInstance();

    // Clear stored data
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerTypeKey);

    accessToken = null;
    refreshToken = null;
    userModel = null;
    role = null;

    // Disconnect socket. The instance must also be unregistered, otherwise
    // `Get.isRegistered<SocketService>()` keeps reporting true and the next
    // user is handed a disposed socket that silently never delivers messages.
    if (Get.isRegistered<SocketService>()) {
      try {
        Get.find<SocketService>().helper.dispose();
      } catch (_) {
        // Already disposed; nothing to clean up.
      }
      await Get.delete<SocketService>(force: true);
    }

    _hideLoader();
    _loggingOut = false;

    // Navigate to login screen once a navigator exists.
    if (Get.key.currentState != null && Get.currentRoute != Routes.login) {
      Get.offAllNamed(Routes.login);
    }
  }

  /// `POST /auth/refresh-token` with the stored refresh token.
  ///
  /// One in-flight refresh is shared by every request that received 401.
  /// Returns false when there is no refresh token or the server rejects it.
  Future<bool> refreshSession(NetworkCaller caller) async {
    final refresh = refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    final response = await caller.postRequest(
      url: AppUrls.refreshTokenUrl,
      body: {'refreshToken': refresh},
      recoverAuth: false,
      authorize: false,
    );
    if (!response.isSuccess) return false;

    final tokens = AuthTokens.fromBody(response.body);
    if (!tokens.hasAccess) return false;
    await saveTokens(
      accessToken: tokens.accessToken!,
      refreshToken: tokens.refreshToken,
    );
    return true;
  }

  /// Stores a new access token, and a rotated refresh token when the server sends one.
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    this.accessToken = accessToken;
    userModel?.token = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
      this.refreshToken = refreshToken;
    }
    _resumeSession();
    _syncSocket(accessToken);
  }

  void _resumeSession() {
    if (Get.isRegistered<NetworkCaller>()) {
      Get.find<NetworkCaller>().resetAuthRecovery();
    }
  }

  void _syncSocket(String token) {
    final userId = userModel?.id;
    if (userId == null || userId.isEmpty) return;
    if (!Get.isRegistered<SocketService>()) return;
    Get.find<SocketService>().reset(
      userId: userId,
      token: token,
      baseUrl: AppUrls.socketBaseUrl,
    );
  }

  Future<void> _showLoader() async {
    if (_loaderEntry != null) return;
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;
    final entry = OverlayEntry(builder: (_) => const NativeLoaderDialog());
    _loaderEntry = entry;
    overlay.insert(entry);
    // Paint it before the request returns, including when the server answers quickly.
    await SchedulerBinding.instance.endOfFrame;
  }

  void _hideLoader() {
    _loaderEntry?.remove();
    _loaderEntry = null;
  }

  // -------------------------
  // HELPER
  // -------------------------
  /// Check if the user is currently logged in
  bool get isLoggedIn => accessToken != null;
}