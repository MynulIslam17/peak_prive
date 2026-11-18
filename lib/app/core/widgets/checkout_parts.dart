import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Building blocks shared by the checkout screens (ski pass, ski hire, …).
///
/// Every checkout follows the same flow: fill the form → pay with Stripe →
/// create the booking. If the payment succeeds but the booking call fails,
/// the screen keeps the transaction id and offers "Retry booking" so the user
/// is never charged twice.

enum CheckoutStage { idle, paying, booking, completed }

/// "€25" / "€25.50".
String checkoutEuro(num v) => NumberFormat.currency(
  locale: 'en_IE',
  symbol: '€',
  decimalDigits: v % 1 == 0 ? 0 : 2,
).format(v);

/// Date/time pickers use the app theme (`AppTheme.light`: white, gold
/// selection). Kept so existing `builder:` arguments still compile.
Widget checkoutPickerTheme(BuildContext context, Widget? child) => child!;

/// Bottom-sheet message with a single OK button.
void showCheckoutMessage(
  BuildContext context,
  String title,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
              size: 48,
              color: isError ? AppColors.error : AppColors.primary_1,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.sub_h1_medium_18(),
            ),
            const SizedBox(height: 8),
            SelectableText(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.sub_h3_regular_14(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary_1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onAction?.call();
                },
                child: Text(actionLabel ?? 'OK'),
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Not now'),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Asks before leaving a checkout whose payment went through but whose
/// booking was not created. Returns true when the user chooses to leave.
Future<bool> confirmLeaveUnbookedPayment(
  BuildContext context,
  String transactionId,
) async {
  final leave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Booking not confirmed'),
      content: Text(
        'Your payment was received but the booking was not created. '
        'If you leave now, contact support with this reference:\n\n'
        '$transactionId',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Leave anyway'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary_1),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Stay'),
        ),
      ],
    ),
  );
  return leave ?? false;
}

/// Standard checkout app bar.
PreferredSizeWidget checkoutAppBar(BuildContext context, String title) =>
    AppBar(
      backgroundColor: AppColors.scaffold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title, style: AppTextStyle.sub_h1_medium_18()),
    );

// ─────────────────────────────── Widgets ───────────────────────────────

class CheckoutCard extends StatelessWidget {
  const CheckoutCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class CheckoutSectionLabel extends StatelessWidget {
  const CheckoutSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(text, style: AppTextStyle.sub_h2_medium_16()),
    );
  }
}

