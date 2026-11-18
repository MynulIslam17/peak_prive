import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/listing_browse_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/views/home/home_service_source.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/harness.dart';

Map<String, dynamic> card(String id, {String category = 'Ski_Hire'}) =>
    {'id': id, 'category': category, 'title': 'L $id', 'price': {'amount': 10, 'unit': 'per_day'}};

http.Response page(List<Map<String, dynamic>> items, int p, int totalPages) => json({
      'success': true,
      'data': items,
      'meta': {'page': p, 'limit': 10, 'total': items.length, 'totalPages': totalPages},
    });

bool isCategories(http.Request r) => r.url.path.contains('/common/category/');

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  ListingBrowseController make(Harness h, ServiceKind kind) {
    registerHarness(h);
    return ListingBrowseController(kind, debounce: Duration.zero);
  }

  test('fresh load: listings, paging and categories', () async {
    final h = Harness((r) => isCategories(r) ? fixtureResponse('cat_ski-hire') : fixtureResponse('p_hire_my'));
    final c = make(h, ServiceKind.skiHire);
    await c.load();
    expect(c.isLoading, isFalse);
    expect(c.listings, hasLength(2));
    expect(c.hasMore, isTrue);
    expect(c.errorMessage, isNull);
    expect(c.categories, isNotEmpty);
    expect(c.isCategoryLoading, isFalse);
    final browse = h.requests.firstWhere((r) => !isCategories(r));
    expect(browse.url.path, '/api/v1/ski-hire');
    expect(browse.url.queryParameters, {'page': '1', 'limit': '10'});
  });

  test('categories are fetched once and never for ski pass', () async {
    final h = Harness((r) => isCategories(r) ? fixtureResponse('cat_ski-hire') : page([], 1, 0));
    final c = make(h, ServiceKind.skiHire);
    await c.load();
    await c.load(search: 'x');
    expect(h.requests.where(isCategories), hasLength(1));

    final h2 = Harness((r) => page([card('a', category: 'Ski_Pass')], 1, 1));
    final p = make(h2, ServiceKind.skiPass);
    await p.load(subCategory: 'ignored');
    expect(h2.requests.where(isCategories), isEmpty);
    expect(h2.last.url.queryParameters.containsKey('category'), isFalse);
  });

  test('reloading the same filters keeps the list visible (no skeleton)', () async {
    var slow = false;
    final gate = Completer<void>();
    final h = Harness((r) async {
      if (isCategories(r)) return fixtureResponse('cat_ski-hire');
      if (slow) await gate.future;
      return page([card('a'), card('b')], 1, 1);
    });
    final c = make(h, ServiceKind.skiHire);
    await c.load();
    slow = true;
    final f = c.load();
    expect(c.isLoading, isFalse);
    expect(c.listings.map((l) => l.id), ['a', 'b']);
    gate.complete();
    await f;
    expect(c.listings.map((l) => l.id), ['a', 'b']);
    // A different filter starts from the skeleton.
    slow = false;
    final g = c.load(search: 'x');
    expect(c.isLoading, isTrue);
    await g;
  });

  test('filters are trimmed and sent; blanks dropped', () async {
    final h = Harness((r) => isCategories(r) ? json({'success': true, 'data': []}) : page([], 1, 0));
    final c = make(h, ServiceKind.transport);
    await c.load(subCategory: 'cat1', search: '  van ');
    final q = h.requests.lastWhere((r) => !isCategories(r)).url.queryParameters;
    expect(q['search'], 'van');
    expect(q['category'], 'cat1');
    await c.load(subCategory: '', search: '   ');
    final q2 = h.requests.lastWhere((r) => !isCategories(r)).url.queryParameters;
    expect(q2.containsKey('search'), isFalse);
    expect(q2.containsKey('category'), isFalse);
  });

  test('empty result is not an error', () async {
    final h = Harness((r) => page([], 1, 0));
    final c = make(h, ServiceKind.skiPass);
    await c.load();
    expect(c.listings, isEmpty);
    expect(c.errorMessage, isNull);
    expect(c.hasMore, isFalse);
  });

  test('server error and offline set errorMessage', () async {
    final h = Harness((r) => http.Response('<html>502</html>', 502));
    final c = make(h, ServiceKind.massage);
    await c.load();
    expect(c.errorMessage, isNotNull);
    expect(c.listings, isEmpty);
    expect(c.isCategoryLoading, isFalse);

    final h2 = Harness((r) => throw const SocketException('down'));
    final c2 = make(h2, ServiceKind.skiPass);
    await c2.load();
    expect(c2.errorMessage, contains('internet'));
  });

  test('loadMore appends, stops at the last page, drops duplicates', () async {
    final h = Harness((r) {
      if (isCategories(r)) return json({'success': true, 'data': []});
      final p = int.parse(r.url.queryParameters['page']!);
      return p == 1 ? page([card('a'), card('b')], 1, 2) : page([card('b'), card('c')], 2, 2);
    });
    final c = make(h, ServiceKind.skiHire);
    await c.load();
    await c.loadMore();
    expect(c.listings.map((l) => l.id), ['a', 'b', 'c']);
    expect(c.hasMore, isFalse);
    final before = h.requests.length;
    await c.loadMore(); // at the end: no call
    expect(h.requests.length, before);
  });

  test('a failed next page keeps the list and reports loadMoreError', () async {
    final h = Harness((r) {
      if (isCategories(r)) return json({'success': true, 'data': []});
      return r.url.queryParameters['page'] == '1' ? page([card('a')], 1, 3) : http.Response('x', 500);
    });
    final c = make(h, ServiceKind.skiHire);
    await c.load();
    await c.loadMore();
    expect(c.listings.single.id, 'a');
    expect(c.loadMoreError, isNotNull);
    expect(c.errorMessage, isNull);
    expect(c.hasMore, isTrue); // can retry
  });

  test('a slow older search never overwrites a newer one', () async {
    final slow = Completer<http.Response>();
    final h = Harness((r) {
      if (r.url.queryParameters['search'] == 'old') return slow.future;
      return page([card('new', category: 'Ski_Pass')], 1, 1);
    });
    final c = make(h, ServiceKind.skiPass);
    final first = c.load(search: 'old');
    await c.load(search: 'new');
    slow.complete(page([card('old', category: 'Ski_Pass')], 1, 1));
    await first;
    expect(c.listings.single.id, 'new');
    expect(c.search, 'new');
  });

  test('debounced search runs the last query only', () async {
    final h = Harness((r) => page([], 1, 0));
    registerHarness(h);
    final c = ListingBrowseController(ServiceKind.skiPass, debounce: const Duration(milliseconds: 20));
    c.searchDebounced('a');
    c.searchDebounced('ab');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(h.requests, hasLength(1));
    expect(h.last.url.queryParameters['search'], 'ab');
  });

  test('home tile mapping', () {
    final hire = ListingCard.fromJson(card('a'));
    final t = toHomeListing(hire);
    expect(t.priceIsFrom, isTrue);
    expect(t.priceUnit, ' / day');
    expect(t.price, 10);

    final pass = toHomeListing(ListingCard.fromJson({
      'id': 'p',
      'category': 'Ski_Pass',
      'passType': 'Vip',
      'price': {'amount': 45, 'unit': 'per_person'},
      'rating': {'average': 4.5, 'count': 2},
    }));
    expect(pass.priceIsFrom, isFalse);
    expect(pass.badge, 'VIP');
    expect(pass.reviewCount, 2);

    final free = toHomeListing(ListingCard.fromJson({'id': 'x', 'category': 'Transport'}));
    expect(free.price, isNull);
    expect(free.imageUrl, '');
    expect(free.priceUnit, '');
  });

  test('HomeServiceSource maps keys to kinds and routes', () {
    expect(HomeServiceSource.forKey('ski_hire')!.type.kind, ServiceKind.skiHire);
    expect(HomeServiceSource.forKey('nope'), isNull);
    expect(HomeServiceSource.forKey('ski_pass')!.supportsCategories, isFalse);
  });
}
