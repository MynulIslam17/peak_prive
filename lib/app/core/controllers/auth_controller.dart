import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';

class AuthController  extends GetxController{
  // -------------------------
  // KEYS
  // -------------------------
  static const String _tokenKey = 'access-token';
  static const String _userDataKey = 'user-model';
  static const String _roleKey = 'role';

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));
    await prefs.setString(_roleKey, model.role);

    accessToken = token;
    userModel = model;
    role = model.role;
  }

  // -------------------------
  // LOAD USER DATA
  // -------------------------
  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString(_tokenKey);
    role = prefs.getString(_roleKey);

    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      userModel = UserModel.fromJson(jsonDecode(userJson));
    }
  }

  // -------------------------
  // CHECK LOGIN
  // -------------------------
  Future<bool> isUserAlreadyLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // -------------------------
  // CLEAR ALL SAVED DATA
  // -------------------------
  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    accessToken = null;
    userModel = null;
    role = null;
  }

  // -------------------------
  // OPTIONAL: SAVE ROLE ONLY
  // -------------------------
  Future<void> saveRole(String newRole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, newRole);
    role = newRole;
  }

  // -------------------------
  // GETTERS
  // -------------------------
  bool get isLoggedIn => accessToken != null;
}
