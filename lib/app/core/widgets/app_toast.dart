import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../utils/toast_host.dart';

/// One look for short feedback messages (replaces ad-hoc `Get.snackbar`s).
///
/// Shown at the top (clear of sticky bottom buttons), with an icon. Safe to call from anywhere
/// that has GetX navigation; a new toast replaces the one on screen.
abstract final class AppToast {
  static void success(String message, {String title = 'Done'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_rounded);

  static void error(String message, {String title = 'Something went wrong'}) =>
      _show(title, message, AppColors.error, Icons.error_rounded, clearOnNavigate: true);

  static void info(String message, {String title = 'Heads up'}) =>
      _show(title, message, const Color(0xFF3F3E3E), Icons.info_rounded);

  static void _show(String title, String message, Color color, IconData icon, {bool clearOnNavigate = false}) {
    ToastHost.present('$title|$message', () => Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: false,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 250),
    ), clearOnNavigate: clearOnNavigate);
  }
}
