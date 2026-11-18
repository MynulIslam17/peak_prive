import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/location/location_picker.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/models/listing_drafts.dart';
import '../../shared/views/listing_editor/editor_base.dart';
import '../../shared/views/listing_editor/editor_ui.dart';

/// Add / edit a transport listing. Route args: `{'isEdit': true, 'id': id}`.
class AddTransportScreen extends StatefulWidget {
  const AddTransportScreen({super.key});

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends ListingEditorState<AddTransportScreen> {
  @override
  ServiceKind get kind => ServiceKind.transport;

  final _title = TextEditingController();
  final _area = TextEditingController();
  final _amount = TextEditingController();
  final _seats = TextEditingController();
  final _mileage = TextEditingController();
  final _power = TextEditingController();
  final _lateFee = TextEditingController();
  final _description = TextEditingController();
  String? _categoryId;
  String? _categoryName;
  File? _thumbnail;
  String? _thumbnailUrl;

  List<TextEditingController> get _all => [
        _title, _area, _amount, _seats, _mileage, _power, _lateFee, _description,
      ];

  @override
  void fill(ListingDetail detail) {
    final d = TransportDraft.from(detail as TransportDetail);
    _title.text = d.title;
    _area.text = d.serviceArea;
    _amount.text = d.amount;
    _seats.text = d.seats;
    _mileage.text = d.mileage;
    _power.text = d.power;
    _lateFee.text = d.lateFee;
    _description.text = d.description;
    _categoryId = d.categoryId;
    _categoryName = detail.subCategory?.name;
    _thumbnailUrl = detail.thumbnail;
  }

  @override
  ListingForm buildForm(ListingDetail? original) => TransportDraft(
        categoryId: _categoryId,
        title: _title.text,
        serviceArea: _area.text,
        amount: _amount.text,
        seats: _seats.text,
        mileage: _mileage.text,
        power: _power.text,
        lateFee: _lateFee.text,
        description: _description.text,
        thumbnail: _thumbnail,
      ).toForm(original as TransportDetail?);

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _money(String label, TextEditingController c, {String hint = '0'}) => AppFormField(
        label: label,
        controller: c,
        hint: hint,
        prefixText: '€ ',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: decimalInput,
      );

  @override
  Widget build(BuildContext context) {
    return observe((c) => EditorScaffold(
          title: isEdit ? 'Edit vehicle' : 'New transport listing',
          isLoading: c.isLoading,
          loadError: c.loadError,
          onRetry: reload,
          isEdit: isEdit,
          saving: c.isSaving,
          onSave: save,
          children: [
            EditorSection(
              title: 'Cover photo',
              subtitle: 'A clear photo of the vehicle',
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
                AppFormField(label: 'Title', controller: _title, hint: 'e.g. Mercedes V-Class', icon: Icons.title_rounded),
                const SizedBox(height: 16),
                LocationFormField(label: 'Service area', controller: _area, hint: 'e.g. Courchevel'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: 'Seats',
                        controller: _seats,
                        hint: '4',
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: digitsInput,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: AppFormField(label: 'Mileage', controller: _mileage, hint: 'e.g. 15 km/l')),
                  ],
                ),
                const SizedBox(height: 16),
                AppFormField(label: 'Power (optional)', controller: _power, hint: 'e.g. 190 hp'),
                const SizedBox(height: 16),
                AppFormField(label: 'Description (optional)', controller: _description, hint: 'Airport transfers, luggage…', maxLines: 3),
              ],
            ),
            EditorSection(
              title: 'Pricing',
              subtitle: 'The trip price is charged once per booking',
              children: [
                _money('Price per trip', _amount),
                const SizedBox(height: 16),
                _money('Late fee per hour', _lateFee),
                const EditorNote(
                  'Charged per started hour after a 15-minute grace, capped at the booking price. '
                  'Late fees only apply after you tap Hand over. Enter 0 for no fee.',
                ),
              ],
            ),
          ],
        ));
  }
}
