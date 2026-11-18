import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Confirmation dialog for destructive actions (delete a listing, …).
///
/// Used by every provider type. [onDelete] returns `true` when the item was
/// deleted; the dialog then closes. On `false` it stays open and shows an
/// error so the user can retry or cancel. [icon] and [failureMessage] let
/// other destructive actions (decline a booking, …) reuse it.
class DeleteDialogService {
  /// Completes when the dialog closes.
  static Future<void> show({
    required BuildContext context,
    String title = "Delete",
    String message = "Are you sure you want to delete this item?",
    String deleteLabel = "Delete",
    String cancelLabel = "Cancel",
    Color themeColor = AppColors.error,
    IconData icon = Icons.delete_outline_rounded,
    String? Function()? failureMessage,
    required Future<bool> Function() onDelete,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;
        bool failed = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: themeColor, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.h3_semibold_20(
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.sub_h3_regular_14(
                          color: AppColors.textTertiary),
                    ),
                    if (failed) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBEAEA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                failureMessage?.call() ??
                                    "Couldn't delete. Check your connection and try again.",
                                style: AppTextStyle.p_regular_12(
                                    color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(cancelLabel,
                                  style: AppTextStyle.sub_h3_medium_14(
                                      color: AppColors.textSecondary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                        failed = false;
                                      });
                                      final success = await onDelete();
                                      if (!dialogContext.mounted) return;
                                      if (success) {
                                        Navigator.pop(dialogContext);
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                          failed = true;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                disabledBackgroundColor:
                                    themeColor.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white),
                                    )
                                  : Text(deleteLabel,
                                      style: AppTextStyle.sub_h3_medium_14(
                                          color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
