import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text-style.dart';
import 'shimmer/skeleton.dart';

class PaginationFooter extends StatelessWidget {
  final bool isMoreLoading;
  final bool hasMore;
  final int itemCount;
  final String endMessage;

  const PaginationFooter({
    super.key,
    required this.isMoreLoading,
    required this.hasMore,
    required this.itemCount,
    required this.endMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isMoreLoading) {
      return const SkeletonLoadMore();
    }

    if (!hasMore && itemCount > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            endMessage,
            style: AppTextStyle.p_medium_12()?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}