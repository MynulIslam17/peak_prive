import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/utils/json_helper.dart';

/// One place from OpenStreetMap, ready to show in a list.
class OsmPlace {
  const OsmPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Reads one Nominatim `search` / `reverse` result.
  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    // `display_name` is a long comma list ("Courchevel 1850, Saint-Bon-
    // Tarentaise, Albertville, Savoie, ..., 73120, France"). Postcodes and
    // house-number-only segments add nothing a reader needs, so they go.
    final parts = JsonHelper.getString(json['display_name'])
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && !RegExp(r'^[\d\s-]+$').hasMatch(p))
        .toList();
    final name =
        JsonHelper.getStringOrNull(json['name']) ??
        (parts.isNotEmpty ? parts.first : '');
    final rest = parts.where((p) => p != name).toList();
    return OsmPlace(
      name: name,
      // Everything in between is administrative detail nobody reads, so keep
      // the two levels closest to the place and the country.
      address: (rest.length <= 3 ? rest : [...rest.take(2), rest.last]).join(
        ', ',
      ),
      latitude: JsonHelper.getDouble(json['lat']),
      longitude: JsonHelper.getDouble(json['lon']),
    );
  }

  /// Headline, e.g. "Courchevel 1850".
  final String name;

  /// Line under the headline, e.g. "Savoie, France".
  final String address;

  final double latitude;
  final double longitude;

  /// The single line stored on a listing or booking.
  String get label => address.isEmpty ? name : '$name, $address';

  bool get isUsable => name.isNotEmpty || address.isNotEmpty;

  /// Same spot picked twice (tap on the map, then the matching result).
  bool isSameSpot(OsmPlace other) =>
      (latitude - other.latitude).abs() < 0.0001 &&
      (longitude - other.longitude).abs() < 0.0001;
}

/// Places found for a query, or why the search failed.
class PlaceResults {
  const PlaceResults.found(this.places) : error = null;
  const PlaceResults.failed(this.error) : places = const [];

  final List<OsmPlace> places;
  final String? error;

  bool get ok => error == null;
}

/// Place search and reverse geocoding through OpenStreetMap's free Nominatim
/// service.
///
/// Nominatim's usage policy allows one request per second from an app and
/// requires a User-Agent that identifies it, so every call queues behind
/// [_minInterval]. Callers should still debounce typing: the throttle delays
/// bursts, it does not drop them.
class PlaceSearch {
  PlaceSearch({http.Client? client, Duration? minInterval})
    : _http = client ?? http.Client(),
      _minInterval = minInterval ?? const Duration(milliseconds: 1100);

  /// Shared client. Tests replace it so the picker never calls the network.
  static PlaceSearch instance = PlaceSearch();

  static const _host = 'nominatim.openstreetmap.org';
  static const _headers = {
    'User-Agent': 'PeakPrivee/1.0 (com.peakprivee.serviceapp)',
    'Accept': 'application/json',
  };

  /// Package name sent with the map tiles, as the tile server's policy asks.
  static const tileUserAgent = 'com.peakprivee.serviceapp';

  final http.Client _http;
  final Duration _minInterval;
  Future<void> _queue = Future.value();
  DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);

  /// Places matching what the user typed, best match first.
  Future<PlaceResults> search(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.length < 2) return const PlaceResults.found([]);
    return _call(
      Uri.https(_host, '/search', {
        'q': q,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '$limit',
      }),
      (body) => PlaceResults.found(
        JsonHelper.mapList(
          body,
          OsmPlace.fromJson,
        ).where((p) => p.isUsable).toList(),
      ),
    );
  }

  /// The address of a point the user tapped on the map.
  Future<PlaceResults> at(double latitude, double longitude) => _call(
    Uri.https(_host, '/reverse', {
      'lat': '$latitude',
      'lon': '$longitude',
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '16',
    }),
    (body) {
      final json = JsonHelper.getMap(body);
      if (json == null) return const PlaceResults.failed(_noPlace);
      final place = OsmPlace.fromJson(json);
      return place.isUsable
          ? PlaceResults.found([place])
          : const PlaceResults.failed(_noPlace);
    },
  );

  static const _noPlace = 'No address here. Try a spot closer to a road.';
  static const _offline =
      'Could not reach the map service. Check your connection and try again.';

  Future<PlaceResults> _call(
    Uri url,
    PlaceResults Function(dynamic body) parse,
  ) async {
    try {
      final response = await _throttled(
        () => _http
            .get(url, headers: _headers)
            .timeout(const Duration(seconds: 15)),
      );
      if (response.statusCode == 429 || response.statusCode == 403) {
        return const PlaceResults.failed(
          'Too many searches at once. Wait a moment and try again.',
        );
      }
      if (response.statusCode != 200) {
        return const PlaceResults.failed(_offline);
      }
      return parse(jsonDecode(response.body));
    } on FormatException {
      return const PlaceResults.failed(_offline);
    } catch (_) {
      return const PlaceResults.failed(_offline);
    }
  }

  /// Runs [request] after every earlier one has finished and at least
  /// [_minInterval] has passed since the last call left.
  Future<T> _throttled<T>(Future<T> Function() request) async {
    final earlier = _queue;
    final mine = Completer<void>();
    _queue = mine.future;
    await earlier;
    final wait = _minInterval - DateTime.now().difference(_lastCall);
    if (wait > Duration.zero) await Future.delayed(wait);
    try {
      _lastCall = DateTime.now();
      return await request();
    } finally {
      _lastCall = DateTime.now();
      mine.complete();
    }
  }
}
