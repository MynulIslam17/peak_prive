import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/booking/widgets/booking_list_card.dart';

import '../api/fixtures.dart';

Widget _host(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
    );

/// A phone-sized view (the test font is wider than the app's).
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Booking _booking(Map<String, dynamic> extra) =>
    Booking.fromJson({...fixtureData('u_booking_detail'), 'status': 'Completed', ...extra});

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('an unpaid late fee shows "Pay late fee" instead of "Rate & review"', (tester) async {
    _phone(tester);
    var opened = 0;
    await tester.pumpWidget(_host(BookingListCard(
      booking: _booking({
        'actions': ['pay_late_fee', 'review'],
        'lateFee': {'hours': 1, 'amount': 10, 'status': 'due'},
      }),
      onTap: () => opened++,
      onReview: () {},
    )));
    await tester.pump();
    expect(find.text('Late fee due: €10.00'), findsOneWidget);
    expect(find.text('Rate & review'), findsNothing);
    await tester.tap(find.text('Pay late fee'));
    expect(opened, 1); // opens the detail screen, where it is paid
  });

  testWidgets('a paid late fee goes back to "Rate & review"', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(BookingListCard(
      booking: _booking({
        'actions': ['review'],
        'lateFee': {'hours': 1, 'amount': 10, 'status': 'paid'},
      }),
      onTap: () {},
      onReview: () {},
    )));
    await tester.pump();
    expect(find.text('Pay late fee'), findsNothing);
    expect(find.text('Rate & review'), findsOneWidget);
  });

  testWidgets('providers never see "Pay late fee"', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(BookingListCard(
      booking: _booking({'lateFee': {'hours': 1, 'amount': 10, 'status': 'due'}}),
      onTap: () {},
      forProvider: true,
    )));
    await tester.pump();
    expect(find.text('Pay late fee'), findsNothing);
    expect(find.text('View details'), findsOneWidget);
  });
}
