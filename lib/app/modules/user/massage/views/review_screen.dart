import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/ratingbar.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../data/models/review_model.dart';

class ReviewScreen extends StatefulWidget {
  final List<Review> reviewList; // now non-nullable and required

  const ReviewScreen({
    super.key,
    required this.reviewList,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final icon = Assets.icons;
  final image = Assets.images;

  /// ⭐ Count reviews by star value
  int countByStar(int star) {
    return widget.reviewList.where((r) => r.rating.round() == star).length;
  }

  /// ⭐ Calculate average rating
  double getAverageRating() {
    if (widget.reviewList.isEmpty) return 0.0;
    final total = widget.reviewList.fold<double>(0, (sum, r) => sum + r.rating);
    return total / widget.reviewList.length;
  }

  @override
  Widget build(BuildContext context) {
    final totalReviews = widget.reviewList.length;
    final avgRating = getAverageRating();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= RATING SUMMARY =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 170.w,
                child: Column(
                  children: List.generate(5, (i) {
                    return RatingBarRow(
                      starCount: 5 - i,
                      reviewCount: countByStar(5 - i),
                      totalReviews: totalReviews,
                    );
                  }),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTextStyle.h1_smibold()
                            .copyWith(fontSize: 40.sp),
                      ),
                      Text(
                        "/5",
                        style: AppTextStyle.h1_smibold()
                            .copyWith(fontSize: 16.sp),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < avgRating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "$totalReviews reviews",
                    style: AppTextStyle.c_regular_12().copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.h),

          /// ================= REVIEW LIST =================
          if (widget.reviewList.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Text(
                  "No reviews available",
                  style: AppTextStyle.c_regular_12(),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.reviewList.length,
              itemBuilder: (context, index) {
                final review = widget.reviewList[index];

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: review.user.profileUrl != null
                                ? NetworkImage(review.user.profileUrl!)
                                : Assets.images.profile.provider(),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.user.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.sub_h2_medium_16(),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review.rating.round()
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 14,
                                          color: Colors.amber,
                                        );
                                      }),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "${review.createdAt.day}-${review.createdAt.month}-${review.createdAt.year}",
                                      style: AppTextStyle.c_regular_12(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  review.comment,
                                  style: AppTextStyle.c_light_12(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
