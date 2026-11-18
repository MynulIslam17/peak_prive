import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_toast.dart';
import '../../../../../data/api/peak_api.dart';
import '../../controllers/listing_editor_controller.dart';
import 'editor_ui.dart';

/// Common lifecycle for the add/edit listing screens: reads the listing id
/// from the route, loads categories (+ the listing when editing), fills the
/// fields once, checks the form and saves.
abstract class ListingEditorState<W extends StatefulWidget> extends State<W> {
  ServiceKind get kind;

  /// Fill the fields from the saved listing (edit only, called once).
  void fill(ListingDetail detail);

  /// The form to send: everything on create, only changes on edit.
  ListingForm buildForm(ListingDetail? original);

  /// Screen-specific checks (shown before calling the server), or null.
  String? extraProblem() => null;

  late final String tag;
  late final ListingEditorController controller;
  bool _filled = false;

  bool get isEdit => controller.isEdit;

  @override
  void initState() {
    super.initState();
    final id = listingIdFromArgs(Get.arguments);
    tag = 'listing-editor-${kind.name}-${id ?? 'new'}-${identityHashCode(this)}';
    controller = Get.put(ListingEditorController(kind: kind, listingId: id), tag: tag);
    reload();
    // What an untouched new form sends, to tell later whether anything changed.
    if (!isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _blank = _snapshot(buildForm(null));
      });
    }
  }

  String? _blank;

  String _snapshot(ListingForm f) =>
      '${f.fields.entries.map((e) => '${e.key}=${e.value}').join('&')}|${f.files.length}';

  /// Anything typed or picked that isn't saved yet.
  bool get hasUnsavedChanges {
    try {
      if (isEdit) {
        final o = controller.original;
        return o != null && _filled && !buildForm(o).isEmpty;
      }
      return _blank != null && _snapshot(buildForm(null)) != _blank;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onBack(bool didPop) async {
    if (didPop || controller.isSaving) return;
    final leave = !hasUnsavedChanges || await _confirmDiscard();
    if (leave && mounted) Navigator.pop(context);
  }

  Future<bool> _confirmDiscard() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Discard changes?'),
        content: Text(isEdit ? 'Your changes to this listing are not saved.' : 'This new listing is not saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  Future<void> reload() async {
    await controller.load();
    if (!mounted) return;
    final o = controller.original;
    if (o != null && !_filled) {
      _filled = true;
      setState(() => fill(o));
    }
  }

  @override
  void dispose() {
    Get.delete<ListingEditorController>(tag: tag, force: true);
    super.dispose();
  }

  /// Problems with the current fields; on edit the photo may stay as is.
  /// The photo, title and other common fields come first (top of the
  /// screen), then the service's own checks (items, slots…).
  String? firstProblem() {
    final problems = buildForm(null).validateForCreate();
    if (isEdit && (controller.original?.thumbnail ?? '').isNotEmpty) {
      problems.remove('Add a photo.');
    }
    if (problems.contains('Add a photo.')) return 'Add a photo.';
    return problems.isNotEmpty ? problems.first : extraProblem();
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();
    final problem = firstProblem();
    if (problem != null) {
      AppToast.error(problem, title: 'Check the form');
      return;
    }
    final form = buildForm(controller.original);
    if (isEdit && form.isEmpty) {
      AppToast.info('Change something before saving.', title: 'No changes');
      return;
    }
    final ok = await controller.save(form);
    if (!mounted) return;
    if (ok) {
      AppToast.success(
        isEdit ? 'Your changes are live for guests.' : 'Guests can now book it.',
        title: isEdit ? 'Listing updated' : 'Listing created',
      );
      // The saved listing goes straight into "My services" (no reload).
      Navigator.pop(context, controller.saved ?? true);
    } else {
      AppToast.error(
        controller.saveError ?? 'Please try again.',
        title: isEdit ? "Couldn't save changes" : "Couldn't create listing",
      );
    }
  }

  /// Rebuilds on controller changes. Leaving with unsaved changes asks first
  /// (back arrow and system back).
  Widget observe(Widget Function(ListingEditorController c) builder) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => _onBack(didPop),
        child: GetBuilder<ListingEditorController>(tag: tag, builder: builder),
      );
}
