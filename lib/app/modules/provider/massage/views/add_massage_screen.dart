import '../../../../core/widgets/checkout_parts.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/models/listing_drafts.dart';
import '../../shared/views/listing_editor/editor_base.dart';
import '../../shared/views/listing_editor/editor_ui.dart';

/// Add / edit a massage listing. Route args: `{'isEdit': true, 'id': id}`.
class AddMassageScreen extends StatefulWidget {
  const AddMassageScreen({super.key});

  @override
  State<AddMassageScreen> createState() => _AddMassageScreenState();
}

/// Session lengths offered in the picker (minutes).
const massageLengths = [15, 30, 45, 60, 75, 90, 105, 120, 150, 180, 240];

class _DurationRow {
  _DurationRow(this.draft) : price = TextEditingController(text: draft.price);
  final DurationDraft draft;
  final TextEditingController price;

  DurationDraft collect() => draft..price = price.text;
}

class _AddMassageScreenState extends ListingEditorState<AddMassageScreen> {
  @override
  ServiceKind get kind => ServiceKind.massage;

  final _title = TextEditingController();
  final _area = TextEditingController();
  final _benefits = TextEditingController();
  final _recommendations = TextEditingController();
  final _description = TextEditingController();
  String? _categoryId;
  String? _categoryName;
  String? _openTime;
  String? _closeTime;
  File? _thumbnail;
  String? _thumbnailUrl;
  int _capacity = 1;
  final List<_DurationRow> _durations = [_DurationRow(DurationDraft(minutes: 60))];

  @override
  void fill(ListingDetail detail) {
    final d = MassageDraft.from(detail as MassageDetail);
    _title.text = d.title;
    _area.text = d.serviceArea;
    _benefits.text = d.benefits;
    _recommendations.text = d.recommendations;
    _description.text = d.description;
    _categoryId = d.categoryId;
    _categoryName = detail.subCategory?.name;
    _openTime = d.openTime;
    _closeTime = d.closeTime;
    _capacity = d.capacity;
    _thumbnailUrl = detail.thumbnail;
    for (final r in _durations) {
      r.price.dispose();
    }
    _durations
      ..clear()
      ..addAll(d.durations.map(_DurationRow.new));
  }

  @override
  ListingForm buildForm(ListingDetail? original) => MassageDraft(
        categoryId: _categoryId,
        title: _title.text,
        openTime: _openTime,
        closeTime: _closeTime,
        durations: _durations.map((r) => r.collect()).toList(),
        serviceArea: _area.text,
        benefits: _benefits.text,
        recommendations: _recommendations.text,
        description: _description.text,
        thumbnail: _thumbnail,
        capacity: _capacity,
      ).toForm(original as MassageDetail?);

  @override
  String? extraProblem() {
    for (var i = 0; i < _durations.length; i++) {
      final r = _durations[i];
      if (r.draft.duration.isEmpty) return 'Option ${i + 1}: choose a length.';
      if (parseAmount(r.price.text) == null) return 'Option ${i + 1}: enter a price.';
    }
    return null;
  }

