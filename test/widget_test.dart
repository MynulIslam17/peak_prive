import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/routes/app_pages.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';

void main() {
  test('every route the app navigates to has a page', () {
    final pages = AppPages.routes.map((p) => p.name).toSet();
    // Collect `Routes.x` references used for navigation anywhere in lib/.
    final used = <String>{};
    final re = RegExp(r'Routes\.(\w+)');
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('app_routes.dart')) continue;
      for (final m in re.allMatches(f.readAsStringSync())) {
        used.add(m.group(1)!);
      }
    }
    // Map names to values through a small mirror of app_routes.dart.
    final src = File('lib/app/routes/app_routes.dart').readAsStringSync();
    final values = {
      for (final m in RegExp(r'static const\s+(\w+)\s*=\s*"([^"]*)"').allMatches(src)) m.group(1)!: m.group(2)!,
    };
    final missing = [
      for (final name in used)
        if (values[name] != null && !pages.contains(values[name])) '$name (${values[name]})',
    ];
    // Bottom-nav tabs are not routes.
    missing.removeWhere((m) => m.startsWith('profile '));
    expect(missing, isEmpty);
  });

  test('booking detail routes all open the unified screen', () {
    final byName = {for (final p in AppPages.routes) p.name: p};
    final unified = byName[Routes.bookingDetails]!;
    for (final r in [
      Routes.userHireBookingDetails,
      Routes.userTransportBookingDetails,
      Routes.userPassBookingDetails,
      Routes.userMassageBookingDetails,
      Routes.userRestaurantBookingDetails,
      Routes.providerBookingDetails,
    ]) {
      expect(byName[r], isNotNull, reason: r);
      expect(byName[r]!.page().runtimeType, unified.page().runtimeType, reason: r);
    }
  });
}
