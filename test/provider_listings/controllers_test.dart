import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/listing_editor_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/my_listings_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/listing_drafts.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/listing_editor/editor_ui.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/harness.dart';

/// Text fields of a multipart body (files skipped).
Map<String, String> multipartFields(http.Request r) {
  final body = latin1.decode(r.bodyBytes);
  final out = <String, String>{};
  final re = RegExp(r'name="([^"]+)"\r\n(?:Content-Type:[^\r]*\r\n)?\r\n([\s\S]*?)\r\n--');
  for (final m in re.allMatches(body)) {
    if (body.substring(m.start - 200 < 0 ? 0 : m.start - 200, m.start).contains('filename=')) continue;
    out[m[1]!] = utf8.decode(latin1.encode(m[2]!));
  }
  return out;
}

Set<String> multipartFileFields(http.Request r) {
  final body = latin1.decode(r.bodyBytes);
  return RegExp(r'name="([^"]+)"; filename=').allMatches(body).map((m) => m[1]!).toSet();
}

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  final photo = File('test/fixtures/hire_detail.json');

  group('MyListingsController', () {
    test('loads every page of /my for the kind', () async {
      final h = Harness((_) => fixtureResponse('p_hire_my'));
      registerHarness(h);
      final c = MyListingsController(kind: ServiceKind.skiHire);
      // The fixture always answers page 1 of 6, so paging stops at the 20-page safety limit.
      await c.load();
      expect(h.requests.first.url.path, '/api/v1/ski-hire/my');
      expect(h.requests.first.url.queryParameters['limit'], '50');
      expect(h.requests, hasLength(20));
      expect(c.listings, hasLength(40));
      expect(c.errorMessage, isNull);
      expect(c.isLoading, isFalse);
    });

    test('error state with a readable message', () async {
      registerHarness(Harness((_) => http.Response('<html>502</html>', 502)));
      final c = MyListingsController(kind: ServiceKind.massage);
      await c.load();
      expect(c.listings, isEmpty);
      expect(c.errorMessage, isNotEmpty);
    });

    test('unknown provider type: no call, clear message', () async {
      final h = Harness((_) => json({}));
      registerHarness(h);
      final c = MyListingsController();
      await c.load();
      expect(c.kind, isNull);
      expect(h.requests, isEmpty);
      expect(c.errorMessage, contains('service type'));
    });

    test('setActive: optimistic, confirmed by the server', () async {
      final h = Harness((req) => req.method == 'GET'
          ? fixtureResponse('p_hire_my')
          : json({'success': true, 'data': {'id': '6939508f6fd3cd7f26c29698', 'isActive': false}}));
      registerHarness(h);
      final c = MyListingsController(kind: ServiceKind.skiHire);
      await c.load();
      final card = c.listings.firstWhere((l) => l.id == '6939508f6fd3cd7f26c29698');
      final err = await c.setActive(card, false);
      expect(err, isNull);
      expect(h.last.url.path, '/api/v1/ski-hire/6939508f6fd3cd7f26c29698/status');
      expect(h.lastBody, {'isActive': false});
      expect(c.listings.firstWhere((l) => l.id == card.id).isActive, isFalse);
      expect(c.activeCount, lessThan(c.listings.length));
      expect(c.busyIds, isEmpty);
    });

    test('setActive failure reverts', () async {
      final h = Harness((req) => req.method == 'GET'
          ? fixtureResponse('p_hire_my')
          : json({'success': false, 'message': 'Not your listing.'}, 403));
      registerHarness(h);
      final c = MyListingsController(kind: ServiceKind.skiHire);
      await c.load();
      final card = c.listings.first;
      final err = await c.setActive(card, false);
      expect(err, 'Not your listing.');
      expect(c.listings.first.isActive, isTrue);
    });

    test('delete: success removes; 409 → hasOpenBookings; 404 → treated as gone', () async {
      var deleteStatus = 200;
      final h = Harness((req) {
        if (req.method == 'GET') return fixtureResponse('p_hire_my');
        if (deleteStatus == 200) return json({'success': true, 'data': {'id': 'x', 'deleted': true}});
        return json({'success': false, 'message': deleteStatus == 409 ? 'This listing has open bookings.' : 'Not found.'}, deleteStatus);
      });
      registerHarness(h);
      final c = MyListingsController(kind: ServiceKind.skiHire);
      await c.load();
      final n = c.listings.length;
      final first = c.listings.first;

      deleteStatus = 409;
      expect(await c.delete(first), DeleteOutcome.hasOpenBookings);
      expect(c.actionError, 'This listing has open bookings.');
      expect(c.listings, hasLength(n));
      expect(h.last.method, 'DELETE');
      expect(h.last.url.path, '/api/v1/ski-hire/${first.id}');

      // "Set inactive instead"
      deleteStatus = 200;
      expect(await c.delete(first), DeleteOutcome.deleted);
      expect(c.listings.any((l) => l.id == first.id), isFalse);

      deleteStatus = 404;
      final second = c.listings.first;
      expect(await c.delete(second), DeleteOutcome.deleted);
    });

    test('a saved listing shows at once and survives the quiet sync', () async {
      registerHarness(Harness((_) => fixtureResponse('p_hire_my')));
      final c = MyListingsController(kind: ServiceKind.skiHire);
      await c.load();
      final n = c.listings.length;
      final fresh = ListingCard(
        id: 'new-1', kind: ServiceKind.skiHire, title: 'New shop',
        price: Price.fromJson({'amount': 30, 'unit': 'per_day'}), rating: RatingSummary.fromJson(null), isActive: true,
      );
      c.upsert(fresh);
      expect(c.listings.first.id, 'new-1');
      expect(c.listings, hasLength(n + 1));
      // A reload that doesn't list it yet keeps it; no skeleton on reload.
      final reload = c.load(showLoader: false);
      expect(c.isLoading, isFalse);
      await reload;
      expect(c.listings.first.id, 'new-1');
      // Editing replaces in place.
      final edited = ListingCard(
        id: 'new-1', kind: ServiceKind.skiHire, title: 'Renamed',
        price: Price.fromJson({'amount': 30, 'unit': 'per_day'}), rating: RatingSummary.fromJson(null), isActive: true,
      );
      c.upsert(edited);
      expect(c.listings.where((l) => l.id == 'new-1').single.title, 'Renamed');
    });

    test('delete is optimistic and restores the card on refusal', () async {
      final gate = Completer<void>();
      registerHarness(Harness((req) async {
        if (req.method == 'GET') return fixtureResponse('p_hire_my');
        await gate.future;
        return json({'success': false, 'message': 'This listing has open bookings.'}, 409);
      }));
      final c = MyListingsController(kind: ServiceKind.skiHire);
      await c.load();
      final ids = c.listings.map((l) => l.id).toList();
      final second = c.listings[1];
      final f = c.delete(second);
      expect(c.listings.any((l) => identical(l, second)), isFalse); // gone at once
      gate.complete();
      expect(await f, DeleteOutcome.hasOpenBookings);
      expect(c.listings.map((l) => l.id).toList(), ids); // back, same order
    });

    test('price labels per kind', () {
      ListingCard card(String category, num amount, String unit) =>
          ListingCard.fromJson({'id': 'a', 'category': category, 'price': {'amount': amount, 'unit': unit}});
      expect(listingPriceLabel(card('Ski_Pass', 45, 'per_person')), '€45 / person');
      expect(listingPriceLabel(card('Ski_Hire', 25, 'per_day')), 'from €25 / day');
      expect(listingPriceLabel(card('Transport', 120, 'per_trip')), '€120 / trip');
      expect(listingPriceLabel(card('Massage', 80, 'per_session')), 'from €80 / session');
      expect(listingPriceLabel(card('Restaurant', 0, 'per_seat')), 'No price yet');
    });
  });

  group('ListingEditorController', () {
    test('edit: loads the listing and categories', () async {
      final h = Harness((req) => req.url.path.contains('/common/category/') ? fixtureResponse('cat_ski-hire') : fixtureResponse('hire_detail'));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.skiHire, listingId: '6939508f6fd3cd7f26c29698');
      await c.load();
      expect(c.isEdit, isTrue);
      expect(c.original, isA<SkiHireDetail>());
      expect(c.categories, isNotEmpty);
      expect(c.loadError, isNull);
      expect(h.requests.map((r) => r.url.path), containsAll(['/api/v1/ski-hire/6939508f6fd3cd7f26c29698', '/api/v1/common/category/ski-hire']));
    });

    test('categories failure is reported, listing still loads', () async {
      registerHarness(Harness((req) => req.url.path.contains('/common/category/')
          ? json({'success': false, 'message': 'Server error'}, 500)
          : fixtureResponse('transport_detail')));
      final c = ListingEditorController(kind: ServiceKind.transport, listingId: '69366868c979bb40137064d9');
      await c.load();
      expect(c.categoriesError, 'Server error');
      expect(c.original, isA<TransportDetail>());
    });

    test('empty category list says so', () async {
      registerHarness(Harness((_) => json({'success': true, 'data': []})));
      final c = ListingEditorController(kind: ServiceKind.massage);
      await c.load();
      expect(c.categoriesError, contains('No categories'));
    });

    test('ski pass: no category call; detail 404 → loadError', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Ski pass not found.'}, 404));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.skiPass, listingId: 'gone');
      await c.load();
      expect(h.requests.single.url.path, '/api/v1/ski-pass/gone');
      expect(c.loadError, 'Ski pass not found.');
    });

    test('create: invalid form never reaches the server', () async {
      final h = Harness((_) => json({}));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.transport);
      final ok = await c.save(TransportDraft(title: 'Van').toForm());
      expect(ok, isFalse);
      expect(c.saveError, 'Choose a category.');
      expect(h.requests, isEmpty);
    });

    test('create: posts multipart to /<service>', () async {
      final h = Harness((_) => fixtureResponse('pass_detail', 201));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.skiPass);
      final form = SkiPassDraft(title: 'Day', passType: PassType.basic, price: '45', services: [const PassService(title: 'Lifts', description: 'All')], serviceArea: 'X', description: 'Y', thumbnail: photo).toForm();
      expect(await c.save(form), isTrue);
      expect(h.last.method, 'POST');
      expect(h.last.url.path, '/api/v1/ski-pass');
      final fields = multipartFields(h.last);
      expect(fields['passType'], 'Basic');
      expect(fields['price'], '45');
      expect(multipartFileFields(h.last), {'file'});
      expect(c.saved, isA<SkiPassDetail>());
    });

    test('edit: PATCH sends only the changed fields', () async {
      final h = Harness((req) => fixtureResponse('hire_detail'));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.skiHire, listingId: '6939508f6fd3cd7f26c29698');
      await c.load();
      final draft = SkiHireDraft.from(c.original! as SkiHireDetail)..title = 'New name';
      expect(await c.save(draft.toForm(c.original! as SkiHireDetail)), isTrue);
      expect(h.last.method, 'PATCH');
      expect(h.last.url.path, '/api/v1/ski-hire/6939508f6fd3cd7f26c29698');
      expect(multipartFields(h.last), {'title': 'New name'});
    });

    test('edit with nothing changed: no call, success', () async {
      final h = Harness((_) => fixtureResponse('massage_detail'));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.massage, listingId: '69350faa4ccb065ddc691d4f');
      await c.load();
      final before = h.requests.length;
      final form = MassageDraft.from(c.original! as MassageDetail).toForm(c.original! as MassageDetail);
      expect(await c.save(form), isTrue);
      expect(h.requests.length, before);
    });

    test('edit: removing an item with open bookings → 409 explained', () async {
      final h = Harness((req) => req.method == 'GET'
          ? fixtureResponse('hire_detail')
          : json({'success': false, 'message': 'Item aaa has open bookings.'}, 409));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.skiHire, listingId: '6939508f6fd3cd7f26c29698');
      await c.load();
      final draft = SkiHireDraft.from(c.original! as SkiHireDetail);
      draft.items
        ..clear()
        ..add(HireItemDraft(name: 'Boots', price: '5', quantity: '2'));
      expect(await c.save(draft.toForm(c.original! as SkiHireDetail)), isFalse);
      final fields = multipartFields(h.last);
      expect(jsonDecode(fields['removeItemIds']!), ['6939508f6fd3cd7f26c29699']);
      expect(c.saveError, contains('Item aaa has open bookings.'));
      expect(c.saveError, contains('Keep it'));
    });

    test('restaurant edit: seats/slots patch with removals', () async {
      final h = Harness((req) => fixtureResponse('restaurant_detail'));
      registerHarness(h);
      final c = ListingEditorController(kind: ServiceKind.restaurant, listingId: '69ce460f50976c8d2c921f97');
      await c.load();
      final o = c.original! as RestaurantDetail;
      final draft = RestaurantDraft.from(o);
      draft.slots.removeLast();
      draft.seats.last.quantity = '60';
      expect(await c.save(draft.toForm(o)), isTrue);
      final f = multipartFields(h.last);
      expect(jsonDecode(f['removeSlotIds']!), [o.slots.last.id]);
      expect((jsonDecode(f['seats']!) as List).single['quantity'], 60);
      expect(f.containsKey('title'), isFalse);
    });

    test('failure messages: 403 create, 502 upload, field errors', () {
      expect(describeSaveFailure(const ApiFailure(message: 'x', statusCode: 403), ServiceKind.massage, creating: true),
          'Only a massage provider can add this.');
      expect(describeSaveFailure(const ApiFailure(message: 'x', statusCode: 403), ServiceKind.massage, creating: false),
          "You can't edit this listing.");
      expect(describeSaveFailure(const ApiFailure(message: 'Bad gateway', statusCode: 502), ServiceKind.skiHire, creating: true),
          'Upload failed, try again.');
      expect(
          describeSaveFailure(const ApiFailure(message: 'Validation failed', statusCode: 400, fieldErrors: [FieldError('seats', 'seats must be at least 1')]),
              ServiceKind.transport, creating: true),
          'Seats: seats must be at least 1');
      expect(describeSaveFailure(const ApiFailure(message: 'Title is required.', statusCode: 400), ServiceKind.transport, creating: true),
          'Title is required.');
    });

    test('server 400 message reaches saveError', () async {
      registerHarness(Harness((_) => json({'success': false, 'message': 'category: not a Massage sub-category'}, 400)));
      final c = ListingEditorController(kind: ServiceKind.massage);
      final form = MassageDraft(
        categoryId: 'c', title: 'Deep', openTime: '9:00 AM', closeTime: '9:00 PM', serviceArea: 'X', benefits: 'b', recommendations: 'r',
        durations: [DurationDraft(minutes: 60, price: '80')], thumbnail: photo,
      ).toForm();
      expect(await c.save(form), isFalse);
      expect(c.saveError, 'category: not a Massage sub-category');
      expect(c.isSaving, isFalse);
    });
  });

  group('listingIdFromArgs', () {
    test('new and legacy shapes', () {
      expect(listingIdFromArgs({'isEdit': true, 'id': 'a'}), 'a');
      expect(listingIdFromArgs({'isEdit': false, 'id': 'a'}), isNull);
      expect(listingIdFromArgs(null), isNull);
      expect(listingIdFromArgs({'isEdit': true, 'listing': ListingCard.fromJson({'id': 'b'})}), 'b');
      expect(listingIdFromArgs({'isEdit': true, 'hire': _Legacy(id: 'c')}), 'c');
      expect(listingIdFromArgs({'isEdit': true, 'massage': _LegacySid('d')}), 'd');
    });
  });
}

class _Legacy {
  _Legacy({this.id});
  final String? id;
}

class _LegacySid {
  _LegacySid(this.sId);
  final String sId;
}
