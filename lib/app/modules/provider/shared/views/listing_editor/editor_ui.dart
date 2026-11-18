import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/text-style.dart';
import '../../../../../core/widgets/app_form_field.dart';
import '../../../../../core/widgets/custom_appbar.dart';
import '../../../../../core/widgets/image_picker_dialog.dart';
import '../../../../../data/api/peak_api.dart';
import '../../models/listing_drafts.dart';
import '../../../../../core/widgets/shimmer/skeleton.dart';

/// Building blocks shared by the five add/edit listing screens, so every
/// provider type gets the same look and behaviour.

const editorGold = Color(0xFF9A7A12);
const _goldTint = Color(0xFFFBF3DC);

final decimalInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
final digitsInput = [FilteringTextInputFormatter.digitsOnly];

/// Scaffold with loading / load-error states and a sticky save button.
class EditorScaffold extends StatelessWidget {
  const EditorScaffold({
    super.key,
    required this.title,
    required this.isLoading,
    required this.loadError,
    required this.onRetry,
    required this.children,
    required this.isEdit,
    required this.saving,
    required this.onSave,
  });

  final String title;
  final bool isLoading;
  final String? loadError;
  final VoidCallback onRetry;
  final List<Widget> children;
  final bool isEdit;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (isLoading) {
      body = const FormSkeleton();
    } else if (loadError != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text("Couldn't load this listing",
                  style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(loadError!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      );
    } else {
      body = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: children,
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomAppBar(title: title, onBackPressed: () => Navigator.maybePop(context)),
      body: body,
      bottomNavigationBar: isLoading || loadError != null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: AppPrimaryButton(
                  label: isEdit ? 'Save changes' : 'Publish listing',
                  icon: isEdit ? Icons.check_rounded : Icons.rocket_launch_outlined,
                  loading: saving,
                  onPressed: onSave,
                ),
              ),
            ),
    );
  }
}

class EditorSection extends StatelessWidget {
  const EditorSection({super.key, required this.title, this.subtitle, this.trailing, required this.children});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Small gold count badge for section headers.
class CountBadge extends StatelessWidget {
  const CountBadge(this.count, {super.key});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _goldTint, borderRadius: BorderRadius.circular(20)),
        child: Text('$count', style: AppTextStyle.p_medium_12(color: editorGold)),
      );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
      );
}

/// Asks gallery/camera, returns the picked file (or null).
Future<File?> pickPhoto(BuildContext context) async {
  ImageSource? source;
  await ImagePickerDialogService.show(
    context: context,
    title: 'Choose image',
    subtitle: 'Select from gallery or take a new photo',
    primaryColor: AppColors.primary_1,
    galleryIconColor: AppColors.primary_1,
    cameraIconColor: Colors.orange,
    onImageSourceSelected: (s) => source = s,
  );
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(source: source!, imageQuality: 85, maxWidth: 2000);
  return picked == null ? null : File(picked.path);
}

Widget _photo({File? file, String? url}) {
  if (file != null) return Image.file(file, fit: BoxFit.cover);
  if (url != null && url.isNotEmpty) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.surfaceAlt,
        child: Icon(Icons.broken_image_outlined, color: AppColors.textDisabled),
      ),
    );
  }
  return const SizedBox.shrink();
}

class CoverPhotoPicker extends StatelessWidget {
  const CoverPhotoPicker({super.key, this.file, this.url, required this.onTap});
  final File? file;
  final String? url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final has = file != null || (url ?? '').isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: has
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _photo(file: file, url: url),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('Change photo', style: AppTextStyle.p_medium_12(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: _goldTint, shape: BoxShape.circle),
                      child: const Icon(Icons.add_a_photo_outlined, color: editorGold, size: 24),
                    ),
                    const SizedBox(height: 10),
                    Text('Add a cover photo', style: AppTextStyle.sub_h3_medium_14(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('JPG or PNG · shown on your listing',
                        style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                  ],
                ),
        ),
      ),
    );
  }
}

class SmallPhotoPicker extends StatelessWidget {
  const SmallPhotoPicker({super.key, this.file, this.url, required this.onTap, this.size = 76});
  final File? file;
  final String? url;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final has = file != null || (url ?? '').isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: has
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _photo(file: file, url: url),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('Change',
                          textAlign: TextAlign.center, style: AppTextStyle.p_regular_12(color: Colors.white)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: editorGold, size: 22),
                  const SizedBox(height: 4),
                  Text('Photo', style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                ],
              ),
      ),
    );
  }
}

