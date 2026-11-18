import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';

/// Loads (call [load]) what an add/edit listing screen needs (sub-categories, and the
/// listing itself when editing) and saves the form. One instance per screen;
/// the screens build the [ListingForm] from a draft
/// (see `models/listing_drafts.dart`).
class ListingEditorController extends GetxController {
  ListingEditorController({required this.kind, this.listingId});

  final ServiceKind kind;

  /// Set when editing.
  final String? listingId;

  ListingApi get _api => Get.find<PeakApi>().listings;

  bool get isEdit => (listingId ?? '').isNotEmpty;

  bool isLoading = false;
  String? loadError;

  /// The listing as saved (edit only).
  ListingDetail? original;

  List<CategoryOption> categories = const [];
  bool categoriesLoading = false;
  String? categoriesError;

  bool isSaving = false;
  String? saveError;

  /// The saved listing after a successful create/update.
  ListingDetail? saved;

  Future<void> load() async {
    isLoading = isEdit;
    loadError = null;
    update();
    await Future.wait([
      loadCategories(),
      if (isEdit) _loadListing(),
    ]);
    isLoading = false;
    update();
  }

  Future<void> _loadListing() async {
    final r = await _api.detail(kind, listingId!);
    if (r.isSuccess) {
      original = r.data;
    } else {
      loadError = r.errorMessage;
    }
  }

  Future<void> loadCategories() async {
    if (!kind.hasSubCategories) return;
    categoriesLoading = true;
    categoriesError = null;
    update();
    final r = await _api.categories(kind);
    if (r.isSuccess) {
      categories = r.data!;
      if (categories.isEmpty) categoriesError = 'No categories are set up yet.';
    } else {
      categoriesError = r.errorMessage;
    }
    categoriesLoading = false;
    update();
  }

  /// Creates or updates. On create, [ListingForm.validateForCreate] runs
  /// first and the first problem becomes [saveError]. An edit with nothing
  /// changed returns true without a call (nothing to save).
  Future<bool> save(ListingForm form) async {
    if (isSaving) return false;
    saveError = null;
    if (!isEdit) {
      final problems = form.validateForCreate();
      if (problems.isNotEmpty) {
        saveError = problems.first;
        update();
        return false;
      }
    } else if (form.isEmpty) {
      saved = original;
      return true;
    }
    isSaving = true;
    update();
    final r = isEdit ? await _api.update(listingId!, form) : await _api.create(form);
    isSaving = false;
    if (r.isSuccess) {
      saved = r.data;
      if (isEdit) original = r.data;
    } else {
      saveError = describeSaveFailure(r.failure!, kind, creating: !isEdit, form: form);
    }
    update();
    return r.isSuccess;
  }
}

/// Message for a failed create/update.
String describeSaveFailure(ApiFailure f, ServiceKind kind, {required bool creating, ListingForm? form}) {
  if (f.isForbidden) {
    return creating
        ? 'Only a ${kind.label.toLowerCase()} provider can add this.'
        : "You can't edit this listing.";
  }
  if (f.statusCode == 502 || f.statusCode == 503 || f.statusCode == 504) {
    return 'Upload failed, try again.';
  }
  if (f.isConflict) {
    final removing = form != null &&
        (form.fields.containsKey('removeItemIds') ||
            form.fields.containsKey('removeSeatIds') ||
            form.fields.containsKey('removeSlotIds'));
    if (removing) {
      return '${f.message} Keep it until its open bookings are finished.';
    }
    return f.message;
  }
  if (f.fieldErrors.isNotEmpty && f.fieldErrors.first.message.isNotEmpty) {
    final e = f.fieldErrors.first;
    return e.field.isEmpty ? e.message : '${_fieldLabel(e.field)}: ${e.message}';
  }
  return f.message;
}

String _fieldLabel(String field) {
  const labels = {
    'extraChargePerHour': 'Late fee',
    'serviceArea': 'Service area',
    'passType': 'Pass type',
    'priceUnit': 'Price unit',
    'insuranceFee': 'Insurance fee',
    'maintenanceFee': 'Maintenance fee',
    'openTime': 'Opening time',
    'closeTime': 'Closing time',
    'foodType': 'Food type',
  };
  final base = field.split(RegExp(r'[.\[]')).first;
  if (labels.containsKey(base)) return labels[base]!;
  return base.isEmpty ? field : base[0].toUpperCase() + base.substring(1);
}
