import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/transaction_card.dart';
import '../controllers/wallet_controller.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';

/// Full withdrawal history (provider) or payment history (customer), paged.
class AllTransaction extends StatefulWidget {
  const AllTransaction({super.key});

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  late final WalletController wallet = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!wallet.hasActivity) wallet.loadActivity();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) wallet.loadMoreActivity();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomAppBar(title: wallet.isProvider ? "Withdrawals" : "Payments"),
      body: GetBuilder<WalletController>(
        builder: (c) {
          if (c.isActivityLoading && !c.hasActivity) {
            return const TransactionListSkeleton();
          }
          if (!c.hasActivity) {
            return RefreshIndicator(
              color: AppColors.primary_1,
              onRefresh: c.loadActivity,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Text(c.activityError != null
                        ? "Couldn't load the history. Pull to try again."
                        : "Nothing here yet"),
                  ),
                ],
              ),
            );
          }
          final count = c.isProvider ? c.withdrawals.length : c.payments.length;
          return RefreshIndicator(
            color: AppColors.primary_1,
            onRefresh: c.loadActivity,
            child: ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: count + (c.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                if (i >= count) {
                  return const TransactionSkeleton();
                }
                return c.isProvider
                    ? TransactionCard.withdrawal(c.withdrawals[i])
                    : TransactionCard.payment(c.payments[i]);
              },
            ),
          );
        },
      ),
    );
  }
}
