import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class JsonHelper {

  static String getString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static int getInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double getDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static Map<String, dynamic>? getMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  static List getList(dynamic value) {
    if (value is List) return value;
    return [];
  }
}



