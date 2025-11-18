import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import '../constants/text-style.dart';

class AvailableService extends StatelessWidget {
  final String serviceType;
  final String serviceCount;

  const AvailableService({
    super.key,
    required this.serviceType,
    required this.serviceCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2), // optional: background for card look
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary_1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Title
          Text(
            serviceType,
            style: AppTextStyle.c_regular_10(color: AppColors.black_3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          /// description
          Text(
            serviceCount,
            style: AppTextStyle.sub_h3_medium_14().copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
