import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/stripe/checkout_controller.dart';
import 'package:harry_service_app/app/data/services/stripe/payment_sheet.dart';
import 'package:harry_service_app/app/modules/user/hire/views/hire_checkout_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurant_checkout_screen.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_checkout_screen.dart';
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

class NeverSheet implements PaymentSheet {
  @override
  Future<SheetOutcome> present({required String publishableKey, required String clientSecret}) async =>
      const SheetOutcome(SheetStatus.canceled);
}

/// Tall screen so the whole ListView is built.
void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 5000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget host(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => GetMaterialApp(home: Scaffold(body: child)),
    );

void main() {
  setUpAll(() {
    Logger.level = Level.off;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('hire: pre-selected quantities are capped by stock', (tester) async {
    tallScreen(tester);
    registerHarness(Harness((_) => json({'success': true, 'data': {}})));
    final hire = ListingDetail.fromJson(fixtureData('hire_detail')) as SkiHireDetail; // aaa: 44 in stock
    await tester.pumpWidget(host(HireCheckoutForm(
      hire: hire,
      initialQuantities: const {'6939508f6fd3cd7f26c29699': 99, 'ghost': 3},
      checkout: CheckoutController(sheet: NeverSheet()),
    )));
    await tester.pump();
    expect(find.text('44'), findsOneWidget); // stepper value capped to stock
    expect(find.text('aaa × 44'), findsOneWidget);
    expect(find.text('Choose dates'), findsOneWidget); // no period yet
  });

  testWidgets('hire: pay without dates shows errors and calls nothing', (tester) async {
    tallScreen(tester);
    final h = Harness((_) => json({'success': true, 'data': {}}));
    registerHarness(h);
    final hire = ListingDetail.fromJson(fixtureData('hire_detail')) as SkiHireDetail;
    await tester.pumpWidget(host(HireCheckoutForm(hire: hire, checkout: CheckoutController(sheet: NeverSheet()))));
    await tester.pump();
    await tester.tap(find.text('Choose dates'));
    await tester.pump();
    expect(find.text('Please choose a pick-up time'), findsOneWidget);
    expect(find.text('Please choose a return time'), findsOneWidget);
    expect(h.requests, isEmpty);
  });

  testWidgets('restaurant: past and full slots are disabled; seats capped per slot', (tester) async {
    tallScreen(tester);
    final avail = fixture('rest_avail');
    final data = Map<String, dynamic>.from(avail['data'] as Map);
    final slots = (data['slots'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    slots[0]['isPast'] = true; // 8:00 AM – 10:30 PM
    slots[1]['seats'] = [
      {'itemId': '69ce460f50976c8d2c921f98', 'type': 'VIP', 'price': 44, 'available': 0},
      {'itemId': '69ce460f50976c8d2c921f99', 'type': 'Normal', 'price': 200, 'available': 0},
    ];
    slots[2]['seats'] = [
      {'itemId': '69ce460f50976c8d2c921f98', 'type': 'VIP', 'price': 44, 'available': 2},
      {'itemId': '69ce460f50976c8d2c921f99', 'type': 'Normal', 'price': 200, 'available': 0},
    ];
    data['slots'] = slots;
    final h = Harness((_) => json({...avail, 'data': data}));
    registerHarness(h);
    final r = ListingDetail.fromJson(fixtureData('restaurant_detail')) as RestaurantDetail;
    await tester.pumpWidget(host(RestaurantCheckoutForm(
      restaurant: r,
      initialSeats: const {'69ce460f50976c8d2c921f98': 5},
      checkout: CheckoutController(sheet: NeverSheet()),
    )));
    await tester.pump();

    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(h.last.url.path, '/api/v1/booking/availability/69ce460f50976c8d2c921f97');
    expect(h.last.url.queryParameters.keys, ['date']);

    ChoiceChip chip(String text) => tester.widget<ChoiceChip>(find.ancestor(of: find.text(text), matching: find.byType(ChoiceChip)));
    expect(chip('8:00 AM – 10:30 PM · passed').onSelected, isNull);
    expect(chip('10:30 PM – 12:30 PM · full').onSelected, isNull);
    expect(chip('2:00 PM – 4:00 PM').onSelected, isNotNull);

    await tester.tap(find.text('2:00 PM – 4:00 PM'));
    await tester.pump();
    expect(find.text('VIP × 2'), findsOneWidget); // 5 wanted, 2 free in this slot
    expect(find.textContaining('2 free at this time'), findsOneWidget);
    expect(find.textContaining('none free'), findsOneWidget); // Normal
  });

  testWidgets('transport: passengers capped at the seat count', (tester) async {
    tallScreen(tester);
    registerHarness(Harness((_) => json({'success': true, 'data': {'available': true}})));
    final t = ListingDetail.fromJson(fixtureData('transport_detail')) as TransportDetail; // 4 seats
    await tester.pumpWidget(host(TransportCheckoutForm(transport: t, checkout: CheckoutController(sheet: NeverSheet()))));
    await tester.pump();
    final more = find.byTooltip('More');
    for (var i = 0; i < 6; i++) {
      await tester.tap(more, warnIfMissed: false);
      await tester.pump();
    }
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Up to 4 seats'), findsOneWidget);
  });

  testWidgets('massage: a duration longer than the opening hours offers no time', (tester) async {
    tallScreen(tester);
    registerHarness(Harness((_) => json({'success': true, 'data': {}})));
    final m = ListingDetail.fromJson(fixtureData('massage_detail')) as MassageDetail; // 682 min, open 12:21–2:21 AM
    await tester.pumpWidget(host(MassageCheckoutForm(massage: m, checkout: CheckoutController(sheet: NeverSheet()))));
    await tester.pump();
    // Single duration is pre-selected.
    await tester.tap(find.text('Choose a day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No start time fits'), findsOneWidget);
  });

  testWidgets('massage: booked times are crossed out and people are capped by capacity', (tester) async {
    tallScreen(tester);
    final m = MassageDetail({
      'id': 'm1',
      'title': 'Sports massage',
      'openTime': '9:00 AM',
      'closeTime': '12:00 PM',
      'capacity': 1,
      'durations': [
        {'_id': 'd1', 'duration': '60 min', 'minutes': 60, 'price': 100},
      ],
    });
    final asked = <String>[];
    await tester.pumpWidget(host(MassageCheckoutForm(
      massage: m,
      checkout: CheckoutController(sheet: NeverSheet()),
      now: () => DateTime(2026, 11, 18, 7),
      loadSlots: (day, duration, persons) async {
        asked.add('${day.day} $duration $persons');
        return ApiResult.success(Availability.fromJson({
          'capacity': 1,
          'slots': [
            {'time': '9:00 AM', 'left': 1, 'available': true, 'isPast': false},
            {'time': '10:00 AM', 'left': 0, 'available': false, 'isPast': false},
          ],
        }));
      },
    )));
    await tester.pump();
    await tester.tap(find.text('Choose a day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(asked, ['18 60 min 1']);
    ChoiceChip chip(String t) => tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, t));
    expect(chip('9:00 AM').onSelected, isNotNull);
    expect(chip('10:00 AM').onSelected, isNull);
    expect(find.text('Crossed-out times are booked.'), findsOneWidget);
    // One guest: a plain "1 guest" label (no greyed-out counter) and a hint
    // for groups.
    expect(find.text('1 guest'), findsOneWidget);
    expect(find.byTooltip('More'), findsNothing);
    expect(find.textContaining('For a group, book separate times'), findsOneWidget);
  });

  testWidgets('massage for groups: people go up to the capacity, capped at 6', (tester) async {
    tallScreen(tester);
    MassageDetail massage(int capacity) => MassageDetail({
          'id': 'm2',
          'title': 'Group massage',
          'openTime': '9:00 AM',
          'closeTime': '6:00 PM',
          'capacity': capacity,
          'durations': [
            {'_id': 'd1', 'duration': '60 min', 'minutes': 60, 'price': 80},
          ],
        });
    expect(massage(1).guestsLabel, 'For 1 guest');
    expect(massage(4).guestsLabel, 'Up to 4 guests');
    expect(massage(12).maxPeople, 6);
    // The server's limit wins once it sends one (as for Ski Pass).
    final serverLimit = MassageDetail({'id': 'm3', 'title': 'Spa', 'capacity': 12, 'maxPeoplePerBooking': 8});
    expect(serverLimit.maxPeople, 8);
    expect(serverLimit.guestsLabel, 'Up to 8 guests');

    await tester.pumpWidget(host(MassageCheckoutForm(
      massage: massage(3),
      checkout: CheckoutController(sheet: NeverSheet()),
      loadSlots: (_, __, ___) async => ApiResult.success(Availability.fromJson({'slots': []})),
    )));
    await tester.pump();
    expect(find.text('Up to 3 people can come together at the same time.'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byTooltip('More'), warnIfMissed: false);
      await tester.pump();
    }
    expect(find.text('3'), findsOneWidget);
  });
}
