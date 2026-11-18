import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/widgets/exit_app_guard.dart';

void main() {
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('back on the last screen asks first; Stay keeps the app open', (tester) async {
    var closed = 0;
    await tester.pumpWidget(ScreenUtilInit(designSize: const Size(360, 690), child: MaterialApp(
      home: ExitAppGuard(closeApp: () => closed++, child: const Scaffold(body: Text('services'))),
    )));

    await systemBack(tester);
    expect(find.text('Close the app?'), findsOneWidget);
    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();
    expect(closed, 0);
    expect(find.text('services'), findsOneWidget);

    await systemBack(tester);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('onBack can take the press (e.g. back to the first tab)', (tester) async {
    var tabBacks = 0;
    await tester.pumpWidget(ScreenUtilInit(designSize: const Size(360, 690), child: MaterialApp(
      home: ExitAppGuard(closeApp: () {}, onBack: () => ++tabBacks == 1, child: const Scaffold()),
    )));
    await systemBack(tester);
    expect(tabBacks, 1);
    expect(find.text('Close the app?'), findsNothing);
    await systemBack(tester);
    expect(find.text('Close the app?'), findsOneWidget);
  });

  testWidgets('when the screen was pushed, back just goes back', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(ScreenUtilInit(designSize: const Size(360, 690), child: MaterialApp(navigatorKey: key, home: const Scaffold(body: Text('below')))));
    key.currentState!.push(MaterialPageRoute(
      builder: (_) => ExitAppGuard(closeApp: () {}, child: const Scaffold(body: Text('services'))),
    ));
    await tester.pumpAndSettle();
    await systemBack(tester);
    expect(find.text('Close the app?'), findsNothing);
    expect(find.text('below'), findsOneWidget);
  });
}
