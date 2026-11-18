// ignore_for_file: discarded_futures, unawaited_futures
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';

/// The toast sits over the bottom of every screen, so its height is a design
/// constraint rather than an implementation detail. These bounds are measured
/// against the test font; they exist to catch a restyle quietly turning the
/// card back into a panel.
void main() {
  setUp(() => Get.testMode = true);

  Future<double> heightOf(WidgetTester tester, String title, String message, {String? action}) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    showAppToast(type: ToastType.error, title: title, message: message, actionLabel: action, onAction: () {});
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final height = tester.renderObject<RenderBox>(find.byType(GetSnackBar).first).size.height;
    // Let the display timer and the close animation finish.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return height;
  }

  testWidgets('a title and message fit in one compact card', (tester) async {
    final height = await heightOf(tester, 'Download failed', "We couldn't create your ticket. Please try again.");
    expect(height, lessThanOrEqualTo(56));
  });

  testWidgets('a title on its own is shorter still', (tester) async {
    final height = await heightOf(tester, 'Saved', '');
    expect(height, lessThanOrEqualTo(50));
  });

  testWidgets('an action button does not make the card taller', (tester) async {
    final plain = await heightOf(tester, 'Payment problem', 'Your card was declined.');
    final withAction = await heightOf(tester, 'Payment problem', 'Your card was declined.', action: 'Retry');
    expect(withAction, equals(plain));
  });

  testWidgets('a long message is clipped to two lines, not grown into a panel', (tester) async {
    final height = await heightOf(tester, 'Error', 'x' * 400);
    expect(height, lessThanOrEqualTo(70));
  });
}
