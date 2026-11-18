import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/api/peak_api.dart';
import '../../routes/app_routes.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../utils/phone_utils.dart';
import 'shimmer/skeleton.dart';

/// Building blocks shared by the listing details screens (ski pass, ski hire,
/// …), used inside [CollapsibleDetailsLayout].

/// "full_day" / "fullDay" → "Full day".
String humanizeLabel(String raw) {
  final spaced = raw
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m[1]}')
      .trim()
      .toLowerCase();
  return spaced.isEmpty ? raw : spaced[0].toUpperCase() + spaced.substring(1);
}

class ListingRatingPill extends StatelessWidget {
  const ListingRatingPill({
    super.key,
    required this.rating,
    required this.count,
  });

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary_1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.primary_1),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1),
              style: AppTextStyle.sub_h3_semibold_14()),
          const SizedBox(width: 4),
          Text('($count)',
              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class ListingInfoChip extends StatelessWidget {
  const ListingInfoChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.p_medium_12(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title + rating/chips row at the top of a details sheet.
class ListingHeader extends StatelessWidget {
  const ListingHeader({
    super.key,
    required this.title,
    required this.rating,
    required this.reviewCount,
    this.chips = const [],
  });

  final String title;
  final double rating;
  final int reviewCount;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.h2_semibold_22()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ListingRatingPill(rating: rating, count: reviewCount),
            ...chips,
          ],
        ),
      ],
    );
  }
}

/// "Hosted by" card with message and call actions.
class ListingProviderCard extends StatelessWidget {
  const ListingProviderCard({
    super.key,
    required this.id,
    required this.name,
    required this.photoUrl,
    this.phoneNumber = '',
    this.label = 'Hosted by',
    this.fallbackName = 'Provider',
  });

  final String id;
  final String name;
  final String photoUrl;
  /// Empty hides the call button (listing responses carry no phone).
  final String phoneNumber;

  /// Small caption above the name.
  final String label;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.shimmerBase,
            backgroundImage: photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl)
                : const AssetImage('assets/images/profile_img.png')
                    as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.p_regular_12(
                        color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? fallbackName : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.sub_h2_medium_16(),
                ),
              ],
            ),
          ),
          if (id.isNotEmpty) ...[
            ListingCircleAction(
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: 'Message',
              onTap: () => Get.toNamed(
                Routes.messagingScreen,
                arguments: {
                  'otherUserId': id,
                  'chatId': '',
                  'otherUserName': name,
                  'otherUserProfileUrl': photoUrl,
                  'isOnline': false,
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (phoneNumber.trim().isNotEmpty)
            ListingCircleAction(
              icon: Icons.call_outlined,
              tooltip: 'Call',
              filled: true,
              onTap: () => makePhoneCall(phoneNumber),
            ),
        ],
      ),
    );
  }
}

class ListingCircleAction extends StatelessWidget {
  const ListingCircleAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? AppColors.primary_1 : Colors.white,
        shape: CircleBorder(
          side: filled
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon,
                size: 20,
                color: filled ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class ListingSectionTitle extends StatelessWidget {
  const ListingSectionTitle(this.text, {super.key, this.trailing, this.action});

  final String text;
  final String? trailing;

  /// Optional widget on the right (e.g. a "Clear" button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Text(text, style: AppTextStyle.sub_h1_medium_18()),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Text(trailing!,
                style: AppTextStyle.sub_h3_regular_14(
                    color: AppColors.textTertiary)),
          ],
          if (action != null) ...[const Spacer(), action!],
        ],
      ),
    );
  }
}

class ListingExpandableText extends StatefulWidget {
  const ListingExpandableText(this.text, {super.key});

  final String text;

  @override
  State<ListingExpandableText> createState() => _ListingExpandableTextState();
}

class _ListingExpandableTextState extends State<ListingExpandableText> {
  static const _collapsedLines = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.sub_h3_regular_14(color: AppColors.textSecondary)
        .copyWith(height: 1.55);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : _collapsedLines,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  foregroundColor: AppColors.primary_1,
                ),
                child: Text(_expanded ? 'Show less' : 'Read more',
                    style: AppTextStyle.sub_h3_semibold_14(
                        color: AppColors.primary_1)),
              ),
          ],
        );
      },
    );
  }
}

/// Minimal review shape so every service's review model can be shown.
class ListingReview {
  const ListingReview({
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.authorName,
    this.authorPhoto,
  });

