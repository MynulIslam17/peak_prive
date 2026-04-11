import 'package:flutter/material.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/modules/user/shared/models/get_balance_model.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    required this.transaction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = transaction.createdAt != null
        ? DateFormat('MMM d, yyyy • hh:mm a').format(transaction.createdAt!)
        : '';

    final isOut = transaction.flow == WalletFlowType.OUT;

    final Color color = isOut ? Colors.red : Colors.green;
    final IconData icon = isOut ? Icons.call_missed_outgoing : Icons.call_received;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        /// ICON
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),

        /// USER / TYPE
        title: Text(
          transaction.type?.name ?? 'Transaction',
          style: AppTextStyle.p_medium_12(),
        ),

        /// DATE
        subtitle: Text(
          formattedDate,
          style: AppTextStyle.p_medium_12(color: Colors.grey),
        ),

        /// AMOUNT
        trailing: Text(
          "${isOut ? '-' : '+'} \€${transaction.balance ?? 0}",
          style: AppTextStyle.sub_h3_medium_14(color: color),
        ),
      ),
    );
  }
}
