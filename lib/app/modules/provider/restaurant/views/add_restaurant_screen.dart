import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/location/location_picker.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/models/listing_drafts.dart';
import '../../shared/views/listing_editor/editor_base.dart';
import '../../shared/views/listing_editor/editor_ui.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

/// Add / edit a restaurant. Route args: `{'isEdit': true, 'id': id}`.
class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _SeatRow {
  _SeatRow(this.draft)
      : price = TextEditingController(text: draft.price),
        quantity = TextEditingController(text: draft.quantity),
        description = TextEditingController(text: draft.description);
  final SeatDraft draft;
  final TextEditingController price, quantity, description;

  SeatDraft collect() => draft
    ..price = price.text
    ..quantity = quantity.text
    ..description = description.text;

  void dispose() {
    price.dispose();
    quantity.dispose();
    description.dispose();
  }
}

class _AddRestaurantScreenState extends ListingEditorState<AddRestaurantScreen> {
  @override
  ServiceKind get kind => ServiceKind.restaurant;

  final _title = TextEditingController();
  final _area = TextEditingController();
  final _foodType = TextEditingController();
  final _description = TextEditingController();
  String? _categoryId;
  String? _categoryName;
  String? _openTime;
  String? _closeTime;
  File? _thumbnail;
  String? _thumbnailUrl;
  final List<_SeatRow> _seats = [_SeatRow(SeatDraft(type: 'Normal'))];
  final List<SlotDraft> _slots = [];

  // New slot being composed.
  String? _newStart;
  String? _newEnd;

  @override
  void fill(ListingDetail detail) {
    final d = RestaurantDraft.from(detail as RestaurantDetail);
    _title.text = d.title;
    _area.text = d.serviceArea;
    _foodType.text = d.foodType;
    _description.text = d.description;
    _categoryId = d.categoryId;
    _categoryName = detail.subCategory?.name;
    _openTime = d.openTime;
    _closeTime = d.closeTime;
    _thumbnailUrl = detail.thumbnail;
    for (final r in _seats) {
      r.dispose();
    }
    _seats
      ..clear()
      ..addAll(d.seats.map(_SeatRow.new));
    _slots
      ..clear()
      ..addAll(d.slots);
  }

  RestaurantDraft get _draft => RestaurantDraft(
        categoryId: _categoryId,
        title: _title.text,
        serviceArea: _area.text,
        openTime: _openTime,
        closeTime: _closeTime,
        foodType: _foodType.text,
        description: _description.text,
        seats: _seats.map((r) => r.collect()).toList(),
        slots: _slots,
        thumbnail: _thumbnail,
      );

  @override
  ListingForm buildForm(ListingDetail? original) => _draft.toForm(original as RestaurantDetail?);

  @override
  String? extraProblem() {
    for (final r in _seats) {
      if (parseAmount(r.price.text) == null) return '${r.draft.type} seats: enter a price.';
      if (parseCount(r.quantity.text) == null) return '${r.draft.type} seats: enter a whole number of seats.';
    }
    return _draft.slotProblem();
  }

  void _addSlot() {
    final s = _newStart, e = _newEnd;
    if (s == null || e == null) return;
    final problem = checkSlot(start: s, end: e, openTime: _openTime, closeTime: _closeTime);
    if (problem != null) {
      showAppToast(type: ToastType.warning, title: "Check the time slot", message: problem);
      return;
    }
    if (_slots.any((x) => x.startTime == s && x.endTime == e)) return;
    setState(() {
      _slots.add(SlotDraft(startTime: s, endTime: e));
      _newStart = null;
      _newEnd = null;
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _area, _foodType, _description]) {
      c.dispose();
    }
    for (final r in _seats) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missingType = seatTypes.where((t) => !_seats.any((s) => s.draft.type.toLowerCase() == t.toLowerCase())).toList();
    return observe((c) => EditorScaffold(
          title: isEdit ? 'Edit restaurant' : 'New restaurant',
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
                AppFormField(label: 'Restaurant name', controller: _title, hint: 'e.g. Le Chalet', icon: Icons.title_rounded),
                const SizedBox(height: 16),
                LocationFormField(label: 'Service area', controller: _area, hint: 'e.g. Courchevel'),
                const SizedBox(height: 16),
                AppFormField(label: 'Food type (optional)', controller: _foodType, hint: 'e.g. Savoyard'),
                const SizedBox(height: 16),
                AppFormField(label: 'Description (optional)', controller: _description, maxLines: 3, hint: 'Fondue and views…'),
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
              title: 'Seats',
              subtitle: 'One or two seat types, each with a price per seat',
              trailing: CountBadge(_seats.length),
              children: [
                for (var i = 0; i < _seats.length; i++) _seatCard(i),
                if (missingType.isNotEmpty && _seats.length < 2)
                  AddRowButton(
                    label: 'Add ${missingType.first} seats',
                    onPressed: () => setState(() => _seats.add(_SeatRow(SeatDraft(type: missingType.first)))),
                  ),
                if (isEdit)
                  const EditorNote('Changing the seat count keeps seats that are already booked.'),
              ],
            ),
            EditorSection(
              title: 'Time slots',
              subtitle: 'Up to 6 hours each, inside the opening hours',
              trailing: CountBadge(_slots.length),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in _slots)
                      InputChip(
                        label: Text(s.label),
                        onDeleted: () => setState(() => _slots.remove(s)),
                        deleteIconColor: AppColors.error,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        labelStyle: AppTextStyle.p_medium_12(color: AppColors.textPrimary),
                      ),
                  ],
                ),
                if (_slots.isNotEmpty) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ClockField(label: 'Starts', value: _newStart, onChanged: (v) => setState(() => _newStart = v))),
                    const SizedBox(width: 12),
                    Expanded(child: ClockField(label: 'Ends', value: _newEnd, onChanged: (v) => setState(() => _newEnd = v))),
                  ],
                ),
                const SizedBox(height: 12),
                AddRowButton(
                  label: 'Add slot',
                  onPressed: _newStart != null && _newEnd != null ? _addSlot : null,
                ),
              ],
            ),
          ],
        ));
  }

  Widget _seatCard(int i) {
    final r = _seats[i];
    return RowCard(
      label: '${r.draft.type == 'VIP' ? 'VIP' : r.draft.type} seats',
      onRemove: _seats.length > 1 ? () => setState(() => _seats.removeAt(i).dispose()) : null,
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
              child: AppFormField(label: 'Description (optional)', controller: r.description, hint: 'e.g. Window tables'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Price per seat',
                controller: r.price,
                hint: '0',
                prefixText: '€ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalInput,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Number of seats',
                controller: r.quantity,
                hint: '20',
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
