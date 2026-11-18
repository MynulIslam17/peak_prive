import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/widgets/listing_details_parts.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view
      ..physicalSize = const Size(390, 844) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
      ),
    );
    await tester.pump();
  }

  Review review(String comment, int day) => Review(
        rating: 5,
        comment: comment,
        createdAt: DateTime(2026, 1, day),
        user: const PersonRef(id: 'u', name: 'QA'),
      );

  testWidgets('more than three reviews shows a See all button and keeps three on the page', (tester) async {
    var opened = 0;
    await pump(
      tester,
      ListingReviewsSection(
        reviews: [
          review('oldest', 1),
          review('second', 2),
          review('third', 3),
          review('newest', 4),
        ],
        count: 4,
        showSeeAll: true,
        onSeeAll: () => opened++,
      ),
    );

    expect(find.text('See all'), findsOneWidget);
    expect(find.text('newest'), findsOneWidget);
    expect(find.text('oldest'), findsNothing);
    await tester.tap(find.text('See all'));
    expect(opened, 1);
  });

  testWidgets('three reviews or fewer stay on the page without See all', (tester) async {
    await pump(
      tester,
      ListingReviewsSection(
        reviews: [review('one', 1), review('two', 2)],
        count: 2,
        onSeeAll: () {},
      ),
    );

    expect(find.text('See all'), findsNothing);
    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
  });
}
