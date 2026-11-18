import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/widgets/draggable_orb_fab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const screen = Size(400, 800);
  const orb = 58.0;

  Future<List<int>> pump(WidgetTester tester, {String? key}) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final taps = <int>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraggableOrbFab(
          semanticLabel: 'Switch service',
          storageKey: key,
          onTap: () => taps.add(1),
          icon: const Icon(Icons.apps),
          child: const SizedBox.expand(),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    return taps;
  }

  Rect orbRect(WidgetTester tester) => tester.getRect(find.byType(AnimatedOrb));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('starts on the right, tap runs onTap', (tester) async {
    final taps = await pump(tester);
    final r = orbRect(tester);
    expect(r.right, closeTo(screen.width - 14, 1));
    await tester.tap(find.byType(AnimatedOrb));
    await settle(tester);
    expect(taps, hasLength(1));
  });

  testWidgets('dragged to the left half, it snaps to the left edge', (tester) async {
    await pump(tester);
    final start = orbRect(tester).center;
    await tester.dragFrom(start, Offset(-(screen.width - 120), -200));
    await settle(tester);
    final r = orbRect(tester);
    expect(r.left, closeTo(14, 1));
    expect(r.center.dy, closeTo(start.dy - 200, 20)); // minus the drag slop
  });

  testWidgets('pushed past the edge it hides; a tap brings it back', (tester) async {
    final taps = await pump(tester);
    final start = orbRect(tester).center;
    await tester.dragFrom(start, const Offset(80, 0));
    await settle(tester);
    var r = orbRect(tester);
    expect(r.left, greaterThan(screen.width - 30), reason: 'only a sliver is visible');
    expect(r.left, lessThan(screen.width));

    // Tapping the sliver shows it again instead of running onTap.
    await tester.tapAt(Offset(screen.width - 8, r.center.dy));
    await settle(tester);
    r = orbRect(tester);
    expect(r.right, closeTo(screen.width - 14, 1));
    expect(taps, isEmpty);
  });

  testWidgets('remembers where it was left (storageKey)', (tester) async {
    await pump(tester, key: 'orb_test');
    await tester.dragFrom(orbRect(tester).center, const Offset(-300, 0));
    await settle(tester);
    expect(orbRect(tester).left, closeTo(14, 1));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('orb_test.side'), 'left');

    // Re-opened: comes back on the left.
    await tester.pumpWidget(const SizedBox());
    await pump(tester, key: 'orb_test');
    expect(orbRect(tester).left, closeTo(14, 1));
  });

  testWidgets('touches away from the orb reach the content', (tester) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var hits = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraggableOrbFab(
          onTap: () {},
          child: Center(child: TextButton(onPressed: () => hits++, child: const Text('content'))),
        ),
      ),
    ));
    await tester.tap(find.text('content'));
    expect(hits, 1);
    expect(orb, 58); // default size used above
  });
}
