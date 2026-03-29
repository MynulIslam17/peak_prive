import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/modules/user/shared/models/get_balance_model.dart';

import '../../../../core/widgets/transaction_card.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/get_balance_controller.dart';

class UserWallet extends StatefulWidget {
  const UserWallet({super.key});

  @override
  State<UserWallet> createState() => _UserWalletState();
}

class _UserWalletState extends State<UserWallet> {
  final BalanceController balanceController = Get.put(BalanceController());

  @override
  void initState() {
    super.initState();
    balanceController.fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "My Wallet"),
      body: GetBuilder<BalanceController>(
        builder: (_) {
          if (balanceController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          if (balanceController.getBalance?.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final data = balanceController.getBalance!.data!;
          final transactions = data.transactions ?? [];

          return RefreshIndicator(
            onRefresh: balanceController.refreshBalance,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// Circle showing current balance
                  _buildCircleBalance(data),

                  const SizedBox(height: 10),
                  Text("Show breakdown", style: AppTextStyle.sub_h1_regular_18()),

                  const SizedBox(height: 20),

                  /// Withdraw button
                  _buildWithdrawButton(),

                  const SizedBox(height: 20),

                  /// Transactions list
                  if (transactions.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Transactions", style: AppTextStyle.sub_h1_regular_18()),
                        InkWell(
                          onTap: () => Get.toNamed(Routes.userTransaction),
                          child: Text(
                            "See All",
                            style: AppTextStyle.sub_h1_regular_18(color: AppColors.primary_1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: TransactionCard(transaction: transaction),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/images/no_payment.png",
                          width: 256,
                          height: 280,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Circle showing current balance
  Align _buildCircleBalance(Data data) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          color: AppColors.primary_1,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircleAvatar(
            radius: 85,
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Your Balance",
                    style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1),
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${data.balance}",
                      style: AppTextStyle.h2_semibold_22(color: AppColors.primary_1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Withdraw button
  SizedBox _buildWithdrawButton() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle withdraw logic

          Get.toNamed(Routes.withdraw);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_exchange),
            const SizedBox(width: 10),
            Text(
              "Withdraw",
              style: AppTextStyle.sub_h2_medium_16(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}