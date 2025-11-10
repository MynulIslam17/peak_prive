import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ProviderBookingCard extends StatelessWidget {
  const ProviderBookingCard({
    super.key, required this.images,
    required this.onTap});

  final AssetGenImage images;

  final icons = Assets.icons;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.white,

        child: InkWell(
          onTap:onTap,
          splashColor: AppColors.primary_1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),

          child: Row(
            children: [
              /// images
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: images.image(width: 93, height: 95, fit: BoxFit.cover),
                ),
              ),

              /// info part of card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// -------- First Row --------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Person
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Person",
                                  style: AppTextStyle.c_regular_12(
                                    color: AppColors.black_3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    icons.user.svg(),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        "3",
                                        style: AppTextStyle.c_regular_10(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// Ski Pass Type
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ski Pass Type",
                                  style: AppTextStyle.c_regular_12(
                                    color: AppColors.black_3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    icons.vip.svg(),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        "Vip",
                                        style: AppTextStyle.c_regular_10(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// -------- Second Row --------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Date & Time
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date & time",
                                  style: AppTextStyle.c_regular_12(
                                    color: AppColors.black_3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    icons.calendarDots.svg(),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        "10 Jun | 09:45",
                                        style: AppTextStyle.c_regular_10(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// Location
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Location",
                                  style: AppTextStyle.c_regular_12(
                                    color: AppColors.black_3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    icons.mapPinSimpleArea.svg(),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        "Mountain1 ssssssssdddddddddd",
                                        style: AppTextStyle.c_regular_10(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
