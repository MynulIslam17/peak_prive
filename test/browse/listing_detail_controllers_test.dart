import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/user/hire/contollers/hire_details_controller.dart';
import 'package:harry_service_app/app/modules/user/hire/models/hire_price_unit.dart';
import 'package:harry_service_app/app/modules/user/massage/controllers/message_details_controller.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_details_controller.dart';
import 'package:harry_service_app/app/modules/user/restaurant/controllers/restaurant_details_controller.dart';
import 'package:harry_service_app/app/modules/user/trasnport/controlers/trasnport_details_controller.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

bool isReviews(http.Request r) => r.url.path.endsWith('/reviews');

Harness withDetail(Map<String, dynamic> detail, {http.Response? reviews}) => Harness((r) => isReviews(r)
    ? (reviews ?? json({'success': true, 'data': [], 'meta': {'page': 1, 'totalPages': 0}, 'rating': {'average': 0, 'count': 0}}))
    : json({'success': true, 'data': detail}));

Map<String, dynamic> hire({bool active = true, List<Map<String, dynamic>>? items}) => {
      ...fixtureData('hire_detail'),
      'isActive': active,
      if (items != null) 'items': items,
    };

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  group('hire', () {
    test('loads detail and reviews', () async {
      final h = Harness((r) => isReviews(r) ? fixtureResponse('hire_reviews') : fixtureResponse('hire_detail'));
      registerHarness(h);
      final c = HireDetailsController();
      expect(await c.fetch('6939508f6fd3cd7f26c29698'), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(c.listing!.items.single.name, 'aaa');
      expect(c.priceUnit, HirePriceUnit.perDay);
      expect(c.reviews.single.rating, 2);
      expect(c.rating.count, 1);
      expect(c.canSeeAllReviews, isFalse);
      expect(h.requests.where(isReviews).single.url.queryParameters['limit'], '3');
      expect(c.canBook, isTrue);
      expect(h.requests.map((r) => r.url.path), containsAll(['/api/v1/ski-hire/6939508f6fd3cd7f26c29698', '/api/v1/ski-hire/6939508f6fd3cd7f26c29698/reviews']));
    });

    test('more than three reviews exposes see all', () async {
      registerHarness(withDetail(hire(), reviews: json({
        'success': true,
        'data': [
          for (var i = 1; i <= 3; i++)
            {'rating': 5, 'comment': 'Review $i', 'createdAt': '2026-01-0${i}T00:00:00.000Z'},
        ],
        'meta': {'page': 1, 'limit': 3, 'total': 8, 'totalPages': 3},
        'rating': {'average': 4.5, 'count': 8},
      })));
      final c = HireDetailsController();
      await c.fetch('x');
      await Future<void>.delayed(Duration.zero);
      expect(c.reviews, hasLength(3));
      expect(c.canSeeAllReviews, isTrue);
    });

    test('selection respects stock and totals per unit', () async {
      registerHarness(withDetail(hire(items: [
        {'id': 'a', 'name': 'Skis', 'price': 25, 'quantity': 2},
        {'id': 'b', 'name': 'Boots', 'price': 10.5, 'quantity': 0},
      ])));
      final c = HireDetailsController();
      await c.fetch('x');
      c.addItem('a');
      c.addItem('a');
      c.addItem('a'); // over stock
      c.addItem('b'); // out of stock
      c.addItem('zzz'); // unknown
      expect(c.selectedItems, {'a': 2});
      expect(c.selectedCount, 2);
      expect(c.totalSelectedPrice, 50);
      final start = DateTime(2026, 12, 1, 9);
      expect(c.totalFor(start, start.add(const Duration(days: 1, hours: 1))), 100); // 2 started days
      c.removeItem('a');
      expect(c.selectedItems, {'a': 1});
      c.clearSelection();
      expect(c.selectedItems, isEmpty);
    });

    test('reload drops selections above the new stock; other listing clears', () async {
      var stock = 5;
      registerHarness(Harness((r) => isReviews(r)
          ? json({'success': true, 'data': []})
          : json({'success': true, 'data': hire(items: [{'id': 'a', 'name': 'Skis', 'price': 1, 'quantity': stock}])})));
      final c = HireDetailsController();
      await c.fetch('x');
      for (var i = 0; i < 4; i++) {
        c.addItem('a');
      }
      stock = 2;
      await c.fetch('x');
      expect(c.selectedItems, isEmpty);
      stock = 5;
      await c.fetch('x');
      c.addItem('a');
      await c.fetch('y');
      expect(c.selectedItems, isEmpty);
    });

    test('inactive listing cannot be selected or booked', () async {
      registerHarness(withDetail(hire(active: false)));
      final c = HireDetailsController();
      await c.fetch('x');
      expect(c.canBook, isFalse);
      c.addItem(c.items.first.id);
      expect(c.selectedItems, isEmpty);
    });

    test('not found and invalid id', () async {
      registerHarness(Harness((r) => json({'success': false, 'message': 'Ski hire not found.'}, 404)));
      final c = HireDetailsController();
      expect(await c.fetch('x'), isFalse);
      expect(c.errorMessage, 'This listing is no longer available.');
      expect(c.listing, isNull);
      expect(await c.fetch(''), isFalse);
      expect(c.errorMessage, 'This listing link is invalid.');
    });

    test('reviews failing keeps the listing', () async {
      registerHarness(withDetail(hire(), reviews: http.Response('err', 500)));
      final c = HireDetailsController();
      await c.fetch('x');
      await Future<void>.delayed(Duration.zero);
      expect(c.listing, isNotNull);
      expect(c.reviewsError, isNotNull);
      expect(c.rating.average, 2); // falls back to the card rating
    });

    test('a slow earlier listing does not replace the newer one', () async {
      final slow = Completer<http.Response>();
      registerHarness(Harness((r) {
        if (isReviews(r)) return json({'success': true, 'data': []});
        if (r.url.path.endsWith('/old')) return slow.future;
        return json({'success': true, 'data': {...hire(), 'id': 'new'}});
      }));
      final c = HireDetailsController();
      final first = c.fetch('old');
      await c.fetch('new');
      slow.complete(json({'success': true, 'data': {...hire(), 'id': 'old'}}));
      expect(await first, isFalse);
      expect(c.listing!.id, 'new');
    });
  });

  test('ski pass', () async {
    registerHarness(withDetail(fixtureData('pass_detail')));
    final c = PassDetailsController();
    await c.fetch('p');
    expect(c.listing!.passType, PassType.premium);
    expect(c.listing!.services, hasLength(3));
  });

  test('wrong category in the response is treated as a failure', () async {
    registerHarness(withDetail(fixtureData('massage_detail')));
    final c = PassDetailsController();
    expect(await c.fetch('p'), isFalse);
    expect(c.errorMessage, isNotNull);
  });

  test('transport bookable only when active and priced', () async {
    registerHarness(withDetail(fixtureData('transport_detail')));
    final c = TransportDetailsController();
    await c.fetch('t');
    expect(c.isBookable, isTrue);
    expect(c.listing!.seats, 4);

    registerHarness(withDetail({...fixtureData('transport_detail'), 'price': {'amount': 0}}));
    final c2 = TransportDetailsController();
    await c2.fetch('t');
    expect(c2.isBookable, isFalse);

    registerHarness(withDetail({'id': 't', 'category': 'Transport', 'title': 'Old car', 'seats': null, 'mileage': '', 'price': {'amount': 50}}));
    final c3 = TransportDetailsController();
    await c3.fetch('t');
    expect(c3.listing!.seats, isNull);
    expect(c3.listing!.mileage, isNull);
    expect(c3.isBookable, isTrue);
  });

  test('massage bookable needs a priced duration', () async {
    registerHarness(withDetail(fixtureData('massage_detail')));
    final c = MassageDetailsController();
    await c.fetch('m');
    expect(c.isBookable, isTrue);

    registerHarness(withDetail({...fixtureData('massage_detail'), 'durations': []}));
    final c2 = MassageDetailsController();
    await c2.fetch('m');
    expect(c2.isBookable, isFalse);
  });

  group('restaurant', () {
    test('seat selection and from price', () async {
      registerHarness(withDetail(fixtureData('restaurant_detail')));
      final c = RestaurantDetailsController();
      await c.fetch('r');
      expect(c.isBookable, isTrue);
      expect(c.fromPrice, 44);
      c.selectItem('69ce460f50976c8d2c921f99');
      expect(c.selectedItem!.type, 'Normal');
      c.selectItem(null);
      expect(c.selectedItem, isNull);
    });

    test('no slots or no selectable seats → not bookable; selection cleared on reload', () async {
      var data = fixtureData('restaurant_detail');
      registerHarness(Harness((r) => isReviews(r) ? json({'success': true, 'data': []}) : json({'success': true, 'data': data})));
      final c = RestaurantDetailsController();
      await c.fetch('r');
      c.selectItem('69ce460f50976c8d2c921f98');
      data = {
        ...data,
        'seats': [
          {'id': '69ce460f50976c8d2c921f98', 'type': 'VIP', 'price': 44, 'quantity': 0}
        ],
      };
      await c.fetch('r');
      expect(c.selectedItemId, isNull);
      expect(c.isBookable, isFalse);

      data = {...fixtureData('restaurant_detail'), 'slots': []};
      await c.fetch('r');
      expect(c.isBookable, isFalse);
    });
  });
}
