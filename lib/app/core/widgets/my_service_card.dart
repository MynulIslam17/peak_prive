import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class MyServiceCard extends StatelessWidget {
  const MyServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.onDelete,
    required this.onEdit,
    this.packageType,
  });

  final String image;
  final String title;
  final String status;
  final double rating;
  final int reviews;
  final String location;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String? packageType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Fixed width, fills parent
      height: 255,            // Fixed height
      child: Stack(
        children: [
          /// Main card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height: 255,
              decoration: BoxDecoration(
                gradient: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image, // <-- use the network URL passed in
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover, // keep the aspect ratio nicely
                        errorBuilder: (context, error, stackTrace) {
                          // optional: fallback image if network fails
                          return Container(
                            width: double.infinity,
                            height: 160,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 160,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),


                    SizedBox(height: 8.h),

                    /// Title + Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyle.sub_h3_medium_14(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          status,
                          style: AppTextStyle.sub_h3_medium_14(
                            color: AppColors.primary_1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    /// Rating + Location
                    Row(
                      children: [
                        Assets.icons.star.svg(height: 12.h, width: 12.h),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyle.c_regular_12(),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "($reviews+)",
                          style: AppTextStyle.c_light_12(),
                        ),
                        const Spacer(),
                        Assets.icons.mapPinSimpleArea
                            .svg(height: 14.h, width: 14.w),
                        SizedBox(width: 5.w),
                        Text(
                          location,
                          style: AppTextStyle.c_regular_12(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Overlay — Package Label + Buttons
          Positioned(
            top: 40,
            left: 30,
            right: 30,
            child: Row(
              children: [
                if (packageType != null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary_1,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Text(
                        packageType!,
                        style: AppTextStyle.sub_h3_medium_14(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const Spacer(),

                /// Delete Button
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                /// Edit Button
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
