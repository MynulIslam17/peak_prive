import 'package:flutter/material.dart';

class OvertimeAndChargeSection extends StatelessWidget {
  final String timeLabel;
  final num overtimeAmount;
  final num? extraChargePerHour;

  const OvertimeAndChargeSection({
    Key? key,
    required this.timeLabel,
    required this.overtimeAmount,
    this.extraChargePerHour,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.10),
            const Color(0xFFD97706).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildInfoCard(
            label: "Over Time",
            value: timeLabel,
            icon: Icons.timer_outlined,
          ),
          _buildDivider(),
          _buildInfoCard(
            label: "Overtime Cost",
            // UPDATED: Changed to Euro symbol
            value: "€ ${overtimeAmount.toStringAsFixed(2)}",
            icon: Icons.payments_outlined,
            isHighlight: true,
          ),
          if (extraChargePerHour != null) ...[
            _buildDivider(),
            _buildInfoCard(
              label: "Extra / Hour",
              // UPDATED: Changed to Euro symbol
              value: "€ ${extraChargePerHour!.toStringAsFixed(2)}",
              icon: Icons.add_circle_outline,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                color: isHighlight ? const Color(0xFFF59E0B) : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isHighlight ? const Color(0xFFF59E0B) : Colors.grey.shade800,
                  ),
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
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade300,
    );
  }
}