import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/location/place_search.dart';
import '../../constants/app_colors.dart';
import '../../constants/text-style.dart';
import '../app_form_field.dart';
import '../shimmer/skeleton.dart';

/// Tiles used instead of the live OpenStreetMap server. Production leaves this
/// null; tests set a provider that does not touch the network.
@visibleForTesting
TileProvider? debugLocationTileProvider;

/// Opens the OpenStreetMap place picker and returns the place the user chose,
/// or null if they backed out.
Future<OsmPlace?> showLocationPicker(
  BuildContext context, {
  String title = 'Choose a location',
  String hint = 'Search a town, resort, hotel or street',
  String confirmLabel = 'Use this location',
  String? initialQuery,
}) {
  return showModalBottomSheet<OsmPlace>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationPickerSheet(
      title: title,
      hint: hint,
      confirmLabel: confirmLabel,
      initialQuery: initialQuery,
    ),
  );
}

/// Map + search field + scrollable results, as a bottom sheet.
class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    this.initialQuery,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String? initialQuery;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  /// The French Alps: where this app's resorts are, so the first map view is
  /// somewhere the user recognises instead of the middle of the ocean.
  static const _defaultCenter = LatLng(45.6, 6.7);
  static const _defaultZoom = 7.0;
  static const _placeZoom = 14.0;

  final _query = TextEditingController();
  final _map = MapController();
  Timer? _debounce;

  /// Rises with every search so a slow earlier response cannot overwrite a
  /// newer one.
  int _request = 0;

  List<OsmPlace> _results = const [];
  OsmPlace? _selected;
  bool _loading = false;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim() ?? '';
    if (q.length >= 2) {
      _query.text = q;
      _search(q);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _map.dispose();
    super.dispose();
  }

  void _onTyped(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() {
        _request++;
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    // Wait for a pause in typing before showing the loading state, so a
    // rebuild here cannot drop the character the user just entered.
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search(String query) async {
    final ticket = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await PlaceSearch.instance.search(query);
    if (!mounted || ticket != _request) return;
    setState(() {
      _loading = false;
      _error = result.error;
      _results = result.places;
    });
  }

  void _select(OsmPlace place, {bool moveMap = true}) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selected = place);
    if (moveMap) {
      _map.move(LatLng(place.latitude, place.longitude), _placeZoom);
    }
  }

  /// Turns a tap on the map into an address.
  Future<void> _pickPoint(LatLng point) async {
    final ticket = ++_request;
    setState(() {
      _locating = true;
      _error = null;
      _selected = null;
    });
    final result = await PlaceSearch.instance.at(
      point.latitude,
      point.longitude,
    );
    if (!mounted || ticket != _request) return;
    setState(() {
      _locating = false;
      _error = result.error;
      _selected = result.places.isEmpty ? null : result.places.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final screen = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // Stay above the keyboard, and never taller than the screen allows.
    final height = (screen * 0.94 - keyboard).clamp(280.0, screen * 0.94);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SizedBox(
        height: height,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                height: 5,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 8, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyle.sub_h1_medium_18(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _query,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyle.sub_h3_regular_14(
                    color: AppColors.textPrimary,
                  ),
                  onChanged: _onTyped,
                  onSubmitted: (v) {
                    _debounce?.cancel();
                    if (v.trim().length >= 2) _search(v.trim());
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyle.sub_h3_regular_14(
                      color: AppColors.textDisabled,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: AppColors.textTertiary,
                            onPressed: () {
                              _query.clear();
                              _onTyped('');
                            },
                          ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: _searchBorder(AppColors.border),
                    enabledBorder: _searchBorder(AppColors.border),
                    focusedBorder: _searchBorder(AppColors.primary_1),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _MapPreview(
                  controller: _map,
                  center: selected == null
                      ? _defaultCenter
                      : LatLng(selected.latitude, selected.longitude),
                  zoom: selected == null ? _defaultZoom : _placeZoom,
                  marker: selected == null
                      ? null
                      : LatLng(selected.latitude, selected.longitude),
                  locating: _locating,
                  onTap: _pickPoint,
                ),
              ),
              Expanded(flex: 3, child: _results_()),
              _ConfirmBar(
                place: selected,
                label: widget.confirmLabel,
                onConfirm: selected == null
                    ? null
                    : () => Navigator.of(context).pop(selected),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _searchBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  Widget _results_() {
    if (_loading) return const _ResultsSkeleton();

    final error = _error;
    if (error != null) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        title: error,
        action: _query.text.trim().length < 2 ? null : 'Try again',
        onAction: () => _search(_query.text.trim()),
      );
    }

    if (_results.isEmpty) {
      final typed = _query.text.trim();
      return _Message(
        icon: typed.length < 2
            ? Icons.travel_explore_rounded
            : Icons.search_off_rounded,
        title: typed.length < 2
            ? 'Search for a place'
            : 'No places found for "$typed"',
        message: typed.length < 2
            ? 'Type a town, resort, hotel or street, or tap the map to drop a pin.'
            : 'Check the spelling, or tap the map to drop a pin instead.',
      );
    }

    final selected = _selected;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (_, i) {
        final place = _results[i];
        return _ResultRow(
          place: place,
          selected: selected != null && selected.isSameSpot(place),
          onTap: () => _select(place),
        );
      },
    );
  }
}

/// OpenStreetMap tiles with the picked pin on top.
class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.controller,
    required this.center,
    required this.zoom,
    required this.marker,
    required this.locating,
    required this.onTap,
  });

  final MapController controller;
  final LatLng center;
  final double zoom;
  final LatLng? marker;
  final bool locating;
  final ValueChanged<LatLng> onTap;

  @override
  Widget build(BuildContext context) {
    final pin = marker;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController: controller,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: zoom,
                  minZoom: 3,
                  maxZoom: 18,
                  onTap: (_, point) => onTap(point),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: PlaceSearch.tileUserAgent,
                    tileProvider: debugLocationTileProvider,
                    maxNativeZoom: 19,
                  ),
                  if (pin != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pin,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: AppColors.primary_1,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        '© OpenStreetMap',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (locating)
                Positioned(
                  left: 8,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary_1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Finding address…',
                            style: AppTextStyle.p_regular_12(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final OsmPlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.primary_3.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.place_outlined,
                size: 19,
                color: AppColors.goldDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.sub_h3_medium_14(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (place.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      place.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.p_regular_12(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              size: selected ? 22 : 20,
              color: selected ? AppColors.primary_1 : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              SkeletonBox(height: 36, circle: true),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 170, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 220, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 34, color: AppColors.textDisabled),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.sub_h3_medium_14(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.p_regular_12(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        action!,
                        style: AppTextStyle.sub_h3_medium_14(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows what is picked and confirms it.
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.place,
    required this.label,
    required this.onConfirm,
  });

  final OsmPlace? place;
  final String label;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place?.label ?? 'Pick a result or tap the map',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: place == null
                    ? AppTextStyle.p_regular_12(color: AppColors.textTertiary)
                    : AppTextStyle.sub_h3_medium_14(
                        color: AppColors.textPrimary,
                      ),
              ),
              const SizedBox(height: 10),
              AppPrimaryButton(
                label: label,
                onPressed: onConfirm,
                icon: Icons.place_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled location field for provider and account forms: looks like
/// [AppFormField], but opens the map picker instead of the keyboard.
class LocationFormField extends StatelessWidget {
  const LocationFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.enabled = true,
    this.sheetTitle,
    this.onPicked,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final bool enabled;
  final String? sheetTitle;
  final ValueChanged<OsmPlace>? onPicked;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: label,
      controller: controller,
      hint: hint,
      helper: helper,
      icon: Icons.location_on_outlined,
      readOnly: true,
      maxLines: 2,
      onTap: !enabled
          ? null
          : () => pickInto(
              context,
              controller: controller,
              title: sheetTitle ?? label,
              onPicked: onPicked,
            ),
      suffix: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.map_outlined,
          size: 20,
          color: enabled ? AppColors.primary_1 : AppColors.textDisabled,
        ),
      ),
    );
  }
}

/// Location field shaped like the checkout text fields: pass the same
/// [decoration] the typed fields use so the card stays consistent.
class LocationPickerField extends StatelessWidget {
  const LocationPickerField({
    super.key,
    required this.controller,
    required this.decoration,
    required this.sheetTitle,
    this.enabled = true,
    this.maxLines = 2,
    this.onPicked,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final String sheetTitle;
  final bool enabled;
  final int maxLines;
  final ValueChanged<OsmPlace>? onPicked;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      // Tapping opens the picker; a keyboard here would invite free text that
      // cannot be placed on the map.
      readOnly: true,
      showCursor: false,
      minLines: 1,
      maxLines: maxLines,
      style: AppTextStyle.sub_h3_regular_14(color: AppColors.textPrimary),
      onTap: () => pickInto(
        context,
        controller: controller,
        title: sheetTitle,
        onPicked: onPicked,
      ),
      decoration: decoration.copyWith(
        suffixIcon: Icon(
          Icons.map_outlined,
          size: 20,
          color: enabled ? AppColors.primary_1 : AppColors.textDisabled,
        ),
      ),
    );
  }
}

/// Opens the picker and writes the chosen place into [controller].
Future<void> pickInto(
  BuildContext context, {
  required TextEditingController controller,
  required String title,
  ValueChanged<OsmPlace>? onPicked,
}) async {
  final place = await showLocationPicker(
    context,
    title: title,
    initialQuery: controller.text,
  );
  if (place == null) return;
  controller.text = place.label;
  onPicked?.call(place);
}
