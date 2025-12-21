import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
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
  final balanceController = Get.put(BalanceController());
  List<Transaction>? transactionList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    balanceController.fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wallet"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),

      body: GetBuilder<BalanceController>(
        builder: (controller) {
          final data = balanceController.getBalance?.data;
          transactionList = data?.transactions ?? [];

          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          if (controller.getBalance == null) {
            return Center(child: Text("No Data Found"));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SizedBox(height: 20),

                /// circle for show current balance
                _buildCircleBalance(),

                SizedBox(height: 10),

                Text("Show breakdown", style: AppTextStyle.sub_h1_regular_18()),

                SizedBox(height: 20),

                /// withddraw button
                _buildWithdrowButton(),

                SizedBox(height: 20),


                if (transactionList!.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions",
                        style: AppTextStyle.sub_h1_regular_18(),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.userTransaction);
                        },
                        child: Text(
                          "See All",
                          style: AppTextStyle.sub_h1_regular_18(
                            color: AppColors.primary_1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: transactionList?.length,
                      itemBuilder: (context, index) {
                        final transaction = transactionList![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: TransactionCard(transaction: transaction),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Image.asset("assets/images/no_payment.png",width: 256,
                  height: 280,)
                ]




              ],
            ),
          );
        },
      ),
    );
  }

  SizedBox _buildWithdrowButton() {
    return SizedBox(
      height: 60,
      width: 350,
      child: ElevatedButton(
        onPressed: () {},
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

  Align _buildCircleBalance() {
    final data = balanceController.getBalance?.data;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary_1,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner circle
            CircleAvatar(
              radius: 85,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Label
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Your Balance",
                      style: AppTextStyle.sub_h3_medium_14(
                        color: AppColors.primary_1,
                      ),
                    ),
                  ),

                  /// Amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "${data!.balance}",
                        style: AppTextStyle.h2_semibold_22(
                          color: AppColors.primary_1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
