import 'package:flutter/material.dart';

class SeatAndAmountSection extends StatelessWidget {
  final String seatType;
  final num totalAmount;

  const SeatAndAmountSection({
    Key? key,
    required this.seatType,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.08),
            const Color(0xFF059669).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(
            "Seat Type",
            seatType,
            icon: Icons.event_seat,
          ),
          _buildDivider(),
          _buildInfoCard(
            "Total Amount",
            totalAmount.toString(),
            icon: Icons.attach_money,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String label,
      String value, {
        bool isHighlight = false,
        required IconData icon,
      }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isHighlight
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isHighlight
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
