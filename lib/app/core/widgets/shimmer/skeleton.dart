import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';

/// Shared loading skeletons. Screens show these on a first load instead of a
/// spinner, shaped like the content that is coming. Every skeleton list is
/// scrollable so pull-to-refresh keeps working while it shows.

/// Paints its [child]'s boxes with the app's shimmer: a soft, slow sweep,
/// and the placeholder fades in (rising slightly) instead of popping in.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: child),
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          period: const Duration(milliseconds: 1600),
          child: child,
        ),
      );
}

/// A grey block (inside a [SkeletonShimmer]).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 12, this.radius = 6, this.circle = false});

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
        width: circle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// Card with a thumbnail and three text lines (bookings, transactions…).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.thumbnail = true, this.footer = true});

  final bool thumbnail;
  final bool footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SkeletonShimmer(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbnail) ...[const SkeletonBox(width: 64, height: 64, radius: 12), const SizedBox(width: 12)],
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: double.infinity, height: 14),
                      SizedBox(height: 10),
                      SkeletonBox(width: 150, height: 10),
                      SizedBox(height: 8),
                      SkeletonBox(width: 100, height: 10),
                    ],
                  ),
                ),
              ],
            ),
            if (footer) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  SkeletonBox(width: 80, height: 16),
                  Spacer(),
                  SkeletonBox(width: 96, height: 30, radius: 10),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Row with a round avatar and two lines (chats, notifications).
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const SkeletonShimmer(
        child: Row(
          children: [
            SkeletonBox(height: 44, circle: true),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 13),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 10),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(width: 36, height: 10),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of skeleton items.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.tiles = false, this.padding = const EdgeInsets.all(16), this.shrinkWrap = false});

  final int count;

  /// Avatar rows instead of cards.
  final bool tiles;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => tiles ? const SkeletonTile() : const SkeletonCard(),
    );
  }
}

/// One skeleton item at the end of a list while the next page loads.
class SkeletonLoadMore extends StatelessWidget {
  const SkeletonLoadMore({super.key, this.tiles = false});

  final bool tiles;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: tiles ? const SkeletonTile() : const SkeletonCard(footer: false),
      );
}

/// Chat bubbles, alternating sides.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const widths = [210.0, 150.0, 240.0, 120.0, 190.0, 160.0];
    return SkeletonShimmer(
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: widths.length,
        itemBuilder: (_, i) {
          final mine = i.isEven;
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SkeletonBox(width: widths[i], height: 42, radius: 16),
            ),
          );
        },
      ),
    );
  }
}

/// Balance card plus activity rows (wallet, withdraw).
class WalletSkeleton extends StatelessWidget {
  const WalletSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonShimmer(child: SkeletonBox(width: double.infinity, height: 150, radius: 20)),
        const SizedBox(height: 20),
        const SkeletonShimmer(child: SkeletonBox(width: 140, height: 16)),
        const SizedBox(height: 12),
        for (var i = 0; i < rows; i++) ...[const SkeletonTile(), const SizedBox(height: 12)],
      ],
    );
  }
}

/// Sections of form fields (listing editor while the listing loads).
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget section(int fields) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: SkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 120, height: 16),
                for (var i = 0; i < fields; i++) ...[
                  const SizedBox(height: 16),
                  const SkeletonBox(width: 90, height: 10),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: double.infinity, height: 44, radius: 12),
                ],
              ],
            ),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonShimmer(child: SkeletonBox(width: double.infinity, height: 170, radius: 16)),
        const SizedBox(height: 16),
        section(3),
        section(2),
      ],
    );
  }
}

/// A white card used by the page skeletons below.
BoxDecoration _skeletonCard([double radius = 16]) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );

/// Checkout forms while the listing loads: a summary card (thumbnail and
/// title) then field sections, like the checkout screens.
class CheckoutSkeleton extends StatelessWidget {
  const CheckoutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget section(int fields) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _skeletonCard(),
          child: SkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 120, height: 15),
                for (var i = 0; i < fields; i++) ...[
                  const SizedBox(height: 14),
                  const SkeletonBox(width: double.infinity, height: 48, radius: 12),
                ],
              ],
            ),
          ),
        );
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: _skeletonCard(),
          child: const SkeletonShimmer(
            child: Row(
              children: [
                SkeletonBox(width: 64, height: 64, radius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: double.infinity, height: 14),
                      SizedBox(height: 10),
                      SkeletonBox(width: 120, height: 11),
                      SizedBox(height: 8),
                      SkeletonBox(width: 80, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        section(2),
        section(1),
        section(2),
      ],
    );
  }
}

/// The ski pass ticket while it loads: card with a photo and four info rows,
/// then the button.
class TicketSkeleton extends StatelessWidget {
  const TicketSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Label on top, then icon + value (like the ticket's info items).
    Widget info() => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 60, height: 10),
              SizedBox(height: 8),
              Row(children: [
                SkeletonBox(width: 18, height: 18, radius: 5),
                SizedBox(width: 8),
                SkeletonBox(width: 130, height: 13),
              ]),
            ],
          ),
        );
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        Container(
          decoration: _skeletonCard(),
          child: SkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: double.infinity, height: 180, radius: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(width: 200, height: 22),
                      for (var i = 0; i < 4; i++) info(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        const SkeletonShimmer(child: SkeletonBox(width: double.infinity, height: 48, radius: 12)),
      ],
    );
  }
}

