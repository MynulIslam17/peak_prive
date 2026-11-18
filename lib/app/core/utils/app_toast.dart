import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import 'toast_host.dart';

enum ToastType { success, error, warning, info }

/// Modern floating toast: dark rounded card, accent icon badge, title +
/// message, optional action button. Use instead of raw `Get.snackbar`.
void showAppToast({
  required String title,
  required String message,
  ToastType type = ToastType.info,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final (Color accent, IconData defaultIcon) = switch (type) {
    ToastType.success => (const Color(0xFF34D399), Icons.check_circle_rounded),
    ToastType.error => (const Color(0xFFF87171), Icons.error_outline_rounded),
    ToastType.warning => (const Color(0xFFFBBF24), Icons.warning_amber_rounded),
    ToastType.info => (AppColors.primary_1, Icons.info_outline_rounded),
  };

  ToastHost.present('${type.name}|$title|$message', () {
    HapticFeedback.lightImpact();
    return _rawToast(title: title, message: message, accent: accent, icon: icon ?? defaultIcon, actionLabel: actionLabel, onAction: onAction);
  }, clearOnNavigate: type == ToastType.error || type == ToastType.warning);
}

SnackbarController _rawToast({
  required String title,
  required String message,
  required Color accent,
  required IconData icon,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return Get.rawSnackbar(
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF1F2328),
    borderRadius: 18,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
    duration: const Duration(seconds: 4),
    animationDuration: const Duration(milliseconds: 350),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
    icon: Container(
      margin: const EdgeInsets.only(left: 10),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accent, size: 20),
    ),
    shouldIconPulse: false,
    titleText: Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    messageText: Padding(
      padding: const EdgeInsets.only(left: 6, top: 2),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 13,
          height: 1.35,
        ),
      ),
    ),
    mainButton: actionLabel == null
        ? null
        : TextButton(
            onPressed: () {
              ToastHost.dismiss();
              onAction?.call();
            },
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
  );
}
