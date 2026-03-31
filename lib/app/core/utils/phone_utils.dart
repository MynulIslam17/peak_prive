// lib/core/utils/phone_utils.dart
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String? phoneNumber) async {
  // Normalize input
  final number = phoneNumber?.trim().toLowerCase();

  // ❌ Invalid cases
  if (number == null ||
      number.isEmpty ||
      number == 'n/a' ||
      number == 'na' ||
      number == 'null') {
    Get.snackbar(
      'Error',
      'Invalid phone number',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
    );
    return;
  }

  // ✅ Validate using regex (only digits + optional +)
  final isValid = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(number);

  if (!isValid) {
    Get.snackbar(
      'Error',
      'Phone number is not valid',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
    );
    return;
  }

  final Uri url = Uri(scheme: 'tel', path: number);

  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch $number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Something went wrong: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
    );
  }
}