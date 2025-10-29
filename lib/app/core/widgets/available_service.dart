import 'package:flutter/cupertino.dart';
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
    return Column(
      ///service 1
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(serviceType, style: AppTextStyle.c_regular_12(color: AppColors.black_3)),
        Text(serviceCount, style: AppTextStyle.sub_h3_medium_14()),
      ],
    );
  }
}