/// What a section of a [DetailsPageSkeleton] looks like.
enum SkeletonSection {
  /// Two tiles side by side ("What's included", seats).
  tiles,

  /// A paragraph ("About").
  lines,

  /// Rows with a small thumbnail and a price (hire items, menus, options).
  list,

  /// A bordered card of label/value rows (booking "When", "Payment").
  infoCard,
}

/// Loading state of the photo + sheet pages ([CollapsibleDetailsLayout]):
/// listing details and booking details. Same geometry as the real page, so
/// nothing jumps when the content arrives.
class DetailsPageSkeleton extends StatelessWidget {
  const DetailsPageSkeleton({
    super.key,
    this.sections = const [SkeletonSection.tiles, SkeletonSection.lines],
    this.booking = false,
    this.bottomBar = true,
  });

  final List<SkeletonSection> sections;

  /// Booking page: status pill above the title, a person card, and a bottom
  /// bar with the total only (no button).
  final bool booking;
  final bool bottomBar;

  // Same values as CollapsibleDetailsLayout.
  static const _sheet = 0.55;
  static const _radius = 28.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomBar ? _BottomBarSkeleton(button: !booking) : null,
      body: LayoutBuilder(
        builder: (context, c) {
          final imageHeight = c.maxHeight * (1 - _sheet) + _radius;
          final side = c.maxWidth > 680 ? (c.maxWidth - 640) / 2 : 20.0;
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: const SkeletonShimmer(child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 0)),
              ),
              Positioned(
                top: topInset + 8,
                left: 16,
                // A real back button: the page can be left while it loads.
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.maybePop(context),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: c.maxHeight * (1 - _sheet),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
                  ),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(side, 10, side, 32),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SkeletonShimmer(child: booking ? const _BookingHead() : const _ListingHead()),
                      for (final s in sections) ...[
                        const SizedBox(height: 24),
                        SkeletonShimmer(child: _Section(s)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ListingHead extends StatelessWidget {
  const _ListingHead();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 230, height: 22),
        SizedBox(height: 12),
        Row(
          children: [
            SkeletonBox(width: 64, height: 28, radius: 14),
            SizedBox(width: 8),
            SkeletonBox(width: 86, height: 28, radius: 14),
            SizedBox(width: 8),
            SkeletonBox(width: 96, height: 28, radius: 14),
          ],
        ),
        SizedBox(height: 20),
        _PersonCard(),
      ],
    );
  }
}

class _BookingHead extends StatelessWidget {
  const _BookingHead();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 96, height: 26, radius: 13),
        SizedBox(height: 12),
        SkeletonBox(width: 220, height: 22),
        SizedBox(height: 8),
        SkeletonBox(width: 140, height: 12),
        SizedBox(height: 22),
        SkeletonBox(width: 110, height: 16),
        SizedBox(height: 12),
        _PersonCard(),
      ],
    );
  }
}

/// "Hosted by" / "Booked by" card: avatar, two lines, round buttons.
class _PersonCard extends StatelessWidget {
  const _PersonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: const Row(
        children: [
          SkeletonBox(height: 48, circle: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 70, height: 10),
                SizedBox(height: 8),
                SkeletonBox(width: 130, height: 14),
              ],
            ),
          ),
          SkeletonBox(height: 40, circle: true),
          SizedBox(width: 8),
          SkeletonBox(height: 40, circle: true),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.kind);

  final SkeletonSection kind;

  @override
  Widget build(BuildContext context) {
    final body = switch (kind) {
      SkeletonSection.tiles => const Row(
          children: [
            Expanded(child: SkeletonBox(height: 92, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 92, radius: 16)),
          ],
        ),
      SkeletonSection.lines => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 11),
            SizedBox(height: 9),
            SkeletonBox(width: double.infinity, height: 11),
            SizedBox(height: 9),
            SkeletonBox(width: double.infinity, height: 11),
            SizedBox(height: 9),
            SkeletonBox(width: 180, height: 11),
          ],
        ),
      SkeletonSection.list => Column(
          children: [
            for (var i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SkeletonBox(width: 56, height: 56, radius: 12),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: 13),
                          SizedBox(height: 8),
                          SkeletonBox(width: 90, height: 10),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 48, height: 14),
                  ],
                ),
              ),
          ],
        ),
      SkeletonSection.infoCard => Column(
          children: [
            for (var i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    SkeletonBox(height: 18, circle: true),
                    SizedBox(width: 12),
                    SkeletonBox(width: 70, height: 11),
                    Spacer(),
                    SkeletonBox(width: 110, height: 13),
                  ],
                ),
              ),
          ],
        ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SkeletonBox(width: 130, height: 17), const SizedBox(height: 14), body],
    );
  }
}

/// Matches DetailsBottomBar: price label and price, then the main button.
class _BottomBarSkeleton extends StatelessWidget {
  const _BottomBarSkeleton({required this.button});

  final bool button;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SkeletonShimmer(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 80, height: 10),
                      SizedBox(height: 8),
                      SkeletonBox(width: 70, height: 20),
                    ],
                  ),
                ),
                if (button) ...[
                  const SizedBox(width: 20),
                  const Expanded(flex: 2, child: SkeletonBox(height: 50, radius: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
