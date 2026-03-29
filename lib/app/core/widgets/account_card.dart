// =============================================================================
// CardTile
// Selectable card item showing account type, holder name, and masked number.
// =============================================================================
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CardTile extends StatelessWidget {
  final Map<String, dynamic> card;
  final bool isSelected;
  final VoidCallback onTap;

  const CardTile({
    super.key,
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mask all but last 4 digits of the card/account number
    final rawNumber = card['cardNumber'].toString();
    final maskedNumber =
        "•••• ${rawNumber.substring(rawNumber.length - 4)}";

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Gradient card background when selected
          gradient: isSelected ? AppColors.cardBackground : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary_1 : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary_1.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon Bubble ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary_1.withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: isSelected ? AppColors.primary_1 : AppColors.black_3,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // ── Account Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['accountType'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected ? AppColors.black_1 : AppColors.black_2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${card['cardHolderName']}  $maskedNumber",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.black_3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Selection Indicator ────────────────────────────────────────
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary_1,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}