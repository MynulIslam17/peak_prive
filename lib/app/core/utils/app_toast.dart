import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import 'toast_host.dart';

enum ToastType { success, error, warning, info }

/// Compact floating toast: dark rounded card with a hairline border, accent
/// icon badge, title + message, optional action button. Use instead of raw
/// `Get.snackbar`.
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

/// GetSnackBar reserves a fixed 42px column for its own `icon` and forces a
/// 6px gap between `titleText` and `messageText`. Passing no icon and no title
/// and laying the row out inside `messageText` keeps the card as short as its
/// content.
SnackbarController _rawToast({
  required String title,
  required String message,
  required Color accent,
  required IconData icon,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final hasMessage = message.trim().isNotEmpty;

  return Get.rawSnackbar(
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF17191C),
    borderColor: Colors.white.withValues(alpha: 0.10),
    borderWidth: 1,
    borderRadius: 14,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
    messageText: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              // A long API error must not grow the card into a panel.
              if (hasMessage)
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
    mainButton: actionLabel == null
        ? null
        : TextButton(
            onPressed: () {
              ToastHost.dismiss();
              onAction?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
  );
}
