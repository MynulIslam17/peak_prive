import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text-style.dart';

class PaginationFooter extends StatelessWidget {
  final bool isMoreLoading;
  final bool hasMore;
  final int itemCount;
  final String endMessage;

  /// One more item, shaped like the ones in the list above (the footer sits
  /// outside the list's padding, so it brings its own).
  final Widget loadingPlaceholder;

  const PaginationFooter({
    super.key,
    required this.isMoreLoading,
    required this.hasMore,
    required this.itemCount,
    required this.endMessage,
    required this.loadingPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    if (isMoreLoading) {
      return loadingPlaceholder;
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