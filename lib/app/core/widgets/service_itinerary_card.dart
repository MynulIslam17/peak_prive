import 'package:flutter/material.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import '../constants/app_colors.dart';

class ServiceItineraryCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onDetailsPressed;

  /// Middle row content: icon + text
  final IconData middleIcon;
  final String middleText;

  const ServiceItineraryCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onDetailsPressed,
    required this.middleIcon,
    required this.middleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left
            CustomCachedImage(
              width: 100,
              height: 100,
              imageUrl: imageUrl,
            ),
            const SizedBox(width: 16),

            // Content on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyle.sub_h2_medium_16(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$$price',
                        style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1)
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Flexible Middle Row (icon + text)
                  Row(
                    children: [
                      Icon(middleIcon, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        middleText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Details Button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: onDetailsPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary_1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Detail's",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}