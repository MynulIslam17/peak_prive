import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Screen layout with a header that is roomy at the top and shrinks into a
/// compact app bar as the content scrolls (and grows back when scrolling up).
///
/// The header is drawn over the content, so the content scrolls under it at
/// normal speed. [body] receives the insets it must add to its scroll padding:
/// `top` for the header (and status bar), `bottom` for the floating nav bar.
/// Any vertical scrollable inside [body] drives the header, including lists
/// inside a TabBarView.
class CollapsingHeaderLayout extends StatefulWidget {
  const CollapsingHeaderLayout({
    super.key,
    required this.header,
    required this.body,
    this.expandedHeight = 104,
    this.collapsedHeight = 60,
    this.bottom,
    this.bottomHeight = 0,
    this.background = AppColors.scaffold,
  });

  /// Builds the header for a collapse progress `t` (0 expanded, 1 collapsed).
  final Widget Function(BuildContext context, double t) header;

  /// Builds the content with the insets to keep clear.
  final Widget Function(BuildContext context, EdgeInsets insets) body;

  final double expandedHeight;
  final double collapsedHeight;

  /// Pinned under the header (tabs, filters, search).
  final Widget? bottom;
  final double bottomHeight;
  final Color background;

  /// `edgeOffset` for a RefreshIndicator in [body]: the spinner comes down
  /// from the top of the screen (over the header), not from the middle of
  /// the content.
  static double refreshEdge(BuildContext context) {
    final view = View.of(context);
    return view.padding.top / view.devicePixelRatio;
  }

  @override
  State<CollapsingHeaderLayout> createState() => _CollapsingHeaderLayoutState();
}

class _CollapsingHeaderLayoutState extends State<CollapsingHeaderLayout> {
  final _t = ValueNotifier<double>(0);

  double get _range => widget.expandedHeight - widget.collapsedHeight;

  bool _onScroll(ScrollNotification n) {
    final m = n.metrics;
    if (m.axis != Axis.vertical || _range <= 0) return false;
    _t.value = (m.pixels / _range).clamp(0.0, 1.0);
    return false;
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final top = mq.padding.top;
    final insets = EdgeInsets.only(
      top: top + widget.expandedHeight + widget.bottomHeight,
      bottom: mq.padding.bottom,
    );

    return ColoredBox(
      color: widget.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: widget.body(context, insets),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _t,
              builder: (context, t, _) {
                final h = lerpDouble(widget.expandedHeight, widget.collapsedHeight, t)!;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07 * t),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: top),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: h, child: widget.header(context, t)),
                        if (widget.bottom != null) SizedBox(height: widget.bottomHeight, child: widget.bottom),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Large page title ("My Bookings") that shrinks into an app-bar title.
class LargeTitleHeader extends StatelessWidget {
  const LargeTitleHeader({
    super.key,
    required this.title,
    required this.t,
    this.count,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final double t;
  final int? count;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final size = lerpDouble(26, 18, t)!;
    final subFade = (1 - t * 1.8).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(onBack == null ? 16 : 4, 0, 12, 0),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
            ),
          Expanded(
            child: Align(
              // Sits low while roomy (like a large title), centred when compact.
              alignment: Alignment.lerp(const Alignment(-1, 0.45), Alignment.centerLeft, t)!,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary)
                              .copyWith(fontSize: size, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.2),
                        ),
                      ),
                      if (count != null) ...[
                        const SizedBox(width: 8),
                        HeaderCountChip(count: count!),
                      ],
                    ],
                  ),
                  if (subtitle != null && subFade > 0)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topLeft,
                        heightFactor: subFade,
                        child: Opacity(
                          opacity: subFade,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary).copyWith(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Small gold count next to a header title.
class HeaderCountChip extends StatelessWidget {
  const HeaderCountChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFFBF3DC), borderRadius: BorderRadius.circular(20)),
      child: Text('$count', style: AppTextStyle.p_medium_12(color: const Color(0xFF9A7A12))),
    );
  }
}
