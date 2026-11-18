import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/notification_controller.dart';

/// Puts the unread-notification count on [child] (the bell button).
/// Loads the count once when first shown; the socket keeps it current.
class UnreadBadge extends StatefulWidget {
  const UnreadBadge({super.key, required this.child});

  final Widget child;

  @override
  State<UnreadBadge> createState() => _UnreadBadgeState();
}

class _UnreadBadgeState extends State<UnreadBadge> {
  late final NotificationController _c = NotificationController.ensure();

  @override
  void initState() {
    super.initState();
    _c.refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (c) {
        final n = c.unread;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (n > 0)
              Positioned(
                top: -2,
                right: -2,
                child: IgnorePointer(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      n > 99 ? '99+' : '$n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
