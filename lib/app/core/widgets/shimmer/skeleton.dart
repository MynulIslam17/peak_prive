import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';
import '../../constants/text-style.dart';

/// Shared loading skeletons. Screens show these on a first load instead of a
/// spinner, shaped like the content that is coming. Every measurement here is
/// copied from the real widget it stands in for, so nothing moves when the
/// data arrives.

/// Paints its [child]'s boxes with the app's shimmer: a soft, slow sweep,
/// and the placeholder fades in (rising slightly) instead of popping in.
///
/// The shimmer gradient covers everything it paints, so cards keep their
/// white background and border *outside* this widget and only put grey boxes
/// inside it.
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

/// A grey bar exactly one line of [style] tall, measured from a hidden piece
/// of text. Use it where the placeholder's height decides the layout: the app
/// sizes its text with `ScreenUtil`, so a bar of fixed pixels would make a bar
/// or card the wrong height on a tablet (or at a large text scale).
class SkeletonTextBar extends StatelessWidget {
  const SkeletonTextBar({super.key, required this.width, required this.style, this.radius = 6});

  final double width;
  final TextStyle style;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Opacity(opacity: 0, child: Text('0', style: style)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A bordered card, like the ones the content uses.
BoxDecoration _cardBox({double radius = 16, Color color = Colors.white}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );

// ───────────────────────────── List items ─────────────────────────────

/// Matches the review tile in `ListingReviewsSection`: avatar and name, the
/// five stars with the date, then the comment.
class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardBox(radius: 14),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonBox(height: 28, circle: true),
                SizedBox(width: 8),
                SkeletonBox(width: 110, height: 14),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  const SkeletonBox(width: 14, height: 14, radius: 4),
                ],
                const Spacer(),
                const SkeletonBox(width: 76, height: 12),
              ],
            ),
            const SizedBox(height: 8),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Matches `TransactionCard`: rounded icon square, title, status, date and
/// the amount on the right.
class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardBox(radius: 14),
      child: const SkeletonShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 40, height: 40, radius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 96, height: 14),
                  SizedBox(height: 4),
                  SkeletonBox(width: 70, height: 12),
                  SizedBox(height: 4),
                  SkeletonBox(width: 140, height: 12),
                ],
              ),
            ),
            SizedBox(width: 8),
            SkeletonBox(width: 62, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of [TransactionSkeleton]s with the history list's spacing.
class TransactionListSkeleton extends StatelessWidget {
  const TransactionListSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const TransactionSkeleton(),
    );
  }
}

/// Chat bubbles, alternating sides, shaped like `MessageBubble`: received
/// ones carry an avatar, and each bubble has its time underneath.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const widths = [210.0, 150.0, 240.0, 120.0, 190.0, 160.0];
    return SkeletonShimmer(
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: widths.length,
        itemBuilder: (_, i) {
          final mine = i.isEven;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
            child: Row(
              mainAxisAlignment:
                  mine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!mine) ...[
                  const SkeletonBox(height: 40, circle: true),
                  const SizedBox(width: 6),
                ],
                Column(
                  crossAxisAlignment:
                      mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: widths[i], height: 52, radius: 16),
                    const SizedBox(height: 4),
                    const SkeletonBox(width: 34, height: 10),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────────── Whole pages ─────────────────────────────

/// Wallet while the balance loads: the gold balance card, the section header
/// and the first activity rows.
class WalletSkeleton extends StatelessWidget {
  const WalletSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardBox(radius: 20),
          child: const SkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 20, height: 20, radius: 6),
                    SizedBox(width: 8),
                    SkeletonBox(width: 120, height: 14),
                  ],
                ),
                SizedBox(height: 10),
                SkeletonBox(width: 160, height: 26),
                SizedBox(height: 6),
                SkeletonBox(width: double.infinity, height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 180, height: 12),
                SizedBox(height: 18),
                SkeletonBox(width: double.infinity, height: 48, radius: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonShimmer(
          child: Row(
            children: [
              SkeletonBox(width: 140, height: 18),
              Spacer(),
              SkeletonBox(width: 54, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < rows; i++) ...[
          const TransactionSkeleton(),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Withdraw screen while the payout methods load: balance banner, the
/// "Withdraw to" list, the amount field and the two buttons.
class WithdrawSkeleton extends StatelessWidget {
  const WithdrawSkeleton({super.key, this.methods = 2});

  final int methods;

  @override
  Widget build(BuildContext context) {
    // Same shape as `CardTile`: icon bubble, two lines, a trailing mark.
    Widget method() => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _cardBox(),
          child: const SkeletonShimmer(
            child: Row(
              children: [
                SkeletonBox(width: 44, height: 44, radius: 12),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 14),
                      SizedBox(height: 6),
                      SkeletonBox(width: 90, height: 12),
                    ],
                  ),
                ),
                SkeletonBox(height: 22, circle: true),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: _cardBox(radius: 20),
          child: const SkeletonShimmer(
            child: Row(
              children: [
                SkeletonBox(width: 56, height: 56, radius: 14),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 110, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 130, height: 26),
                    ],
                  ),
                ),
                SkeletonBox(width: 34, height: 34, radius: 10),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const SkeletonShimmer(child: SkeletonBox(width: 104, height: 14)),
                const SizedBox(height: 12),
                for (var i = 0; i < methods; i++) method(),
                const Spacer(),
                const SkeletonShimmer(
                  child: SkeletonBox(width: double.infinity, height: 56, radius: 12),
                ),
                const SizedBox(height: 16),
                const SkeletonShimmer(
                  child: Row(
                    children: [
                      Expanded(child: SkeletonBox(height: 48, radius: 14)),
                      SizedBox(width: 12),
                      Expanded(child: SkeletonBox(height: 48, radius: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Listing editor while the listing loads: the cover photo then sections of
/// labelled fields, like `EditorScaffold`'s body.
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Same as `EditorSection`: title (and subtitle) then the fields.
    Widget section(int fields) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: _cardBox(),
          child: SkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 150, height: 16),
                const SizedBox(height: 2),
                const SkeletonBox(width: 210, height: 12),
                const SizedBox(height: 14),
                for (var i = 0; i < fields; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  const SkeletonBox(width: 90, height: 12),
                  const SizedBox(height: 6),
                  const SkeletonBox(width: double.infinity, height: 48, radius: 12),
                ],
              ],
            ),
          ),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: SkeletonShimmer(
              child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 14),
            ),
          ),
        ),
        section(3),
        section(2),
      ],
    );
  }
}

