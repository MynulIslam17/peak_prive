import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/modules/all_service/views/AllServiceScreen.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(Get.reset);

  Future<NavController> pump(WidgetTester tester, {String lastType = ''}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final nav = Get.put(NavController())..addType(lastType);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(360, 690),
      child: GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const AllServiceScreen()),
          GetPage(name: Routes.bottomNav, page: () => const Scaffold(body: Text('home tabs'))),
          GetPage(name: Routes.itinerary, page: () => const Scaffold(body: Text('itinerary page'))),
        ],
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300)); // photo ready (or timeout)
    await tester.pump(const Duration(seconds: 2)); // entrance animation
    return nav;
  }

  testWidgets('every service and the itinerary are offered', (tester) async {
    await pump(tester);
    for (final label in ['Ski Pass', 'Ski Hire', 'Transport', 'Restaurant', 'Massage', 'Itinerary']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('a service tile sets the type and opens the home tabs', (tester) async {
    final nav = await pump(tester);
    nav.changeIndex(2);
    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();
    expect(nav.getServiceType, 'restaurant');
    expect(nav.getIndex, 0);
    expect(find.text('home tabs'), findsOneWidget);
  });

  testWidgets('itinerary opens its own screen', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();
    expect(find.text('itinerary page'), findsOneWidget);
  });

  testWidgets('the last used service is marked', (tester) async {
    await pump(tester, lastType: 'massage');
    expect(find.text('Last used'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Massage.*Last used')), findsOneWidget);
  });

  testWidgets('tiles fit with large text (no 1px overflow)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.put(NavController());
    for (final scale in [1.0, 1.15, 1.3]) {
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(360, 690),
        child: GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const AllServiceScreen(),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull, reason: 'text ×$scale');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
