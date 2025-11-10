import 'package:flutter/material.dart';
import 'package:harry_service_app/gen/assets.gen.dart';

class BookingDetailItem {
  final String label;
  final String value;
  final SvgGenImage ?iconPath; // optional
  final Color? labelColor;
  final Color? valueColor;

  BookingDetailItem({
    required this.label,
    required this.value,
    this.iconPath,
    this.labelColor,
    this.valueColor,
  });
}
