import 'dart:convert';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/data/services/socket/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../modules/chats/controllers/chat_list_controller.dart';
import '../../routes/app_routes.dart';
import '../constants/api_urls.dart';

class AuthController extends GetxController {
  // -------------------------
  // KEYS
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
  // SAVE USER + TOKEN + ROLE
  // -------------------------
  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));
    await prefs.setString(_roleKey, model.role);

    if (model.providerType != null) {
      await prefs.setString(_providerTypeKey, model.providerType!);
    }

    accessToken = token;
    userModel = model;
    role = model.role;


    // Socket initialize
    await Get.putAsync<SocketService>(
          () => SocketService().init(
        userId: model.id,
        token: token,
        baseUrl: AppUrls.socketBaseUrl,
      ),
      permanent: true,
    );

    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().setSocketListener();
    }

  }

  // -------------------------
  // LOAD USER DATA
  // -------------------------
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString(_tokenKey);
    role = prefs.getString(_roleKey);

    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      userModel = UserModel.fromJson(jsonDecode(userJson));
    }

   //when  App restart
    if (accessToken != null && userModel != null) {
      await Get.putAsync<SocketService>(
            () => SocketService().init(
          userId: userModel!.id,
          token: accessToken!,
          baseUrl: AppUrls.socketBaseUrl,
        ),
        permanent: true,
      );
    }

    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().setSocketListener();
    }





  }

  // -------------------------
  // UPDATE PROFILE
  // -------------------------
  Future<void> updateUser(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    userModel = updatedUser;
    await prefs.setString(_userDataKey, jsonEncode(updatedUser.toJson()));
  }

  // -------------------------
  // LOGOUT
  // -------------------------
  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerTypeKey);



    accessToken = null;
    userModel = null;
    role = null;

    // Socket disconnect kore cleanup
    await Get.delete<SocketService>();

    Get.offAllNamed(Routes.login);
  }

  // -------------------------
  bool get isLoggedIn => accessToken != null;
}