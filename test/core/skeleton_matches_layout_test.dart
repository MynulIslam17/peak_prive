import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/widgets/collapsible_details_layout.dart';
import 'package:harry_service_app/app/core/widgets/listing_details_parts.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

/// The skeleton of a details page and the loaded page must line up: if they
/// don't, the content visibly jumps the moment the request comes back.
///
/// These compare the parts both pages share: the floating back button, the
/// sheet's grab handle, and where the sheet's first line of content starts.
void main() {
  final handle = find.byWidgetPredicate(
    (w) => w is Container && w.constraints == BoxConstraints.tightFor(width: 44, height: 5),
    description: 'sheet grab handle',
  );
  final back = find.byIcon(Icons.arrow_back_ios_new_rounded);
  final titlePlaceholder = find.byWidgetPredicate(
    (w) => w is SkeletonBox && w.width == 230 && w.height == 22,
    description: 'title placeholder',
  );

  const title = 'Three Valleys day pass';

  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(home: child),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// The loaded page, with the pieces every listing details screen uses.
  Widget loaded() => CollapsibleDetailsLayout(
        imageUrl: '',
        title: title,
        bottomBar: DetailsBottomBar(price: '€52', buttonText: 'Book Ski Pass', onPressed: () {}),
        children: const [
          ListingHeader(title: title, rating: 4.8, reviewCount: 12),
          SizedBox(height: 20),
          ListingSectionTitle('About this pass'),
          ListingExpandableText('A day on the slopes.'),
        ],
      );

  // How far the sheet may sit from where the real one opens. The pinned bar
  // decides that, and the real bar's height follows its own text: on a wide
  // screen `ScreenUtil` scales the price up until its `FittedBox` shrinks it
  // again, which no placeholder can predict. At the design size it is exact.
  const sizes = <(Size, double)>[
    (Size(390, 844), 0),
    (Size(834, 1112), 16),
  ];

  for (final (size, tolerance) in sizes) {
    group('${size.width.toInt()}×${size.height.toInt()}', () {
      testWidgets('back button sits in the same place', (tester) async {
        await pump(tester, const DetailsPageSkeleton(), size);
        final loading = tester.getRect(back);

        await pump(tester, loaded(), size);
        expect(tester.getRect(back), loading);
      });

      testWidgets('the sheet opens at the same height', (tester) async {
        await pump(tester, const DetailsPageSkeleton(), size);
        final loading = tester.getRect(handle);

        await pump(tester, loaded(), size);
        final real = tester.getRect(handle);
        expect(real.left, loading.left);
        expect(real.width, loading.width);
        expect(real.top, closeTo(loading.top, tolerance));
      });

      testWidgets('the title starts at the same point', (tester) async {
        await pump(tester, const DetailsPageSkeleton(), size);
        final loading = tester.getTopLeft(titlePlaceholder);

        await pump(tester, loaded(), size);
        final real = tester.getTopLeft(find.text(title).first);
        expect(real.dx, loading.dx);
        expect(real.dy, closeTo(loading.dy, tolerance));
      });
    });
  }
}
