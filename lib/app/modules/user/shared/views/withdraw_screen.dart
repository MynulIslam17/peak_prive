import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/my_cards_controller.dart';
import '../../../../core/widgets/account_card.dart';
import '../controllers/add_account_controller.dart';
import '../controllers/get_balance_controller.dart';
import '../controllers/withdraw_controller.dart';
import '../models/get_balance_model.dart';

// =============================================================================
// WithdrawScreen
// Main screen for selecting a withdrawal method and entering an amount.
// =============================================================================
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final addAccountController = Get.find<AddAccountController>();
  final myCardsController = Get.find<MyCardsController>();
  final withdrawController = Get.find<WithdrawRequestController>();
  final balanceController = Get.find<BalanceController>();

  // ── State ────────────────────────────────────────────────────────────────────
  String? selectedCardId;
  String? selectedCardNumber;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myCardsController.fetchMyCards();
    balanceController.fetchBalance();
  }

  // ── Withdraw Logic ───────────────────────────────────────────────────────────
  void processWithdraw() async {
    if (selectedCardNumber == null) {
      Get.snackbar("Error", "Please select a card first");
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar("Error", "Enter a valid amount");
      return;
    }

    // ── Balance Check ────────────────────────────────────────────────────────
    final int currentBalance = balanceController.getBalance?.data.balance ?? 0;
    if (amount > currentBalance) {
      Get.snackbar(
        "Insufficient Balance",
        "Your balance (\$$currentBalance) is less than the requested amount (\$${amount.toStringAsFixed(2)}",
      );
      return;
    }

    bool success = await withdrawController.withdrawAmount(
      cardId: selectedCardNumber!,
      amount: amount,
    );

    if (success) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Request Sent"),
          content: const Text(
            "Your withdrawal request has been sent successfully. "
            "You will receive the money within 24 hours.",
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text("OK", style: TextStyle(color: AppColors.primary_1)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      amountController.clear();
    }
  }

  // ── Add Card Logic ───────────────────────────────────────────────────────────
  void addCard(
    String accountType,
    String cardHolderName,
    String cardNumber,
  ) async {
    // Validations
    if (cardHolderName.trim().isEmpty || cardNumber.trim().isEmpty) {
      Get.snackbar("Required", "Please fill all fields");
      return;
    }
    if (cardNumber.trim().length < 8) {
      Get.snackbar("Invalid", "Account number must be at least 8 digits long");
      return;
    }
    final cardNumberNum = int.tryParse(cardNumber.trim());
    if (cardNumberNum == null) {
      Get.snackbar("Invalid", "Account number must be numeric");
      return;
    }

    // API Call
    bool success = await addAccountController.addAccount(
      accountType,
      cardHolderName.trim(),
      cardNumberNum,
    );

    // Response Handling
    if (success) {
      Get.back();
      myCardsController.fetchMyCards();
      Get.snackbar("Success", "Account Added");
    } else {
      Get.snackbar("Error", addAccountController.errorMessage ?? "Failed");
    }
  }

  // ── Add Card Bottom Sheet ────────────────────────────────────────────────────
  void _showAddCardBottomSheet(BuildContext context) {
    String selectedType = 'Bank Account';
    final nameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final List<String> cardTypes = ['Bank Account'];

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag Handle ──────────────────────────────────────────────
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Sheet Title ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary_1, AppColors.primary_3],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add Withdrawal Method",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black_1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Account Type Dropdown ────────────────────────────────────
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(14),
                  value: selectedType,
                  items: cardTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => selectedType = val!,
                  decoration: _inputDecoration(
                    label: "Account Type",
                    icon: Icons.category_outlined,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Holder Name ──────────────────────────────────────────────
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration(
                    label: "Account Holder Name",
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Account Number ───────────────────────────────────────────
                TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    label: "Account / Card Number",
                    icon: Icons.credit_card_outlined,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Save Button ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GetBuilder<AddAccountController>(
                    builder: (controller) => ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => addCard(
                              selectedType,
                              nameController.text,
                              accountNumberController.text,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary_1,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary_3,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Save Method",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Shared Input Decoration Helper ───────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.black_3, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary_1, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary_1, width: 1.6),
      ),
    );
  }

  // ── Balance Banner Widget ────────────────────────────────────────────────────
  Widget _buildBalanceBanner() {
    return GetBuilder<BalanceController>(
      builder: (controller) {
        final int balance = controller.getBalance?.data.balance ?? 0;
        final bool loading = controller.isLoading;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary_1,
                AppColors.primary_3.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary_1.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Wallet Icon Bubble ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // ── Balance Text ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    loading
                        ? Container(
                            width: 100,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                        : Text(
                            "\$${balance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ],
                ),
              ),

              // ── Refresh Button ───────────────────────────────────────────
              GestureDetector(
                onTap: controller.refreshBalance,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ───────────────────────────────────────────────────────────────
      appBar: CustomAppBar(title: "Withdraw"),

      body: GetBuilder<MyCardsController>(
        builder: (controller) {
          // ── Loading State ──────────────────────────────────────────────────
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          // ── Empty State ────────────────────────────────────────────────────
          if (controller.cards.isEmpty) {
            return _EmptyMethodsView(
              onAddTap: () => _showAddCardBottomSheet(context),
            );
          }

          // ── Main Content ───────────────────────────────────────────────────
          return Column(
            children: [
              // Balance Banner
              _buildBalanceBanner(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Section Label
                      const Text(
                        "Select Withdrawal Method",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black_2,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card List
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.cards.length,
                          itemBuilder: (context, index) {
                            final card = controller.cards[index];
                            return CardTile(
                              card: {
                                "cardId": card.id,
                                "accountType": card.accountType,
                                "cardNumber": card.cardNumber,
                                "cardHolderName": card.cardHolderName,
                              },
                              isSelected: selectedCardId == card.id,
                              onTap: () => setState(() {
                                selectedCardId = card.id;
                                selectedCardNumber = card.cardNumber;
                              }),
                            );
                          },
                        ),
                      ),

                      // Amount Field
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          label: "Enter Amount",
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          // Add Method
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddCardBottomSheet(context),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text("Add Method"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary_1,
                                side: const BorderSide(
                                  color: AppColors.primary_1,
                                  width: 1.4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Withdraw
                          // Withdraw
                          GetBuilder<WithdrawRequestController>(
                            builder: (wController) {
                              return Expanded(
                                child: ElevatedButton(
                                  onPressed: wController.isLoading ? null : processWithdraw,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary_1,
                                    disabledBackgroundColor: AppColors.primary_3,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  child: wController.isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text("Withdraw"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// _EmptyMethodsView
// Shown when the user has no saved withdrawal methods yet.
// =============================================================================
class _EmptyMethodsView extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyMethodsView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration bubble
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary_1.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_outlined,
              size: 52,
              color: AppColors.primary_1,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Withdrawal Methods",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.black_1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add a bank account to get started",
            style: TextStyle(fontSize: 13, color: AppColors.black_3),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("Add Method"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary_1,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
