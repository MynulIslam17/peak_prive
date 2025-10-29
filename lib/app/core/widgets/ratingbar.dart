import 'package:flutter/material.dart';

class RatingBarRow extends StatelessWidget {
  final int starCount;      // 1-5 stars
  final int reviewCount;    // Number of reviews for this star
  final int totalReviews;   // Total reviews for percentage
  final Color barColor;

  // Customizable properties
  final double height;      // Overall row height
  final double barHeight;   // Height of the graphical bar
  final double fontSize;    // Font size for text
  final double spacing;     // Spacing between elements
  final double? barWidth;   // Optional fixed width for the bar

  const RatingBarRow({
    super.key,
    required this.starCount,
    required this.reviewCount,
    required this.totalReviews,
    this.barColor = Colors.amber,
    this.height = 40,
    this.barHeight = 10,
    this.fontSize = 14,
    this.spacing = 8,
    this.barWidth,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = totalReviews == 0 ? 0 : reviewCount / totalReviews;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Star text
          Text(
            "$starCount stars",
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(width: spacing),

          // Graphical bar
          Expanded(
            child: SizedBox(
              width: barWidth,
              child: Stack(
                children: [
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(barHeight / 2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(barHeight / 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: spacing),

          // Review count
          Text(
            "$reviewCount",
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
