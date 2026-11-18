import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore_for_file: discarded_futures, unawaited_futures
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/utils/toast_host.dart';

void main() {
  setUp(() => Get.testMode = true);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the same error tapped again is shown once, not queued', (tester) async {
    await pumpApp(tester);
    for (var i = 0; i < 5; i++) {
      showAppToast(type: ToastType.error, title: 'Download failed', message: 'Try again.');
      await tester.pump(const Duration(milliseconds: 200));
    }
    await settle(tester);
    expect(find.text('Download failed'), findsOneWidget);

    // After it times out nothing else follows.
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    expect(find.text('Download failed'), findsNothing);
    expect(ToastHost.visibleKey, isNull);

    // Once gone, the same error can show again.
    showAppToast(type: ToastType.error, title: 'Download failed', message: 'Try again.');
    await settle(tester);
    expect(find.text('Download failed'), findsOneWidget);
    ToastHost.dismiss(); // completes as the close animation runs
    await settle(tester);
    expect(find.text('Download failed'), findsNothing);
  });

  testWidgets('a different toast replaces the visible one, no backlog', (tester) async {
    await pumpApp(tester);
    showAppToast(type: ToastType.error, title: 'First', message: 'a');
    await settle(tester);
    showAppToast(type: ToastType.error, title: 'Second', message: 'b');
    showAppToast(type: ToastType.success, title: 'Third', message: 'c');
    await settle(tester);
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsNothing);
    expect(find.text('Third'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
    expect(find.text('Second'), findsNothing);
    expect(find.text('Third'), findsNothing);
  });

  testWidgets('route change clears an error but keeps a success toast', (tester) async {
    await pumpApp(tester);
    showAppToast(type: ToastType.error, title: 'Login failed', message: 'x');
    await settle(tester);
    ToastHost.onRouteChanged();
    await settle(tester);
    expect(find.text('Login failed'), findsNothing);

    showAppToast(type: ToastType.success, title: 'Code sent', message: 'y');
    await settle(tester);
    ToastHost.onRouteChanged();
    await settle(tester);
    expect(find.text('Code sent'), findsOneWidget);
    ToastHost.dismiss();
    await settle(tester);
  });
}