  @override
  void dispose() {
    for (final c in [_title, _area, _benefits, _recommendations, _description]) {
      c.dispose();
    }
    for (final r in _durations) {
      r.price.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return observe((c) => EditorScaffold(
          title: isEdit ? 'Edit massage' : 'New massage listing',
          isLoading: c.isLoading,
          loadError: c.loadError,
          onRetry: reload,
          isEdit: isEdit,
          saving: c.isSaving,
          onSave: save,
          children: [
            EditorSection(
              title: 'Cover photo',
              subtitle: 'The first thing guests see',
              children: [
                CoverPhotoPicker(
                  file: _thumbnail,
                  url: _thumbnailUrl,
                  onTap: () async {
                    final f = await pickPhoto(context);
                    if (f != null) setState(() => _thumbnail = f);
                  },
                ),
              ],
            ),
            EditorSection(
              title: 'Details',
              children: [
                const FieldLabel('Category'),
                CategoryPicker(
                  options: c.categories,
                  selectedId: _categoryId,
                  fallbackName: _categoryName,
                  loading: c.categoriesLoading,
                  error: c.categoriesError,
                  onRetry: c.loadCategories,
                  onSelected: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 16),
                AppFormField(label: 'Title', controller: _title, hint: 'e.g. Deep tissue', icon: Icons.title_rounded),
                const SizedBox(height: 16),
                AppFormField(label: 'Service area', controller: _area, hint: 'e.g. Chamonix', icon: Icons.location_on_outlined),
                const SizedBox(height: 16),
                AppFormField(label: 'Description (optional)', controller: _description, maxLines: 3, hint: 'About the session'),
              ],
            ),
            EditorSection(
              title: 'Opening hours',
              subtitle: 'Resort time. Closing after midnight is fine.',
              children: [
                Row(
                  children: [
                    Expanded(child: ClockField(label: 'Opens', value: _openTime, onChanged: (v) => setState(() => _openTime = v))),
                    const SizedBox(width: 12),
                    Expanded(child: ClockField(label: 'Closes', value: _closeTime, onChanged: (v) => setState(() => _closeTime = v))),
                  ],
                ),
              ],
            ),
            EditorSection(
              title: 'Guests at the same time',
              subtitle: 'How many guests you can treat at once: your number of therapists. '
                  'A time is full when this many guests are booked.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _capacity == 1 ? '1 guest (1 therapist)' : '$_capacity guests ($_capacity therapists)',
                        style: AppTextStyle.sub_h3_medium_14(),
                      ),
                    ),
                    CheckoutQuantityStepper(
                      value: _capacity,
                      min: 1,
                      max: 50,
                      unit: 'guests',
                      onChanged: (v) => setState(() => _capacity = v),
                    ),
                  ],
                ),
              ],
            ),
            EditorSection(
              title: 'Lengths and prices',
              subtitle: 'Guests pick one when booking',
              trailing: CountBadge(_durations.length),
              children: [
                for (var i = 0; i < _durations.length; i++) _durationCard(i),
                AddRowButton(
                  label: 'Add another length',
                  onPressed: _durations.length >= 20
                      ? null
                      : () => setState(() => _durations.add(_DurationRow(DurationDraft()))),
                ),
              ],
            ),
            EditorSection(
              title: 'For guests',
              children: [
                AppFormField(label: 'Benefits', controller: _benefits, maxLines: 3, hint: 'e.g. Relaxes muscles'),
                const SizedBox(height: 16),
                AppFormField(label: 'Our recommendations', controller: _recommendations, maxLines: 3, hint: 'e.g. Drink water afterwards'),
              ],
            ),
          ],
        ));
  }

  Widget _durationCard(int i) {
    final r = _durations[i];
    final used = {
      for (var j = 0; j < _durations.length; j++)
        if (j != i && _durations[j].draft.minutes != null) _durations[j].draft.minutes!,
    };
    final options = [
      for (final m in massageLengths)
        if (!used.contains(m) || m == r.draft.minutes) m,
      if (r.draft.minutes != null && !massageLengths.contains(r.draft.minutes)) r.draft.minutes!,
    ]..sort();
    return RowCard(
      label: 'Option ${i + 1}',
      onRemove: _durations.length > 1
          ? () => setState(() => _durations.removeAt(i).price.dispose())
          : null,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Length', style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: r.draft.minutes,
                    isExpanded: true,
                    hint: Text(r.draft.minutes == null && r.draft.raw.isNotEmpty ? r.draft.raw : 'Choose'),
                    items: [
                      for (final m in options)
                        DropdownMenuItem(value: m, child: Text(DurationDraft(minutes: m).label)),
                    ],
                    onChanged: (m) => setState(() => r.draft.minutes = m),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Price',
                controller: r.price,
                hint: '0',
                prefixText: '€ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalInput,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
