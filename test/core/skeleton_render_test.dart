import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/booking_Item_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_home_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';
import 'package:harry_service_app/app/modules/user/shared/views/home/widgets/listing_card.dart';

/// Every skeleton must lay out cleanly on a phone and on a tablet: they draw
/// before any data exists, so an overflow here would be the first thing a
/// user sees.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) async {
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
    expect(tester.takeException(), isNull);
  }

  group('details page skeletons', () {
    final cases = <String, List<SkeletonSection>>{
      'ski pass': [SkeletonSection.tiles, SkeletonSection.lines],
      'ski hire': [SkeletonSection.lines, SkeletonSection.list],
      'massage': [SkeletonSection.durations, SkeletonSection.lines],
      'transport': [SkeletonSection.specs, SkeletonSection.lines, SkeletonSection.infoCard],
      'restaurant': [SkeletonSection.lines, SkeletonSection.list, SkeletonSection.chips],
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key} lays out', (tester) async {
        await pump(tester, DetailsPageSkeleton(sections: entry.value));
      });

      testWidgets('${entry.key} lays out on a tablet', (tester) async {
        await pump(tester, DetailsPageSkeleton(sections: entry.value), size: const Size(834, 1112));
      });
    }

    testWidgets('booking lays out', (tester) async {
      await pump(
        tester,
        const DetailsPageSkeleton(booking: true, sections: [SkeletonSection.infoCard, SkeletonSection.infoCard]),
      );
    });

    testWidgets('keeps a working back button while it loads', (tester) async {
      await pump(tester, const DetailsPageSkeleton());
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  group('other skeletons', () {
    final screens = <String, Widget>{
      'checkout': const CheckoutSkeleton(),
      'ticket (from booking)': const TicketSkeleton(),
      'ticket (after checkout)': const TicketSkeleton(actions: 2),
      'listing editor': const FormSkeleton(),
      'wallet': const WalletSkeleton(),
      'withdraw': const WithdrawSkeleton(),
      'transaction history': const TransactionListSkeleton(),
      'chat': const ChatSkeleton(),
      'booking list': const BookingListSkeleton(),
      'itinerary': const BookingListSkeleton(dayHeaders: true),
      'provider home': const ProviderHomeShimmer(),
    };

    for (final entry in screens.entries) {
      testWidgets('${entry.key} lays out', (tester) async {
        await pump(tester, Scaffold(body: entry.value));
      });
    }

    for (final entry in <String, Widget>{
      'review': const ReviewSkeleton(),
      'transaction': const TransactionSkeleton(),
      'booking card': const BookingCardSkeleton(),
      'provider booking card': const BookingCardSkeleton(provider: true),
      'home listing card': const ListingCardSkeleton(),
    }.entries) {
      testWidgets('${entry.key} item lays out', (tester) async {
        await pump(
          tester,
          Scaffold(
            body: ListView(padding: const EdgeInsets.all(16), children: [entry.value]),
          ),
        );
      });
    }
  });
}
