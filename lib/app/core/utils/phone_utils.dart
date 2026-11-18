// lib/core/utils/phone_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_toast.dart';

/// Opens the device dialer with [phoneNumber] pre-filled.
///
/// Shows a friendly toast when the number is missing/invalid or when the
/// device can't place calls (iOS Simulator, iPad, iPod).
Future<void> makePhoneCall(String? phoneNumber) async {
  final raw = phoneNumber?.trim() ?? '';
  final lower = raw.toLowerCase();

  if (raw.isEmpty || lower == 'n/a' || lower == 'na' || lower == 'null') {
    showAppToast(
      type: ToastType.warning,
      icon: Icons.phone_disabled_rounded,
      title: 'No phone number',
      message: "This provider hasn't added a phone number yet. "
          'Try sending them a message instead.',
    );
    return;
  }

  // Strip formatting characters (spaces, dashes, dots, parentheses) so
  // numbers like "+44 7700 900-123" are accepted.
  final cleaned = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleaned)) {
    showAppToast(
      type: ToastType.error,
      title: "Can't call this number",
      message: '"$raw" doesn\'t look like a valid phone number.',
    );
    return;
  }

  final url = Uri(scheme: 'tel', path: cleaned);

  try {
    // Launch directly: canLaunchUrl() returns false on Android 11+ unless the
    // exact intent is declared in <queries>, which wrongly blocked the dialer.
    final launched =
        await launchUrl(url, mode: LaunchMode.externalApplication);
    if (launched) return;

    // No dialer available. Copy the number so the user can still call it.
    await Clipboard.setData(ClipboardData(text: cleaned));
    showAppToast(
      type: ToastType.info,
      icon: Icons.content_copy_rounded,
      title: 'Number copied',
      message: "Calling isn't available on this device. "
          '$cleaned has been copied to your clipboard.',
    );
  } catch (_) {
    showAppToast(
      type: ToastType.error,
      icon: Icons.phone_callback_rounded,
      title: "Couldn't open the dialer",
      message: 'Something went wrong. Please try again in a moment.',
      actionLabel: 'Copy',
      onAction: () => Clipboard.setData(ClipboardData(text: cleaned)),
    );
  }
}
