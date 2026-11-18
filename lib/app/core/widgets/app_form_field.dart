import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Labelled, outlined form field used on provider and account forms.
///
/// Matches the "Account information" screen: label above, white field with a
/// light border, gold focus ring, optional leading icon. Password fields get
/// a show/hide toggle.
class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.prefixText,
    this.helper,
    this.textInputAction,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final String? prefixText;
  final String? helper;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final suffix = widget.isPassword
        ? IconButton(
            tooltip: _obscure ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
          )
        : widget.suffix;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyle.sub_h3_regular_14(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                AppTextStyle.sub_h3_regular_14(color: AppColors.textDisabled),
            // Icon and/or a fixed prefix such as "€", always visible
            // (InputDecoration.prefixText only shows while focused).
            prefixIcon: widget.icon == null && widget.prefixText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null)
                          Icon(widget.icon,
                              size: 20, color: AppColors.textTertiary),
                        if (widget.icon != null && widget.prefixText != null)
                          const SizedBox(width: 8),
                        if (widget.prefixText != null)
                          Text(widget.prefixText!.trim(),
                              style: AppTextStyle.sub_h3_medium_14(
                                  color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: suffix,
            helperText: widget.helper,
            helperStyle:
                AppTextStyle.p_regular_12(color: AppColors.textTertiary),
            helperMaxLines: 2,
            errorMaxLines: 2,
            filled: true,
            // A read-only field that opens a picker is still editable, so it
            // keeps the white fill; only truly locked ones look greyed out.
            fillColor: widget.readOnly && widget.onTap == null
                ? AppColors.surfaceAlt
                : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary_1, 1.4),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.4),
          ),
        ),
      ],
    );
  }
}

/// Full-width primary action with a loading state.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          disabledBackgroundColor: AppColors.primary_1.withValues(alpha: 0.6),
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  // Shrinks rather than overflowing with very large text.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label,
                          maxLines: 1,
                          style: AppTextStyle.sub_h2_medium_16(
                              color: AppColors.textOnPrimary)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
