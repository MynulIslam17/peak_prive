import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';
import 'package:harry_service_app/app/modules/auth/views/signup_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(Get.reset);
  tearDown(Get.reset);

  test('provider service labels map to the API values', () {
    expect(providerTypeFor('Ski Hire'), 'Ski_Hire');
    expect(providerTypeFor('Ski Pass'), 'Ski_Pass');
    expect(providerTypeFor('Massage'), 'Massage');
  });

  testWidgets('signup starts as a customer and reveals the service picker for providers', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 900) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Get.put(UserSignupController());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const GetMaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Service type'), findsNothing);

    await tester.pump(const Duration(seconds: 1)); // entrance animation
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();
    expect(find.text('Service type'), findsOneWidget);
    for (final s in ['Ski Pass', 'Ski Hire', 'Transport', 'Restaurant Booking', 'Massage']) {
      expect(find.widgetWithText(ChoiceChip, s), findsOneWidget, reason: s);
    }
    await tester.tap(find.widgetWithText(ChoiceChip, 'Massage'));
    await tester.pump();
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Massage')).selected, isTrue);

    // Each tab has its own ripple (an InkWell), so taps show on that tab.
    expect(find.ancestor(of: find.text('Customer'), matching: find.byType(InkWell)), findsWidgets);

    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();
    expect(find.text('Service type'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signup header shows one title and the back button does not cover it', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844) * 3
      ..devicePixelRatio = 3
      ..padding = const FakeViewPadding(top: 59, left: 0, right: 0, bottom: 34);
    addTearDown(tester.view.reset);
    Get.put(UserSignupController());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => GetMaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Create your account'), findsOneWidget);
    final title = tester.getRect(find.text('Create your account'));
    final back = tester.getRect(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(title.overlaps(back), isFalse, reason: 'back button overlaps the title');
    expect(back.bottom, lessThanOrEqualTo(title.top));

    // Scrolling the green title away reveals the solid bar. The green title
    // is fully behind that bar, so the two titles are not on screen together.
    final scroll = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    scroll.controller!.jumpTo(220);
    await tester.pump(); // applies the scroll, then measures the title
    await tester.pump(); // builds the bar from that measurement
    final titles = find.text('Create your account');
    expect(titles, findsNWidgets(2));
    final cover = tester.view.padding.top / tester.view.devicePixelRatio + 56;
    final header = tester.renderObjectList<RenderBox>(titles).reduce(
      (a, b) => a.size.height >= b.size.height ? a : b,
    );
    final headerBottom = header.localToGlobal(Offset(0, header.size.height)).dy;
    expect(headerBottom, lessThanOrEqualTo(cover));
    expect(tester.takeException(), isNull);
  });
}