/// Checkout forms while the listing loads: the summary card then labelled
/// sections, with the pay bar pinned at the bottom — like every checkout.
class CheckoutSkeleton extends StatelessWidget {
  const CheckoutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // `CheckoutSectionLabel` + a `CheckoutCard` of rows.
    Widget section(int rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 24, 4, 10),
              child: SkeletonShimmer(child: SkeletonBox(width: 130, height: 16)),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBox(),
              child: SkeletonShimmer(
                child: Column(
                  children: [
                    for (var i = 0; i < rows; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      const SkeletonBox(width: double.infinity, height: 48, radius: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // `CheckoutSummaryCard`: 76 thumbnail, title, location, price.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _cardBox(),
                    child: const SkeletonShimmer(
                      child: Row(
                        children: [
                          SkeletonBox(width: 76, height: 76, radius: 12),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(width: double.infinity, height: 16),
                                SizedBox(height: 8),
                                SkeletonBox(width: 130, height: 12),
                                SizedBox(height: 8),
                                SkeletonBox(width: 80, height: 14),
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
              ),
            ),
          ),
        ),
        const _BottomBarSkeleton(
          buttonHeight: 52,
          buttonRadius: 14,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        ),
      ],
    );
  }
}

/// The ski pass ticket while it loads: the tinted card with its photo and
/// four info rows, then the action buttons.
class TicketSkeleton extends StatelessWidget {
  const TicketSkeleton({super.key, this.actions = 1});

  /// 1 right after checkout grows to 2 ("Get Ticket" + "Go Home").
  final int actions;

