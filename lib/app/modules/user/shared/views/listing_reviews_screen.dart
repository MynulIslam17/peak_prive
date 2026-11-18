import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';
import '../../../../data/api/peak_api.dart';
import '../controllers/listing_reviews_controller.dart';

void openListingReviews({required ServiceKind kind, required String? id}) {
  if (id == null || id.isEmpty) return;
  Get.to(() => ListingReviewsScreen(kind: kind, listingId: id));
}

class ListingReviewsScreen extends StatefulWidget {
  const ListingReviewsScreen({super.key, required this.kind, required this.listingId});

  final ServiceKind kind;
  final String listingId;

  @override
  State<ListingReviewsScreen> createState() => _ListingReviewsScreenState();
}

class _ListingReviewsScreenState extends State<ListingReviewsScreen> {
  late final ListingReviewsController controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = 'reviews-${widget.kind.path}-${widget.listingId}';
    controller = Get.put(
      ListingReviewsController(kind: widget.kind, listingId: widget.listingId),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ListingReviewsController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Reviews', style: AppTextStyle.sub_h1_medium_18()),
      ),
      body: GetBuilder<ListingReviewsController>(
        tag: _tag,
        builder: (c) {
          if (c.isLoading && c.reviews.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [ReviewSkeleton(), SizedBox(height: 10), ReviewSkeleton()]),
            );
          }
          if (c.errorMessage != null && c.reviews.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListingNote(icon: Icons.cloud_off_rounded, text: "Reviews couldn't be loaded."),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: c.load, child: const Text('Try again')),
              ],
            );
          }
          if (c.reviews.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ListingReviews(reviews: []),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 240) {
                c.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: c.reviews.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                if (index == c.reviews.length) {
                  if (c.isLoadingMore) return const ReviewSkeleton();
                  return const SizedBox.shrink();
                }
                return ListingReviewTile(review: ListingReview.fromApi(c.reviews[index]));
              },
            ),
          );
        },
      ),
    );
  }
}
