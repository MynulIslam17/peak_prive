import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Details-screen layout: a hero image with a draggable sheet on top of it.
///
/// - While the sheet is collapsed, a floating round back button sits on the image.
/// - As the sheet is dragged to the top, its corners flatten and a solid app bar
///   (back button + [title]) fades in above it.
/// - An optional [bottomBar] stays pinned at the bottom (e.g. price + CTA).
/// - Content is centred and width-capped on tablets via [maxContentWidth].
class CollapsibleDetailsLayout extends StatefulWidget {
  const CollapsibleDetailsLayout({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.children,
    this.bottomBar,
    this.onBack,
    this.minSheetFraction = 0.55,
    this.maxContentWidth = 640,
    this.horizontalPadding = 20,
    this.backgroundColor = Colors.white,
  });

  final String imageUrl;

  /// Shown in the app bar once the sheet is fully expanded.
  final String title;

  /// Sheet content, laid out top-to-bottom below the drag handle.
  final List<Widget> children;

  final Widget? bottomBar;
  final VoidCallback? onBack;

  /// Height of the collapsed sheet as a fraction of the available body height.
  final double minSheetFraction;
  final double maxContentWidth;
  final double horizontalPadding;
  final Color backgroundColor;

  @override
  State<CollapsibleDetailsLayout> createState() =>
      _CollapsibleDetailsLayoutState();
}

class _CollapsibleDetailsLayoutState extends State<CollapsibleDetailsLayout> {
  static const double _radius = 28;

  /// 0 = sheet collapsed, 1 = sheet fully expanded.
  final ValueNotifier<double> _progress = ValueNotifier(0);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _handleBack() => (widget.onBack ?? () => Navigator.maybePop(context))();

  bool _onSheetNotification(DraggableScrollableNotification n) {
    final range = n.maxExtent - n.minExtent;
    _progress.value =
        range <= 0 ? 0 : ((n.extent - n.minExtent) / range).clamp(0.0, 1.0);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final appBarHeight = topInset + kToolbarHeight;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: widget.bottomBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          // Fully expanded, the sheet stops right below the app bar.
          final maxSize = ((height - appBarHeight) / height).clamp(0.3, 1.0);
          final minSize = widget.minSheetFraction.clamp(0.2, maxSize);
          final imageHeight = height * (1 - minSize) + _radius;
          final sidePadding = math.max(
            widget.horizontalPadding,
            (width - widget.maxContentWidth) / 2,
          );

          return ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, t, _) {
              // App bar fades in over the last 20% of the drag.
              final barOpacity = ((t - 0.8) / 0.2).clamp(0.0, 1.0);
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: barOpacity > 0.5
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light,
                child: _buildStack(
                  t: t,
                  barOpacity: barOpacity,
                  imageHeight: imageHeight,
                  minSize: minSize,
                  maxSize: maxSize,
                  sidePadding: sidePadding,
                  topInset: topInset,
                  appBarHeight: appBarHeight,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStack({
    required double t,
    required double barOpacity,
    required double imageHeight,
    required double minSize,
    required double maxSize,
    required double sidePadding,
    required double topInset,
    required double appBarHeight,
  }) {
    final radius = _radius * (1 - barOpacity);

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: _onSheetNotification,
      child: Stack(
        children: [
          // ===== Hero image (with light parallax) =====
          Positioned(
            top: -imageHeight * 0.15 * t,
            left: 0,
            right: 0,
            height: imageHeight,
            child: _HeroImage(url: widget.imageUrl),
          ),

          // ===== Draggable sheet =====
          DraggableScrollableSheet(
            initialChildSize: minSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            snap: true,
            builder: (context, scrollController) => Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08 * (1 - barOpacity)),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  const SliverToBoxAdapter(child: _DragHandle()),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(sidePadding, 4, sidePadding, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(widget.children),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Floating back button (collapsed state) =====
          if (barOpacity < 1)
            Positioned(
              top: topInset + 8,
              left: 16,
              child: Opacity(
                opacity: 1 - barOpacity,
                child: _RoundBackButton(onTap: _handleBack),
              ),
            ),

          // ===== App bar (expanded state) =====
          if (barOpacity > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: appBarHeight,
              child: IgnorePointer(
                ignoring: barOpacity < 0.5,
                child: Opacity(
                  opacity: barOpacity,
                  child: _DetailsAppBar(
                    title: widget.title,
                    topInset: topInset,
                    sidePadding: sidePadding - 12,
                    onBack: _handleBack,
                    backgroundColor: widget.backgroundColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.shimmerBase,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 48, color: Colors.white),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        url.isEmpty
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                errorWidget: (_, __, ___) => placeholder,
              ),
        // Top scrim so the status bar and back button stay legible.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0, -0.3),
              colors: [Color(0x66000000), Color(0x00000000)],
            ),
          ),
        ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DetailsAppBar extends StatelessWidget {
  const _DetailsAppBar({
    required this.title,
    required this.topInset,
    required this.sidePadding,
    required this.onBack,
    required this.backgroundColor,
  });

  final String title;
  final double topInset;
  final double sidePadding;
  final VoidCallback onBack;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topInset, left: math.max(4, sidePadding)),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.sub_h1_medium_18(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

/// Pinned bottom bar with a price on the left and a call-to-action on the right.
class DetailsBottomBar extends StatelessWidget {
  const DetailsBottomBar({
    super.key,
    required this.price,
    required this.buttonText,
    required this.onPressed,
    this.priceLabel = 'Total price',
    this.maxContentWidth = 640,
  });

  final String price;
  final String priceLabel;
  final String buttonText;
  final VoidCallback? onPressed;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(priceLabel,
                              maxLines: 1,
                              style: AppTextStyle.p_regular_12(
                                  color: AppColors.textTertiary)),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(price,
                              maxLines: 1,
                              style: AppTextStyle.h3_semibold_20(
                                  color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary_1,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            buttonText,
                            maxLines: 1,
                            softWrap: false,
                            style: AppTextStyle.sub_h2_medium_16(
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
