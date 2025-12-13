import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ContactDetailsSection extends StatelessWidget {
  final String address;
  final String phoneNumber;

  const ContactDetailsSection({
    Key? key,
    required this.address,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _ContactDetailRow(
          icon: Icons.location_on_outlined,
          label: "Address",
          value: address.isNotEmpty ? address : "N/A",
          accentColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 10),
        _ContactDetailRow(
          icon: Icons.phone_outlined,
          label: "Phone Number",
          value: phoneNumber.isNotEmpty ? phoneNumber : "N/A",
          accentColor: const Color(0xFF10B981),
        ),
      ],
    );
  }
}


class _ContactDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _ContactDetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
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
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
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