  /// From the API review (`GET /<service>/:id/reviews`).
  factory ListingReview.fromApi(Review r) => ListingReview(
        rating: r.rating.toDouble(),
        comment: r.comment,
        createdAt: r.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        authorName: r.user?.name,
        authorPhoto: r.user?.photo,
      );

  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? authorName;
  final String? authorPhoto;
}

/// Bordered info row (late fee rules, opening hours…). [tone] tints it.
class ListingNote extends StatelessWidget {
  const ListingNote({super.key, required this.icon, required this.text, this.tone});

  final IconData icon;
  final String text;

  /// Null = neutral grey.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = tone;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c == null ? AppColors.surfaceAlt : c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c == null ? AppColors.border : c.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c ?? AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyle.p_regular_12(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// Shown at the top of an inactive listing (`isActive: false`).
class ListingUnavailableNotice extends StatelessWidget {
  const ListingUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: ListingNote(
          icon: Icons.block_rounded,
          tone: Color(0xFFB45309),
          text: "This listing isn't taking bookings right now.",
        ),
      );
}

/// Late-fee rule for rentals (server: 15 min free, then per started hour,
/// capped at the booking price).
String lateFeeRuleText(String perHourLabel) =>
    'Late returns: $perHourLabel per started hour after 15 min, capped at the booking price.';

/// Section with the reviews from the reviews endpoint (loading / error /
/// empty handled).
class ListingReviewsSection extends StatelessWidget {
  const ListingReviewsSection({
    super.key,
    required this.reviews,
    required this.count,
    this.isLoading = false,
    this.error,
    this.showSeeAll = false,
    this.onSeeAll,
  });

  /// How many reviews stay on the listing before "See all".
  static const int previewLimit = 3;

  final List<Review> reviews;
  final int count;
  final bool isLoading;
  final String? error;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final canOpenAll = showSeeAll && onSeeAll != null && !(isLoading && reviews.isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListingSectionTitle('Reviews', trailing: count > 0 ? '$count' : null),
        if (isLoading && reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [ReviewSkeleton(), SizedBox(height: 10), ReviewSkeleton()]),
          )
        else if (error != null && reviews.isEmpty)
          ListingNote(icon: Icons.cloud_off_rounded, text: "Reviews couldn't be loaded.")
        else
          ListingReviews(
            reviews: [for (final r in reviews) ListingReview.fromApi(r)],
            maxVisible: previewLimit,
          ),
        if (canOpenAll) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSeeAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldDeep,
                side: const BorderSide(color: AppColors.primary_1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('See all', style: AppTextStyle.sub_h3_semibold_14(color: AppColors.goldDeep)),
            ),
          ),
        ],
      ],
    );
  }
}

class ListingReviews extends StatelessWidget {
  const ListingReviews({super.key, required this.reviews, this.maxVisible});

  final List<ListingReview> reviews;

  /// Null shows every review. The listing preview passes 3.
  final int? maxVisible;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined,
                size: 28, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('No reviews yet',
                style: AppTextStyle.sub_h3_regular_14(
                    color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    final sorted = [...reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final visible = maxVisible == null ? sorted : sorted.take(maxVisible!).toList();

    return Column(
      children: [
        for (final r in visible) ...[
          ListingReviewTile(review: r),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ListingReviewTile extends StatelessWidget {
  const ListingReviewTile({super.key, required this.review});

  final ListingReview review;

  @override
  Widget build(BuildContext context) {
    // Accounts without a name (or deleted ones) still get a header.
    final raw = (review.authorName ?? '').trim();
    final name = raw.isEmpty ? 'Guest' : raw;
    final photo = (review.authorPhoto ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary_1.withValues(alpha: 0.15),
                backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
                child: photo.isNotEmpty
                    ? null
                    : Text(
                        name.characters.first.toUpperCase(),
                        style: AppTextStyle.p_medium_12(color: AppColors.primary_1)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.sub_h3_medium_14()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  review.rating >= i
                      ? Icons.star_rounded
                      : (review.rating >= i - 0.5
                          ? Icons.star_half_rounded
                          : Icons.star_outline_rounded),
                  size: 16,
                  color: AppColors.primary_1,
                ),
              const Spacer(),
              Text(
                DateFormat('d MMM yyyy').format(review.createdAt.toLocal()),
                style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment.trim(),
              style: AppTextStyle.sub_h3_regular_14(
                      color: AppColors.textSecondary)
                  .copyWith(height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen error with a back button and "Try again".
class ListingErrorView extends StatelessWidget {
  const ListingErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 44, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.sub_h3_regular_14(
                      color: AppColors.textTertiary)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary_1,
                  side: const BorderSide(color: AppColors.primary_1),
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
