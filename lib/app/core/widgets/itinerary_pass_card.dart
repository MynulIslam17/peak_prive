import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ItinerarySkiPass extends StatelessWidget {
  final String image;
  final String persons;
  final String duration;
  final String dateTime;
  final String location;
  final VoidCallback onDetailsPressed;

  const ItinerarySkiPass({
    super.key,
    required this.image,
    required this.persons,
    required this.duration,
    required this.dateTime,
    required this.location,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Person & Duration
                  Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          label: "Person",
                          value: persons,
                          icon: Icons.person,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoItem(
                          label: "Duration",
                          value: duration,
                          icon: Icons.timer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Date & Location
                  Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          label: "Date & Time",
                          value: dateTime,
                          icon: Icons.calendar_month,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoItem(
                          label: "Location",
                          value: location,
                          icon: Icons.location_on,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Details Button aligned to bottom right
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
                          "Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Helper widget for label + icon + value
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.c_light_10()),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: AppTextStyle.c_light_10(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}