import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/location/location_picker.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/models/listing_drafts.dart';
import '../../shared/views/listing_editor/editor_base.dart';
import '../../shared/views/listing_editor/editor_ui.dart';

/// Add / edit a ski hire listing. Route args: `{'isEdit': true, 'id': id}`.
class AddHireScreen extends StatefulWidget {
  const AddHireScreen({super.key});

  @override
  State<AddHireScreen> createState() => _AddHireScreenState();
}

class _ItemRow {
  _ItemRow(this.draft)
      : name = TextEditingController(text: draft.name),
        price = TextEditingController(text: draft.price),
        quantity = TextEditingController(text: draft.quantity);

  final HireItemDraft draft;
  final TextEditingController name, price, quantity;

  HireItemDraft collect() => draft
    ..name = name.text
    ..price = price.text
    ..quantity = quantity.text;

  void dispose() {
    name.dispose();
    price.dispose();
    quantity.dispose();
  }
}

class _AddHireScreenState extends ListingEditorState<AddHireScreen> {
  @override
  ServiceKind get kind => ServiceKind.skiHire;

  final _title = TextEditingController();
  final _area = TextEditingController();
  final _description = TextEditingController();
  final _lateFee = TextEditingController();
  String? _categoryId;
  String? _categoryName;
  String _priceUnit = 'per_day';
  File? _thumbnail;
  String? _thumbnailUrl;
  final List<_ItemRow> _items = [_ItemRow(HireItemDraft())];

  @override
  void fill(ListingDetail detail) {
    final d = SkiHireDraft.from(detail as SkiHireDetail);
    _title.text = d.title;
    _area.text = d.serviceArea;
    _description.text = d.description;
    _lateFee.text = d.lateFee;
    _categoryId = d.categoryId;
    _categoryName = detail.subCategory?.name;
    _priceUnit = d.priceUnit;
    _thumbnailUrl = detail.thumbnail;
    for (final r in _items) {
      r.dispose();
    }
    _items
      ..clear()
      ..addAll(d.items.map(_ItemRow.new));
  }

  SkiHireDraft get _draft => SkiHireDraft(
        categoryId: _categoryId,
        title: _title.text,
        serviceArea: _area.text,
        description: _description.text,
        priceUnit: _priceUnit,
        lateFee: _lateFee.text,
        items: _items.map((r) => r.collect()).toList(),
        thumbnail: _thumbnail,
      );

  @override
  ListingForm buildForm(ListingDetail? original) => _draft.toForm(original as SkiHireDetail?);

  @override
  String? extraProblem() {
    final fee = _lateFee.text.trim();
    if (fee.isNotEmpty && (parseAmount(fee) == null || parseAmount(fee)! < 0)) {
      return 'Enter the late fee as a number (0 or more).';
    }
    for (var i = 0; i < _items.length; i++) {
      final r = _items[i];
      if (parseAmount(r.price.text) == null) return 'Item ${i + 1}: enter a price.';
      if (parseCount(r.quantity.text) == null) return 'Item ${i + 1}: enter a whole quantity.';
    }
    return null;
  }

  @override
  void dispose() {
    for (final c in [_title, _area, _description, _lateFee]) {
      c.dispose();
    }
    for (final r in _items) {
      r.dispose();
    }
    super.dispose();
  }

  String get _unitWord => switch (_priceUnit) {
        'per_hour' => 'hour',
        'per_rental' => 'rental',
        _ => 'day',
      };

  @override
  Widget build(BuildContext context) {
    return observe((c) => EditorScaffold(
          title: isEdit ? 'Edit listing' : 'New ski hire listing',
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
                AppFormField(
                  label: 'Listing title',
                  controller: _title,
                  hint: 'e.g. Premium ski set',
                  icon: Icons.title_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                LocationFormField(
                  label: 'Pick-up location',
                  controller: _area,
                  hint: 'Resort, shop or address',
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Description (optional)',
                  controller: _description,
                  hint: 'What is included, sizes, brands…',
                  maxLines: 3,
                ),
              ],
            ),
            EditorSection(
              title: 'Pricing',
              subtitle: 'What one item price pays for',
              children: [
                ChoiceChips<String>(
                  values: hirePriceUnits,
                  labelOf: (u) => switch (u) {
                    'per_hour' => 'Per hour',
                    'per_rental' => 'Per rental',
                    _ => 'Per day',
                  },
                  selected: _priceUnit,
                  onSelected: (u) => setState(() => _priceUnit = u),
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Late fee per hour',
                  controller: _lateFee,
                  hint: '0',
                  prefixText: '€ ',
                  icon: Icons.more_time_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInput,
                ),
                const EditorNote(
                  'Charged per started hour after a 15-minute grace, capped at the booking price. '
                  'Late fees only apply after you tap Hand over.',
                ),
              ],
            ),
            EditorSection(
              title: 'Equipment',
              subtitle: 'What guests can rent from this listing',
              trailing: CountBadge(_items.length),
              children: [
                for (var i = 0; i < _items.length; i++) _itemCard(i),
                AddRowButton(
                  label: 'Add another item',
                  onPressed: () => setState(() => _items.add(_ItemRow(HireItemDraft()))),
                ),
                if (isEdit)
                  const EditorNote(
                    'Changing a quantity keeps units that are already booked. '
                    'An item with open bookings can’t be removed.',
                  ),
              ],
            ),
          ],
        ));
  }

  Widget _itemCard(int i) {
    final r = _items[i];
    return RowCard(
      label: r.draft.id == null ? 'New item' : 'Item ${i + 1}',
      onRemove: _items.length > 1
          ? () => setState(() {
                _items.removeAt(i).dispose();
              })
          : null,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SmallPhotoPicker(
              file: r.draft.photo,
              url: r.draft.photoUrl,
              onTap: () async {
                final f = await pickPhoto(context);
                if (f != null) setState(() => r.draft.photo = f);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Item name',
                controller: r.name,
                hint: 'e.g. Skis, Helmet',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Price per $_unitWord',
                controller: r.price,
                hint: '0',
                prefixText: '€ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalInput,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'In stock',
                controller: r.quantity,
                hint: '10',
                keyboardType: TextInputType.number,
                inputFormatters: digitsInput,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
