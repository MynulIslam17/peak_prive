import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api/peak_api.dart';
import '../../modules/user/shared/controllers/wallet_controller.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../utils/price_label.dart';

/// One wallet movement: icon, title, status/date and signed amount.
class TransactionCard extends StatelessWidget {
  const TransactionCard._({
    required this.title,
    required this.status,
    required this.amount,
    required this.isOut,
    required this.icon,
    required this.color,
    this.date,
    this.struck = false,
    super.key,
  });

  /// Provider withdrawal (money out; a rejected one went back to the balance).
  factory TransactionCard.withdrawal(Withdrawal w, {Key? key}) {
    final rejected = w.status == WithdrawalStatus.rejected;
    return TransactionCard._(
      key: key,
      title: 'Withdrawal',
      status: withdrawalStatusText(w),
      amount: w.amount,
      isOut: true,
      icon: Icons.account_balance_outlined,
      color: switch (w.status) {
        WithdrawalStatus.paid => AppColors.success,
        WithdrawalStatus.rejected => AppColors.error,
        _ => const Color(0xFFB45309),
      },
      date: w.createdAt,
      struck: rejected,
    );
  }

  /// Customer payment (money out; refunds noted in the status).
  factory TransactionCard.payment(PaymentRecord p, {Key? key}) {
    return TransactionCard._(
      key: key,
      title: paymentTitle(p),
      status: paymentStatusText(p),
      amount: p.amount,
      isOut: true,
      icon: p.isLateFee ? Icons.more_time_rounded : Icons.payments_outlined,
      color: p.status == PaymentStatus.paid ? AppColors.textPrimary : AppColors.success,
      date: p.createdAt,
    );
  }

  final String title;
  final String status;
  final num amount;
  final bool isOut;
  final IconData icon;
  final Color color;
  final DateTime? date;

  /// Amount crossed out (rejected withdrawal: nothing left the balance).
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final when = date == null ? '' : DateFormat('d MMM yyyy · h:mm a').format(date!);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.sub_h3_medium_14(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(status, style: AppTextStyle.p_medium_12(color: color)),
                if (when.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(when, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isOut ? '−' : '+'}${euroLabel(amount)}',
            style: AppTextStyle.sub_h3_semibold_14(
              color: struck ? AppColors.textTertiary : AppColors.textPrimary,
            ).copyWith(decoration: struck ? TextDecoration.lineThrough : null),
          ),
        ],
      ),
    );
  }
}
