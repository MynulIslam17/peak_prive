import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_form_field.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/models/listing_drafts.dart';
import '../../shared/views/listing_editor/editor_base.dart';
import '../../shared/views/listing_editor/editor_ui.dart';

/// Add / edit a ski pass. Route args: `{'isEdit': true, 'id': id}`.
class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _ServiceRow {
  _ServiceRow([PassService? s])
      : title = TextEditingController(text: s?.title ?? ''),
        description = TextEditingController(text: s?.description ?? '');
  final TextEditingController title, description;

  PassService collect() => PassService(title: title.text, description: description.text);

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class _AddPassScreenState extends ListingEditorState<AddPassScreen> {
  @override
  ServiceKind get kind => ServiceKind.skiPass;

  final _title = TextEditingController();
  final _price = TextEditingController();
  final _area = TextEditingController();
  final _description = TextEditingController();
  PassType? _passType;
  File? _thumbnail;
  String? _thumbnailUrl;
  final List<_ServiceRow> _services = [_ServiceRow()];

  @override
  void fill(ListingDetail detail) {
    final d = SkiPassDraft.from(detail as SkiPassDetail);
    _title.text = d.title;
    _price.text = d.price;
    _area.text = d.serviceArea;
    _description.text = d.description;
    _passType = d.passType;
    _thumbnailUrl = detail.thumbnail;
    for (final r in _services) {
      r.dispose();
    }
    _services
      ..clear()
      ..addAll(d.services.isEmpty ? [_ServiceRow()] : d.services.map(_ServiceRow.new));
  }

  @override
  ListingForm buildForm(ListingDetail? original) => SkiPassDraft(
        title: _title.text,
        passType: _passType,
        price: _price.text,
        services: _services.map((r) => r.collect()).toList(),
        serviceArea: _area.text,
        description: _description.text,
        thumbnail: _thumbnail,
      ).toForm(original as SkiPassDetail?);

  @override
  String? extraProblem() {
    if (_services.any((r) => r.title.text.trim().isEmpty && r.description.text.trim().isNotEmpty)) {
      return 'Every service needs a title.';
    }
    return null;
  }

  @override
  void dispose() {
    for (final c in [_title, _price, _area, _description]) {
      c.dispose();
    }
    for (final r in _services) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return observe((c) => EditorScaffold(
          title: isEdit ? 'Edit ski pass' : 'New ski pass',
          isLoading: c.isLoading,
          loadError: c.loadError,
          onRetry: reload,
          isEdit: isEdit,
          saving: c.isSaving,
          onSave: save,
          children: [
            EditorSection(
              title: 'Cover photo',
              subtitle: 'Clear photos help guests trust your pass',
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
                AppFormField(
                  label: 'Title',
                  controller: _title,
                  hint: 'e.g. Day pass',
                  icon: Icons.title_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Pass type'),
                ChoiceChips<PassType>(
                  values: PassType.values,
                  labelOf: (t) => t.label,
                  selected: _passType,
                  onSelected: (t) => setState(() => _passType = t),
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Price per person',
                  controller: _price,
                  hint: '0',
                  prefixText: '€ ',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInput,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Resort / area',
                  controller: _area,
                  hint: 'e.g. Courchevel',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'Description',
                  controller: _description,
                  hint: 'What the pass gives access to',
                  maxLines: 4,
                ),
              ],
            ),
            EditorSection(
              title: 'Included services',
              subtitle: 'At least one, e.g. "Free parking · 3 cars"',
              trailing: CountBadge(_services.length),
              children: [
                for (var i = 0; i < _services.length; i++)
                  RowCard(
                    label: 'Service ${i + 1}',
                    onRemove: _services.length > 1
                        ? () => setState(() => _services.removeAt(i).dispose())
                        : null,
                    children: [
                      AppFormField(label: 'Title', controller: _services[i].title, hint: 'e.g. Free parking'),
                      const SizedBox(height: 12),
                      AppFormField(label: 'Details', controller: _services[i].description, hint: 'e.g. 3 cars'),
                    ],
                  ),
                AddRowButton(
                  label: 'Add another service',
                  onPressed: () => setState(() => _services.add(_ServiceRow())),
                ),
              ],
            ),
          ],
        ));
  }
}
