import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';

/// Confirm dialog for a booking action. Returns null when dismissed, else the
/// (optional) reason typed in.
Future<({String? reason})?> confirmBookingAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Not now',
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
  bool askReason = false,
  String reasonHint = 'Reason (optional)',
}) {
  return showDialog<({String? reason})>(
    context: context,
    builder: (_) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      destructive: destructive,
      askReason: askReason,
      reasonHint: reasonHint,
    ),
  );
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.destructive,
    required this.askReason,
    required this.reasonHint,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool destructive;
  final bool askReason;
  final String reasonHint;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.destructive ? AppColors.error : AppColors.primary_1;
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(widget.icon, size: 30, color: accent),
            ),
            const SizedBox(height: 14),
            Text(widget.title, textAlign: TextAlign.center, style: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyle.sub_h3_regular_14(color: AppColors.textSecondary).copyWith(height: 1.4)),
            if (widget.askReason) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _reason,
                maxLines: 3,
                minLines: 2,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.reasonHint,
                  filled: true,
                  fillColor: AppColors.scaffold,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accent)),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final r = _reason.text.trim();
                      Navigator.of(context).pop((reason: r.isEmpty ? null : r));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: widget.destructive ? Colors.white : AppColors.textOnPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.confirmLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