/// Single-choice chips.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({super.key, required this.values, required this.labelOf, required this.selected, required this.onSelected});
  final List<T> values;
  final String Function(T) labelOf;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(labelOf(v)),
            selected: selected == v,
            onSelected: (_) => onSelected(v),
            showCheckmark: false,
            labelStyle: AppTextStyle.sub_h3_medium_14(
              color: selected == v ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary_1,
            side: BorderSide(color: selected == v ? AppColors.primary_1 : AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
      ],
    );
  }
}

/// Sub-category chips with loading / error / empty states.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onSelected,
    this.fallbackName,
  });

  final List<CategoryOption> options;
  final String? selectedId;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelected;

  /// Name of the saved category when it isn't in [options] (e.g. removed).
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // Category chips loading.
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: SkeletonShimmer(
          child: Wrap(spacing: 8, children: [
            SkeletonBox(width: 80, height: 34, radius: 17),
            SkeletonBox(width: 100, height: 34, radius: 17),
            SkeletonBox(width: 70, height: 34, radius: 17),
          ]),
        ),
      );
    }
    if (error != null && options.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text("Couldn't load categories. $error",
                style: AppTextStyle.p_regular_12(color: AppColors.error)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    final known = options.any((o) => o.id == selectedId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChoiceChips<String>(
          values: options.map((o) => o.id).toList(),
          labelOf: (id) => options.firstWhere((o) => o.id == id).name,
          selected: selectedId,
          onSelected: onSelected,
        ),
        if (selectedId != null && !known && (fallbackName ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Current: $fallbackName', style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
        ],
      ],
    );
  }
}

class AddRowButton extends StatelessWidget {
  const AddRowButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, color: editorGold),
        label: Text(label, style: AppTextStyle.sub_h3_medium_14(color: editorGold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary_3),
          backgroundColor: const Color(0xFFFFFCF3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Grey card for one repeated row (item, seat, duration, service).
class RowCard extends StatelessWidget {
  const RowCard({super.key, required this.label, this.onRemove, required this.children});
  final String label;
  final VoidCallback? onRemove;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyle.p_medium_12(color: editorGold)),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  tooltip: 'Remove',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

/// Tappable clock field ("7:00 PM"), picks with the system time picker.
class ClockField extends StatelessWidget {
  const ClockField({super.key, required this.label, required this.value, required this.onChanged});
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final has = (value ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            final picked = await showTimePicker(
              context: context,
              initialTime: parseClock(value) ?? const TimeOfDay(hour: 9, minute: 0),
            );
            if (picked != null) onChanged(formatClock(picked));
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 20, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(has ? value! : 'Choose',
                    style: AppTextStyle.sub_h3_regular_14(
                        color: has ? AppColors.textPrimary : AppColors.textDisabled)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Short tip box (e.g. how the late fee works).
class EditorNote extends StatelessWidget {
  const EditorNote(this.text, {super.key, this.icon = Icons.info_outline_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFFFFCF3), borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: editorGold),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: AppTextStyle.p_regular_12(color: AppColors.textSecondary))),
          ],
        ),
      );
}

/// Edit screens are opened with `{'isEdit': true, 'id': listingId}`. Older
/// call sites pass a model object (`'hire'`, `'pass'`, …); its `id`/`sId`
/// is read so they keep working.
String? listingIdFromArgs(dynamic args) {
  if (args is! Map) return null;
  if (args['isEdit'] == false) return null;
  final id = args['id'];
  if (id is String && id.isNotEmpty) return id;
  for (final key in const ['listing', 'hire', 'pass', 'transport', 'massage', 'restaurant']) {
    final o = args[key];
    if (o == null) continue;
    if (o is ListingCard) return o.id;
    try {
      final v = (o as dynamic).id;
      if (v is String && v.isNotEmpty) return v;
    } catch (_) {}
    try {
      final v = (o as dynamic).sId;
      if (v is String && v.isNotEmpty) return v;
    } catch (_) {}
  }
  return null;
}
