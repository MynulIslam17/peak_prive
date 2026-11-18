import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Full-screen block with the platform activity indicator.
///
/// iOS uses the Cupertino spinner. Android uses the Material one inside a
/// dialog card. It is inserted on the root overlay, not as a route, so a
/// later navigation cannot dismiss it before it is painted.
class NativeLoaderDialog extends StatelessWidget {
  const NativeLoaderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ios = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x8A000000)),
        Center(
          child: ios
              ? const CupertinoActivityIndicator(radius: 18, color: Colors.white)
              : const Card(
                  elevation: 6,
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(color: AppColors.primary_1),
                  ),
                ),
        ),
      ],
    );
  }
}
