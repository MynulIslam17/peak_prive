import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harry_service_app/app/modules/splash/splash_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('splash animates in on the brand green: logo, name, tagline', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen(navigate: false)));
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, const Color(0xFF08523C));
    expect(find.byWidgetPredicate((w) => w is Image && w.semanticLabel == 'Peak Privee'), findsOneWidget);

    double opacityOf(Finder f) =>
        tester.widget<Opacity>(find.ancestor(of: f, matching: find.byType(Opacity)).first).opacity;
    final tagline = find.text('ABOVE AND BEYOND LUXURY');
    final firstLetter = find.text('P').first;
    expect(opacityOf(tagline), 0);
    expect(opacityOf(firstLetter), 0);

    await tester.pump(const Duration(milliseconds: 2400));
    expect(opacityOf(tagline), 1);
    expect(opacityOf(firstLetter), 1);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox()); // stops the repeating glow
  });
}
