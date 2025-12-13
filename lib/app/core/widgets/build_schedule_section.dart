import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeScheduleSection extends StatelessWidget {
  final String startDateTime;
  final String endDateTime;

  const TimeScheduleSection({
    Key? key,
    required this.startDateTime,
    required this.endDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Schedule",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _TimeCard(
          label: "Start Date & Time",
          value: formatDate(startDateTime),
          icon: Icons.access_time_outlined,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 10),
        _TimeCard(
          label: "End Date & Time",
          value: formatDate(endDateTime),
          icon: Icons.access_time_filled_outlined,
          color: const Color(0xFFEC4899),
        ),
      ],
    );
  }



  String formatDate(String? isoDate) {
    if (isoDate == null) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }


}


class _TimeCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TimeCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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