/// Thumbnail + title + location + price line at the top of a checkout.
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.location,
    this.price,
    this.priceSuffix,
  });

  final String imageUrl;
  final String title;
  final String? location;
  final String? price;
  final String? priceSuffix;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 76,
              height: 76,
              child: imageUrl.isEmpty
                  ? Container(color: AppColors.shimmerBase)
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.shimmerBase),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.sub_h2_medium_16(),
                ),
                if ((location ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.p_regular_12(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (price != null) ...[
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: AppTextStyle.sub_h3_semibold_14(
                            color: AppColors.primary_1,
                          ),
                        ),
                        if (priceSuffix != null)
                          TextSpan(
                            text: priceSuffix,
                            style: AppTextStyle.p_regular_12(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round − / + button used by quantity steppers.
class CheckoutStepButton extends StatelessWidget {
  const CheckoutStepButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.size = 40,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? AppColors.primary_1.withValues(alpha: 0.12)
            : AppColors.disabled,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size / 2,
              color: enabled ? AppColors.primary_1 : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

/// − value + row.
class CheckoutQuantityStepper extends StatelessWidget {
  const CheckoutQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.enabled = true,
    this.unit = 'items',
    this.buttonSize = 40,
  });

  final int value;
  final int min;
  final int max;
  final bool enabled;
  final String unit;
  final double buttonSize;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckoutStepButton(
          icon: Icons.remove_rounded,
          tooltip: 'Less',
          size: buttonSize,
          onTap: enabled && value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: buttonSize + 4,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            semanticsLabel: '$value $unit',
            style: AppTextStyle.sub_h1_medium_18(),
          ),
        ),
        CheckoutStepButton(
          icon: Icons.add_rounded,
          tooltip: 'More',
          size: buttonSize,
          onTap: enabled && value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

/// Tappable row that opens a picker (date, time, …) and shows its value.
class CheckoutPickerTile extends StatelessWidget {
  const CheckoutPickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.error,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final String? error;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (hasError ? AppColors.error : AppColors.primary_1)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: hasError ? AppColors.error : AppColors.primary_1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.p_regular_12(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? placeholder,
                    style: value == null
                        ? AppTextStyle.sub_h3_regular_14(
                            color: AppColors.textDisabled,
                          )
                        : AppTextStyle.sub_h3_medium_14(),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 4),
                    Text(
                      error!,
                      style: AppTextStyle.p_regular_12(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Price lines followed by a divider and the bold total.
class CheckoutPriceBreakdown extends StatelessWidget {
  const CheckoutPriceBreakdown({
    super.key,
    required this.lines,
    required this.total,
    this.footnote,
    this.totalLabel = 'Total (EUR)',
  });

  final String totalLabel;

  /// (label, amount) pairs.
  final List<(String, String)> lines;
  final double total;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: bold
                ? AppTextStyle.sub_h2_medium_16()
                : AppTextStyle.sub_h3_regular_14(
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: bold
              ? AppTextStyle.sub_h2_medium_16().copyWith(
                  fontWeight: FontWeight.w700,
                )
              : AppTextStyle.sub_h3_medium_14(),
        ),
      ],
    );

    return Column(
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          row(lines[i].$1, lines[i].$2),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        row(totalLabel, checkoutEuro(total), bold: true),
        if (footnote != null) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footnote!,
                  style: AppTextStyle.p_regular_12(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class CheckoutSecureNote extends StatelessWidget {
  const CheckoutSecureNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Payments are processed securely by Stripe',
            style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}

/// Pinned bar with the total and the Pay / Retry booking button.
class CheckoutBar extends StatelessWidget {
  const CheckoutBar({
    super.key,
    required this.total,
    required this.stage,
    required this.needsBookingRetry,
    required this.onPressed,
    this.totalLabel = 'Total',
    this.idleButtonLabel,
  });

  /// Small label above the amount (e.g. "Per day" before dates are set).
  final String totalLabel;

  /// Replaces "Pay €X" in the idle state (e.g. "Choose dates").
  final String? idleButtonLabel;

  final double total;
  final CheckoutStage stage;
  final bool needsBookingRetry;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final busy =
        stage == CheckoutStage.paying || stage == CheckoutStage.booking;
    final label = switch (stage) {
      CheckoutStage.paying => 'Processing…',
      CheckoutStage.booking => 'Confirming…',
      CheckoutStage.completed => 'Booked',
      CheckoutStage.idle =>
        needsBookingRetry
            ? 'Retry booking'
            : idleButtonLabel ?? 'Pay now',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // Total: never cut off — shrinks to fit for big amounts.
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalLabel,
                          maxLines: 1,
                          style: AppTextStyle.p_regular_12(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            checkoutEuro(total),
                            maxLines: 1,
                            style: AppTextStyle.h3_semibold_20(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: busy || stage == CheckoutStage.completed
                            ? null
                            : onPressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary_1,
                          disabledBackgroundColor: AppColors.primary_1
                              .withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (busy) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ] else if (stage == CheckoutStage.idle &&
                                !needsBookingRetry &&
                                idleButtonLabel == null) ...[
                              const Icon(Icons.lock_rounded, size: 18),
                              const SizedBox(width: 8),
                            ],
                            // Shrink instead of "…" so the label is
                            // always readable.
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: AppTextStyle.sub_h2_medium_16(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered icon + title + message + action (errors, empty states).
class CheckoutStateView extends StatelessWidget {
  const CheckoutStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyle.sub_h1_medium_18()),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.sub_h3_regular_14(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary_1,
                side: const BorderSide(color: AppColors.primary_1),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
