
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/transaction_card.dart';
import '../controllers/get_balance_controller.dart';
import '../models/get_balance_model.dart';

class AllTransaction extends StatefulWidget {
  const AllTransaction({super.key});

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  final  balanceController =Get.put(BalanceController()) ;

  @override
  void initState() {
    super.initState();
    balanceController.fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: GetBuilder<BalanceController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.getBalance == null ||
              controller.getBalance!.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final transactions =
              controller.getBalance!.data!.transactions ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text("No transactions available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TransactionCard(transaction: transactions[index]),
              );
            },
          );
        },
      ),
    );
  }
}