  @override
  Widget build(BuildContext context) {
    // Label on top, then icon + value (like the ticket's info items).
    Widget info() => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 60, height: 12),
              SizedBox(height: 6),
              Row(children: [
                SkeletonBox(width: 18, height: 18, radius: 5),
                SizedBox(width: 8),
                SkeletonBox(width: 130, height: 14),
              ]),
            ],
          ),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.primary_3.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary_3.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Stack(
                children: [
                  SkeletonShimmer(
                    child: SkeletonBox(width: double.infinity, height: 180, radius: 0),
                  ),
                  // The ticket number badge, drawn opaque like the real one.
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _TicketBadge(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SkeletonShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(width: 200, height: 24),
                      for (var i = 0; i < 4; i++) info(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SkeletonShimmer(
          child: Row(
            children: [
              for (var i = 0; i < actions; i++) ...[
                if (i > 0) const SizedBox(width: 15),
                const Expanded(child: SkeletonBox(height: 48, radius: 10)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketBadge extends StatelessWidget {
  const _TicketBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.secendary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ───────────────────────── Details pages (photo + sheet) ─────────────────────

/// What a section of a [DetailsPageSkeleton] looks like. Each value matches a
/// real section of a details sheet, down to its card padding and radius.
enum SkeletonSection {
  /// Two-column tiles with an icon and two lines ("What's included").
  tiles,

  /// A paragraph ("About", "Benefits").
  lines,

  /// Bordered rows with a photo, a price and an action
  /// ("Choose equipment", "Choose your seating").
  list,

  /// Rows with a small icon, a label and a price ("Durations").
  durations,

  /// Three equal stat tiles side by side (transport "Vehicle").
  specs,

  /// Pills that wrap onto several lines (restaurant "Time slots").
  chips,

  /// A bordered card of icon · label · value rows
  /// (booking "When" and "Payment", transport "Price").
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
    this.reviews,
  });

  final List<SkeletonSection> sections;

  /// Booking page: a status pill above the title and a guest/provider card
  /// under its own heading. Its bottom bar keeps the total at its natural
  /// width (`BookingTotalBar`) instead of letting it take the free space.
  final bool booking;
  final bool bottomBar;

  /// Reviews at the end of the sheet. Listing pages always have them;
  /// bookings never do.
  final bool? reviews;

  // Same values as CollapsibleDetailsLayout.
  static const _sheet = 0.55;
  static const _radius = 28.0;
  static const _maxContentWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final showReviews = reviews ?? !booking;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomBar ? _BottomBarSkeleton(expandLabel: !booking) : null,
      body: LayoutBuilder(
        builder: (context, c) {
          final imageHeight = c.maxHeight * (1 - _sheet) + _radius;
          final side = math.max(20.0, (c.maxWidth - _maxContentWidth) / 2);

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: const _HeroSkeleton(),
              ),

              // The sheet, collapsed: white, rounded on top, shadowed.
              Positioned.fill(
                top: c.maxHeight * (1 - _sheet),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const _DragHandleSkeleton(),
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(side, 4, side, 32),
                          children: [
                            booking ? const _BookingHead() : const _ListingHead(),
                            for (final s in sections) _Section(s, booking: booking),
                            if (showReviews) ...[
                              _SectionTitle(booking: booking, width: 110),
                              const ReviewSkeleton(),
                              const SizedBox(height: 10),
                              const ReviewSkeleton(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // A real back button: the page can be left while it loads.
              Positioned(
                top: topInset + 8,
                left: 16,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.maybePop(context),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
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

/// The hero photo, with the same top scrim as `_HeroImage` so the status bar
/// and the back button stay legible.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        SkeletonShimmer(
          child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 0),
        ),
        DecoratedBox(
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

/// The sheet's grab handle (not shimmered: it is the same grey when loaded).
class _DragHandleSkeleton extends StatelessWidget {
  const _DragHandleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

/// `ListingSectionTitle` (top 28 / bottom 12) or `BookingSectionTitle`
/// (top 24 / bottom 10).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.booking, this.width = 130});

  final bool booking;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: booking ? 24 : 28, bottom: booking ? 10 : 12),
      child: SkeletonShimmer(child: SkeletonBox(width: width, height: 18)),
    );
  }
}

/// `ListingHeader` (title + rating pill + chips) then `ListingProviderCard`.
class _ListingHead extends StatelessWidget {
  const _ListingHead();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 230, height: 22),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SkeletonBox(width: 94, height: 30, radius: 20),
                  SkeletonBox(width: 86, height: 30, radius: 20),
                  SkeletonBox(width: 118, height: 30, radius: 20),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _PersonCard(),
      ],
    );
  }
}

/// `BookingDetailsHeader` (status chip, title, subtitle) then the guest or
/// provider card under its own section title.
class _BookingHead extends StatelessWidget {
  const _BookingHead();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 128, height: 26, radius: 20),
              SizedBox(height: 10),
              SkeletonBox(width: 210, height: 20),
              SizedBox(height: 4),
              SkeletonBox(width: 150, height: 14),
            ],
          ),
        ),
        _SectionTitle(booking: true, width: 96),
        _PersonCard(),
      ],
    );
  }
}

/// "Hosted by" / "Booked by" card: avatar, two lines, round action buttons.
class _PersonCard extends StatelessWidget {
  const _PersonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardBox(color: AppColors.surfaceAlt),
      child: const SkeletonShimmer(
        child: Row(
          children: [
            SkeletonBox(height: 48, circle: true),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 70, height: 12),
                  SizedBox(height: 4),
                  SkeletonBox(width: 130, height: 16),
                ],
              ),
            ),
            SkeletonBox(height: 42, circle: true),
            SizedBox(width: 8),
            SkeletonBox(height: 42, circle: true),
          ],
        ),
      ),
    );
  }
}

/// One titled section of a details sheet.
class _Section extends StatelessWidget {
  const _Section(this.kind, {required this.booking});

