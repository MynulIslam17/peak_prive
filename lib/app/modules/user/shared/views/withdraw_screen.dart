import 'package:harry_service_app/app/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import '../../../../core/widgets/account_card.dart';
import '../controllers/wallet_controller.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';

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
  late final WalletController wallet = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());

  // ── State ────────────────────────────────────────────────────────────────────
  String? selectedAccountId;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    wallet.loadAccount();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // ── Withdraw Logic ───────────────────────────────────────────────────────────
  Future<void> processWithdraw() async {
    FocusScope.of(context).unfocus();
    final amountText = amountController.text;
    final error = await wallet.withdraw(
      accountId: selectedAccountId,
      amountText: amountText,
    );
    if (!mounted) return;
    if (error != null) {
      AppToast.error(error, title: "Withdrawal not sent");
      return;
    }
    amountController.clear();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Request sent"),
        content: Text(
          "We've reserved ${euroLabel(WalletController.parseAmount(amountText) ?? 0)} "
          "from your balance. You'll see the status under Withdrawals.",
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
  }

  // ── Add Card Logic ───────────────────────────────────────────────────────────
  Future<void> addCard(
    String accountType,
    String cardHolderName,
    String cardNumber,
  ) async {
    final error = await wallet.addAccount(
      accountType: accountType,
      cardHolderName: cardHolderName,
      cardNumber: cardNumber,
    );
    if (error != null) {
      AppToast.error(error, title: "Couldn't add account");
      return;
    }
    Get.back();
    AppToast.success("You can now withdraw to this account.", title: "Account added");
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
                  child: GetBuilder<WalletController>(
                    builder: (controller) => ElevatedButton(
                      onPressed: controller.isAddingAccount
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
                      child: controller.isAddingAccount
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
    return GetBuilder<WalletController>(
      builder: (controller) {
        final num balance = controller.balance ?? 0;
        final bool loading = controller.isLoading;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE2C25A), AppColors.primary_1, Color(0xFFB8952B)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary_1.withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF1F1A10),
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
                      "Available balance",
                      style: TextStyle(
                        color: Color(0xCC1F1A10),
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
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                        : Text(
                            euroLabel(balance),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1F1A10),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ],
                ),
              ),

              // ── Refresh Button ───────────────────────────────────────────
              GestureDetector(
                onTap: controller.loadAccount,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Color(0xFF1F1A10),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFF1F1A10),
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
      backgroundColor: AppColors.scaffold,

      // ── AppBar ───────────────────────────────────────────────────────────────
      appBar: CustomAppBar(title: "Withdraw"),

      body: GetBuilder<WalletController>(
        builder: (controller) {
          // ── Loading State ──────────────────────────────────────────────────
          if (controller.isLoading && controller.balance == null) {
            return const WithdrawSkeleton();
          }

          // ── Error State ────────────────────────────────────────────────────
          if (controller.balance == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.errorMessage ?? "Couldn't load your wallet",
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controller.loadAccount,
                      child: const Text("Try again"),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty State ────────────────────────────────────────────────────
          if (controller.accounts.isEmpty) {
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
                        "Withdraw to",
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
                          itemCount: controller.accounts.length,
                          itemBuilder: (context, index) {
                            final account = controller.accounts[index];
                            return CardTile(
                              account: account,
                              isSelected: selectedAccountId == account.id,
                              onTap: () => setState(() {
                                selectedAccountId = account.id;
                              }),
                            );
                          },
                        ),
                      ),

                      // Amount Field
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(
                          label: "Amount (€)",
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
                          GetBuilder<WalletController>(
                            builder: (wController) {
                              return Expanded(
                                child: ElevatedButton(
                                  onPressed: wController.isWithdrawing ? null : processWithdraw,
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
                                  child: wController.isWithdrawing
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
