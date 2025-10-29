import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/appText.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/ratingbar.dart';

import '../../../../../gen/assets.gen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final icon = Assets.icons;
  final image = Assets.images;

  int totalReviews = 50 + 30 + 10 + 5 + 5; // total of all reviews

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// rating review count part
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 170.w,
              child: Column(
                children: [
                  RatingBarRow(
                    starCount: 5,
                    reviewCount: 50,
                    totalReviews: 100,
                    barColor: Colors.green,
                    height: 20, // Total height of this row
                    barHeight: 10, // Height of the graphical bar
                    fontSize: 14, // Font size for texts
                    spacing: 20, // Space between elements
                  ),
                  RatingBarRow(
                    starCount: 4,
                    reviewCount: 30,
                    totalReviews: 100,
                    barColor: Colors.lightGreen,
                    height: 20, // Total height of this row
                    barHeight: 10, // Height of the graphical bar
                    fontSize: 14, // Font size for texts
                    spacing: 20, // Space between elements
                  ),
                  RatingBarRow(
                    starCount: 3,
                    reviewCount: 10,
                    totalReviews: 100,
                    barColor: Colors.orange,
                    height: 20, // Total height of this row
                    barHeight: 10, // Height of the graphical bar
                    fontSize: 14, // Font size for texts
                    spacing: 20, // Space between elements
                  ),
                  RatingBarRow(
                    starCount: 2,
                    reviewCount: 5,
                    totalReviews: 100,
                    barColor: Colors.deepOrange,
                    height: 20, // Total height of this row
                    barHeight: 10, // Height of the graphical bar
                    fontSize: 14, // Font size for texts
                    spacing: 20, // Space between elements
                  ),
                  RatingBarRow(
                    starCount: 1,
                    reviewCount: 5,
                    totalReviews: 100,
                    barColor: Colors.red,
                    height: 20, // Total height of this row
                    barHeight: 10, // Height of the graphical bar
                    fontSize: 14, // Font size for texts
                    spacing: 20, // Space between elements
                  ),
                ],
              ),
            ),

            /// review count part
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "4.7",
                      style: AppTextStyle.h1_smibold().copyWith(
                        fontSize: 40.sp,
                      ),
                    ),
                    Text(
                      "/5",
                      style: AppTextStyle.h1_smibold().copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    icon.star.svg(),
                    icon.star.svg(),
                    icon.star.svg(),
                    icon.star.svg(),
                    icon.star.svg(),
                  ],
                ),

                SizedBox(height: 2.h),
                Text(
                  "4,659 reviews",
                  style: AppTextStyle.c_regular_12().copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: image.profile.provider(),
                        radius: 35,
                      ),

                      SizedBox(width: 10.w,),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Isabella",
                               overflow: TextOverflow.ellipsis,
                               maxLines: 1,
                              style: AppTextStyle.sub_h2_medium_16(),
                            ),

                            Row(
                              children: [
                                icon.star.svg(width: 12, height: 12),
                                icon.star.svg(width: 12, height: 12),
                                icon.star.svg(width: 12, height: 12),
                                icon.star.svg(width: 12, height: 12),
                                icon.star.svg(width: 12, height: 12),

                                Spacer(),

                                /// date
                                Text(
                                  "july14,2025",
                                  style: AppTextStyle.c_regular_12(),
                                ),
                              ],
                            ),

                            Text(
                              "Feedback is constructive information given to improve performance, behavior, or understanding in various situations.",
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
    );
  }
}
