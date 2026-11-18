import '../../../../../notification/widgets/unread_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/text-style.dart';
import '../../../../../../core/widgets/custom_search_bar.dart';

/// Home header. At the top it is roomy (big avatar, greeting, name, service
/// switcher, bell); scrolling collapses it into a compact app bar (small
/// avatar, name, service, bell) with the search bar pinned underneath. The
/// change follows the scroll position, so it animates both ways.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.serviceLabel,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onSwitchService,
    required this.onNotifications,
    required this.horizontalPadding,
  });

  final String userName;
  final String avatarUrl;
  final String serviceLabel;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final VoidCallback onSwitchService;
  final VoidCallback onNotifications;
  final double horizontalPadding;

  /// Greeting area when expanded / collapsed, and the pinned search row.
  static const double expandedHeight = 112;
  static const double collapsedHeight = 60;
  static const double searchHeight = 70;

  /// Full header height at the top of the page (for the refresh indicator).
  static const double maxExtent = expandedHeight + searchHeight;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(this),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate(this.h);

  final HomeHeader h;

  @override
  double get maxExtent => HomeHeader.expandedHeight + HomeHeader.searchHeight;

  @override
  double get minExtent => HomeHeader.collapsedHeight + HomeHeader.searchHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0 = expanded, 1 = collapsed.
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final top = lerpDouble(HomeHeader.expandedHeight, HomeHeader.collapsedHeight, t)!;
    final avatar = lerpDouble(52, 34, t)!;
    final nameSize = lerpDouble(22, 16, t)!;
    final greetingFade = (1 - t * 1.6).clamp(0.0, 1.0);
    final firstName = h.userName.trim().split(RegExp(r'\s+')).first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06 * t),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: top,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: h.horizontalPadding),
              child: Row(
                children: [
                  _Avatar(url: h.avatarUrl, size: avatar),
                  SizedBox(width: lerpDouble(14, 10, t)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The greeting line folds away as the header collapses.
                        ClipRect(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            heightFactor: greetingFade,
                            child: Opacity(
                              opacity: greetingFade,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  _greeting(DateTime.now()),
                                  maxLines: 1,
                                  style: AppTextStyle.p_regular_12(color: AppColors.textTertiary).copyWith(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          firstName.isEmpty ? 'there' : firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary)
                              .copyWith(fontSize: nameSize, fontWeight: FontWeight.w700, height: 1.15),
                        ),
                        SizedBox(height: lerpDouble(6, 1, t)),
                        _ServiceSwitcher(label: h.serviceLabel, onTap: h.onSwitchService, compact: t > 0.6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  UnreadBadge(
                    child: _CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                      tooltip: 'Notifications',
                      onTap: h.onNotifications,
                      size: lerpDouble(46, 40, t)!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: HomeHeader.searchHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(h.horizontalPadding, 4, h.horizontalPadding, 14),
              child: CustomSearchBar(
                controller: h.searchController,
                hintText: h.searchHint,
                onChanged: h.onSearchChanged,
                onClear: h.onSearchCleared,
                filledColor: AppColors.surfaceAlt,
                borderColor: AppColors.border,
                focusColor: AppColors.primary_1,
                borderRadius: 14,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.h.userName != h.userName ||
      old.h.avatarUrl != h.avatarUrl ||
      old.h.serviceLabel != h.serviceLabel ||
      old.h.searchHint != h.searchHint ||
      old.h.horizontalPadding != h.horizontalPadding ||
      old.h.searchController != h.searchController;
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFBF3DC),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.shimmerBase,
        backgroundImage: url.isNotEmpty
            ? CachedNetworkImageProvider(url)
            : const AssetImage('assets/images/profile_img.png') as ImageProvider,
      ),
    );
  }
}

/// Shows the active service and opens the service picker.
class _ServiceSwitcher extends StatelessWidget {
  const _ServiceSwitcher({required this.label, required this.onTap, this.compact = false});

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change service, current: $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.sub_h3_semibold_14(
                    color: AppColors.primary_1,
                  ).copyWith(fontSize: compact ? 12.5 : 14),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primary_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceAlt,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