  final SkeletonSection kind;
  final bool booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(booking: booking, width: kind == SkeletonSection.lines ? 96 : 150),
        switch (kind) {
          SkeletonSection.tiles => const _IncludedTiles(),
          SkeletonSection.lines => const _Paragraph(),
          SkeletonSection.list => const _ItemCards(),
          SkeletonSection.durations => const _DurationRows(),
          SkeletonSection.specs => const _SpecTiles(),
          SkeletonSection.chips => const _ChipRows(),
          SkeletonSection.infoCard => const _InfoCard(),
        },
      ],
    );
  }
}

/// `ListingExpandableText`: 14 pt lines at 1.55 line height.
class _Paragraph extends StatelessWidget {
  const _Paragraph();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 10),
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 10),
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 10),
          SkeletonBox(width: 180, height: 12),
        ],
      ),
    );
  }
}

/// The ski pass "What's included" grid: same columns and tile shape.
class _IncludedTiles extends StatelessWidget {
  const _IncludedTiles();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final w = constraints.maxWidth;
        final columns = w < 340 ? 1 : (w < 520 ? 2 : 3);
        final tileWidth = (w - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < columns * 2; i++)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _cardBox(radius: 14),
                  child: const SkeletonShimmer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 34, height: 34, radius: 10),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: 50, height: 12),
                              SizedBox(height: 4),
                              SkeletonBox(width: double.infinity, height: 14),
                            ],
                          ),
                        ),
                      ],
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

/// Hire equipment / restaurant seat cards: 64 photo, three lines, an action.
class _ItemCards extends StatelessWidget {
  const _ItemCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: _cardBox(),
            child: const SkeletonShimmer(
              child: Row(
                children: [
                  SkeletonBox(width: 64, height: 64, radius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 150, height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(width: 90, height: 14),
                        SizedBox(height: 4),
                        SkeletonBox(width: 70, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  SkeletonBox(width: 78, height: 38, radius: 12),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Massage duration rows: icon square, label, price.
class _DurationRows extends StatelessWidget {
  const _DurationRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _cardBox(radius: 14),
            child: const SkeletonShimmer(
              child: Row(
                children: [
                  SkeletonBox(width: 34, height: 34, radius: 10),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(width: 140, height: 14)),
                  SkeletonBox(width: 56, height: 14),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Transport "Vehicle": three tiles with an icon, a value and a label.
class _SpecTiles extends StatelessWidget {
  const _SpecTiles();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: _cardBox(radius: 14, color: AppColors.surfaceAlt),
              child: const SkeletonShimmer(
                child: Column(
                  children: [
                    SkeletonBox(width: 20, height: 20, radius: 6),
                    SizedBox(height: 6),
                    SkeletonBox(width: 42, height: 14),
                    SizedBox(height: 4),
                    SkeletonBox(width: 54, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Restaurant "Time slots": wrapped `ListingInfoChip`s.
class _ChipRows extends StatelessWidget {
  const _ChipRows();

  @override
  Widget build(BuildContext context) {
    const widths = [104.0, 88.0, 120.0, 96.0, 110.0];
    return SkeletonShimmer(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final w in widths) SkeletonBox(width: w, height: 30, radius: 20),
        ],
      ),
    );
  }
}

/// `BookingInfoCard`: icon · label · value rows split by thin dividers.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardBox(color: AppColors.scaffold),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0)
              const Divider(height: 1, indent: 52, endIndent: 16, color: AppColors.border),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: SkeletonShimmer(
                child: Row(
                  children: [
                    SkeletonBox(width: 28, height: 28, radius: 8),
                    SizedBox(width: 10),
                    SkeletonBox(width: 70, height: 12),
                    Spacer(),
                    SkeletonBox(width: 110, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Matches the pinned bars (`DetailsBottomBar`, `BookingTotalBar`,
/// `CheckoutBar`): a price on the left, the main button on the right.
class _BottomBarSkeleton extends StatelessWidget {
  const _BottomBarSkeleton({
    this.expandLabel = true,
    this.buttonHeight = 50,
    this.buttonRadius = 12,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 12),
  });

  /// The price column takes the free space (listing and checkout bars);
  /// `BookingTotalBar` keeps it at its natural width.
  final bool expandLabel;
  final double buttonHeight;
  final double buttonRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // The real bars size this column from the text styles below, and it is
    // what decides their height on a tablet.
    final price = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonTextBar(width: 80, style: AppTextStyle.p_regular_12()),
        const SizedBox(height: 2),
        SkeletonTextBar(width: 90, style: AppTextStyle.h3_semibold_20()),
      ],
    );

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
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: padding,
              child: SkeletonShimmer(
                child: Row(
                  children: [
                    if (expandLabel) Expanded(child: price) else price,
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(height: buttonHeight, radius: buttonRadius),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
