import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';

typedef ReviewSubmit = Future<({bool ok, String message})> Function(int rating, String comment);

/// Rating dialog: 1–5 whole stars + a comment. Closes with the result message
/// (null when dismissed). Stays open on a recoverable error.
class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key, required this.title, required this.onSubmit});

  final String title;
  final ReviewSubmit onSubmit;

  static Future<({bool ok, String message})?> show(BuildContext context, {required String title, required ReviewSubmit onSubmit}) =>
      showDialog<({bool ok, String message})>(
        context: context,
        builder: (_) => ReviewDialog(title: title, onSubmit: onSubmit),
      );

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _comment = TextEditingController();
  int _rating = 0;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final text = _comment.text.trim();
    if (_rating == 0) return setState(() => _error = 'Please tap a star to rate.');
    if (text.length < 3) return setState(() => _error = 'Please write a short message about your experience.');
    setState(() {
      _sending = true;
      _error = null;
    });
    final r = await widget.onSubmit(_rating, text);
    if (!mounted) return;
    // Saved, or the server says a review already exists: close either way.
    if (r.ok || r.message.contains('already')) {
      Navigator.of(context).pop(r);
    } else {
      setState(() {
        _sending = false;
        _error = r.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));
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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFFBF3DC), shape: BoxShape.circle),
              child: const Icon(Icons.star_rounded, size: 34, color: AppColors.primary_1),
            ),
            const SizedBox(height: 14),
            Text('How was your experience?', textAlign: TextAlign.center, style: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary)),
            if (widget.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
            ],
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              allowHalfRating: false, // the API takes whole stars
              itemCount: 5,
              itemSize: 36,
              itemPadding: const EdgeInsets.symmetric(horizontal: 3),
              unratedColor: const Color(0xFFE9E4D8),
              itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.primary_1),
              onRatingUpdate: (r) => setState(() {
                _rating = r.round().clamp(1, 5);
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comment,
              maxLines: 4,
              minLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyle.sub_h3_regular_14(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tell others about your experience',
                hintStyle: AppTextStyle.sub_h3_regular_14(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.scaffold,
                contentPadding: const EdgeInsets.all(14),
                border: border(AppColors.border),
                enabledBorder: border(AppColors.border),
                focusedBorder: border(AppColors.primary_1),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center, style: AppTextStyle.p_regular_12(color: AppColors.error)),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sending ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sending ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      foregroundColor: AppColors.textOnPrimary,
                      disabledBackgroundColor: AppColors.primary_1.withValues(alpha: 0.6),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit', style: TextStyle(fontWeight: FontWeight.w600)),
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
