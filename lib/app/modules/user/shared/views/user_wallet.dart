import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';

import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/transaction_card.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/wallet_controller.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';

/// Provider: balance, withdraw, recent withdrawals.
/// Customer: recent payments (refunds go back to the card).
class UserWallet extends StatefulWidget {
  const UserWallet({super.key});

  @override
  State<UserWallet> createState() => _UserWalletState();
}

class _UserWalletState extends State<UserWallet> {
  late final WalletController wallet = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    // After the first frame: load() calls update(), not allowed mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) wallet.load();
    });
  }

  @override
  void dispose() {
    // Drop it so the next account (after a logout) never sees this one's
    // balance, withdrawals or payments. History/withdraw screens are opened
    // from here, so nothing else is using it by now.
    Get.delete<WalletController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomAppBar(title: wallet.isProvider ? "My wallet" : "Payments"),
      body: GetBuilder<WalletController>(
        builder: (c) {
          if (c.isProvider && c.isLoading && c.balance == null) {
            return const WalletSkeleton();
          }

          if (c.isProvider && c.balance == null) {
            return _ErrorState(
              title: "Couldn't load your wallet",
              message: c.errorMessage,
              onRetry: c.load,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary_1,
            onRefresh: c.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (c.isProvider) ...[
                  _buildBalanceCard(c.balance!),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Text(c.isProvider ? "Withdrawals" : "Recent payments",
                        style: AppTextStyle.sub_h1_medium_18()),
                    const Spacer(),
                    if (c.hasActivity)
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.userTransaction),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9A7A12),
                        ),
                        child: Text(
                          "See all",
                          style: AppTextStyle.sub_h3_medium_14(
                            color: const Color(0xFF9A7A12),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._activity(c),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _activity(WalletController c) {
    if (c.isActivityLoading) {
      return const [
        SkeletonTile(),
        SizedBox(height: 10),
        SkeletonTile(),
        SizedBox(height: 10),
        SkeletonTile(),
      ];
    }
    if (!c.hasActivity && c.activityError != null) {
      return [
        _EmptyCard(
          icon: Icons.cloud_off_rounded,
          title: "Couldn't load the history",
          message: c.activityError!,
          onRetry: c.loadActivity,
        ),
      ];
    }
    if (!c.hasActivity) {
      return [
        _EmptyCard(
          icon: Icons.receipt_long_outlined,
          title: c.isProvider ? "No withdrawals yet" : "No payments yet",
          message: c.isProvider
              ? "Withdrawals you request will show here."
              : "Your booking payments will show here.",
        ),
      ];
    }
    final cards = c.isProvider
        ? c.withdrawals.take(10).map(TransactionCard.withdrawal)
        : c.payments.take(10).map(TransactionCard.payment);
    return [
      for (final card in cards) ...[card, const SizedBox(height: 8)],
    ];
  }

  Widget _buildBalanceCard(num balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2C25A), AppColors.primary_1, Color(0xFFB8952B)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary_1.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.textOnPrimary, size: 20),
              const SizedBox(width: 8),
              Text("Available balance",
                  style: AppTextStyle.sub_h3_medium_14(
                      color: AppColors.textOnPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              euroLabel(balance),
              style: AppTextStyle.h1_smibold(color: AppColors.textOnPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text("Booking earnings arrive here when a booking is completed.",
              style: AppTextStyle.p_regular_12(color: AppColors.textOnPrimary)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: balance > 0 ? () => Get.toNamed(Routes.withdraw) : null,
              icon: const Icon(Icons.account_balance_outlined, size: 20),
              label: Text("Withdraw",
                  style: AppTextStyle.sub_h2_medium_16(
                      color: AppColors.textPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.message, this.onRetry});

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyle.sub_h3_semibold_14()),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text("Try again")),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.title, this.message, required this.onRetry});

  final String title;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyle.sub_h3_semibold_14()),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
            ],
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text("Try again")),
          ],
        ),
      ),
    );
  }
}
