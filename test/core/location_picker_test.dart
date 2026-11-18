import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/widgets/checkout_flow_parts.dart';
import 'package:harry_service_app/app/core/widgets/location/location_picker.dart';
import 'package:harry_service_app/app/data/services/location/place_search.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A 1×1 png, so map tiles resolve without a network call.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

class _BlankTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_pixel);
}

/// Answers Nominatim without reading the request body. [MockClient] waits on
/// that body, and the wait never finishes under the widget-test clock.
class _PlacesClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final query = request.url.queryParameters['q'] ?? '';
    final Object body = request.url.path == '/reverse'
        ? _courchevel
        : query.toLowerCase().contains('courchevel')
        ? [_courchevel]
        : const [];
    request.finalize();
    return Future<http.StreamedResponse>.value(
      http.StreamedResponse(
        Stream<List<int>>.fromIterable([utf8.encode(jsonEncode(body))]),
        200,
        headers: const {'content-type': 'application/json'},
      ),
    );
  }
}

const _courchevel = {
  'name': 'Courchevel 1850',
  'display_name':
      'Courchevel 1850, Saint-Bon-Tarentaise, Albertville, Savoie, Auvergne-Rhône-Alpes, France métropolitaine, 73120, France',
  'lat': '45.415',
  'lon': '6.634',
};

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, __) => GetMaterialApp(home: Scaffold(body: child)),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('OsmPlace', () {
    test('keeps the place, the two nearest areas and the country', () {
      final place = OsmPlace.fromJson(_courchevel);

      expect(place.name, 'Courchevel 1850');
      expect(place.address, 'Saint-Bon-Tarentaise, Albertville, France');
      expect(place.latitude, 45.415);
      expect(place.longitude, 6.634);
      expect(
        place.label,
        'Courchevel 1850, Saint-Bon-Tarentaise, Albertville, France',
      );
    });

    test(
      'keeps a short address whole and treats a blank result as unusable',
      () {
        final hotel = OsmPlace.fromJson({
          'name': 'Hotel Alpina',
          'display_name': 'Hotel Alpina, Chamonix, France',
          'lat': 45.9,
          'lon': 6.8,
        });
        expect(hotel.label, 'Hotel Alpina, Chamonix, France');

        final blank = OsmPlace.fromJson({
          'display_name': '',
          'lat': '0',
          'lon': '0',
        });
        expect(blank.isUsable, isFalse);
      },
    );

    test('two picks of the same spot match', () {
      final a = OsmPlace.fromJson(_courchevel);
      final nudged = OsmPlace(
        name: 'pin',
        address: '',
        latitude: a.latitude + 0.00005,
        longitude: a.longitude,
      );
      final elsewhere = OsmPlace(
        name: 'pin',
        address: '',
        latitude: a.latitude + 0.01,
        longitude: a.longitude,
      );

      expect(a.isSameSpot(nudged), isTrue);
      expect(a.isSameSpot(elsewhere), isFalse);
    });
  });

  group('PlaceSearch', () {
    test('a one-character query never reaches the network', () async {
      var calls = 0;
      final search = PlaceSearch(
        client: MockClient((_) async {
          calls++;
          return _json(const []);
        }),
        minInterval: Duration.zero,
      );

      final result = await search.search('  a ');

      expect(result.ok, isTrue);
      expect(result.places, isEmpty);
      expect(calls, 0);
    });

    test('search sends the query to Nominatim and reads the places', () async {
      final search = PlaceSearch(
        client: MockClient((request) async {
          expect(request.url.host, 'nominatim.openstreetmap.org');
          expect(request.url.path, '/search');
          expect(request.url.queryParameters['q'], 'Courchevel');
          expect(request.headers['user-agent'], contains('PeakPrivee'));
          return _json([
            _courchevel,
            {'display_name': '', 'lat': '0', 'lon': '0'},
          ]);
        }),
        minInterval: Duration.zero,
      );

      final result = await search.search('Courchevel');

      expect(result.ok, isTrue);
      expect(result.places, hasLength(1));
      expect(result.places.single.name, 'Courchevel 1850');
    });

    test('reverse geocoding reads the address of a tapped point', () async {
      final search = PlaceSearch(
        client: MockClient((request) async {
          expect(request.url.path, '/reverse');
          expect(request.url.queryParameters['lat'], '45.4');
          expect(request.url.queryParameters['lon'], '6.6');
          return _json(_courchevel);
        }),
        minInterval: Duration.zero,
      );

      final result = await search.at(45.4, 6.6);

      expect(result.places.single.label, contains('Courchevel 1850'));
    });

    test(
      'a rate limit and a broken response become errors, not throws',
      () async {
        PlaceSearch clientFor(http.Response response) => PlaceSearch(
          client: MockClient((_) async => response),
          minInterval: Duration.zero,
        );

        final blocked = await clientFor(
          _json('slow down', 429),
        ).search('Courchevel');
        final broken = await clientFor(http.Response('not json', 200)).at(1, 2);

        expect(blocked.ok, isFalse);
        expect(blocked.error, contains('Too many'));
        expect(broken.ok, isFalse);
        expect(broken.places, isEmpty);
      },
    );

    test('calls leave at least the minimum gap between them', () async {
      final started = <DateTime>[];
      final search = PlaceSearch(
        client: MockClient((_) async {
          started.add(DateTime.now());
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return _json(const []);
        }),
        minInterval: const Duration(milliseconds: 180),
      );

      await Future.wait([search.search('aa'), search.search('bb')]);

      expect(started, hasLength(2));
      expect(
        started[1].difference(started[0]),
        greaterThanOrEqualTo(const Duration(milliseconds: 180)),
      );
    });
  });

  group('location fields', () {
    late PlaceSearch real;

    setUp(() {
      Get.testMode = true;
      real = PlaceSearch.instance;
      PlaceSearch.instance = PlaceSearch(
        client: _PlacesClient(),
        minInterval: Duration.zero,
      );
      debugLocationTileProvider = _BlankTiles();
    });

    tearDown(() {
      PlaceSearch.instance = real;
      debugLocationTileProvider = null;
      Get.reset();
    });

    testWidgets(
      'checkout address and destination open the map instead of the keyboard',
      (tester) async {
        final contact = CheckoutContact();
        addTearDown(contact.dispose);

        await tester.pumpWidget(
          _host(
            CheckoutContactCard(
              contact: contact,
              enabled: true,
              onChanged: () {},
              showAddress: true,
              showDestination: true,
            ),
          ),
        );
        await tester.pump();

        final picked = tester
            .widgetList<TextField>(find.byType(TextField))
            .where(
              (field) => field.readOnly && field.decoration?.suffixIcon is Icon,
            )
            .toList();
        expect(picked, hasLength(2));
        expect(
          (picked.first.decoration!.suffixIcon! as Icon).icon,
          Icons.map_outlined,
        );
      },
    );

    testWidgets(
      'a location field opens the map and stays empty until a place is confirmed',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _host(
            LocationFormField(
              label: 'Service area',
              controller: controller,
              sheetTitle: 'Choose area',
            ),
          ),
        );
        await tester.pump();

        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          ),
        );
        expect(field.readOnly, isTrue);

        await tester.tap(find.byType(TextFormField));
        await tester.pump();
        await tester.pump();

        expect(find.text('Choose area'), findsOneWidget);
        expect(find.text('Search for a place'), findsOneWidget);
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Use this location'),
              )
              .onPressed,
          isNull,
        );
        expect(find.text('© OpenStreetMap'), findsOneWidget);

        final close = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.close_rounded),
        );
        close.onPressed!();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(controller.text, isEmpty);
        expect(find.text('Choose area'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });
}
