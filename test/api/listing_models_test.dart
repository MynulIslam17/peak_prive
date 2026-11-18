import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';

import 'fixtures.dart';

void main() {
  group('ListingCard', () {
    test('parses a real browse card', () {
      final list = fixture('p_hire_my')['data'] as List;
      final card = ListingCard.fromJson(list[1] as Map<String, dynamic>);
      expect(card.id, '6939508f6fd3cd7f26c29698');
      expect(card.kind, ServiceKind.skiHire);
      expect(card.subCategory!.name, 'Ski Essential');
      expect(card.price.amount, 25);
      expect(card.price.unitLabel, 'day');
      expect(card.rating.average, 2);
      expect(card.provider!.name, 'Sushil Hemrom');
      expect(card.isActive, isTrue);
    });

    test('survives an almost empty object', () {
      final card = ListingCard.fromJson({'id': 'x'}, fallbackKind: ServiceKind.massage);
      expect(card.kind, ServiceKind.massage);
      expect(card.title, 'Untitled');
      expect(card.price.amount, 0);
      expect(card.rating.count, 0);
      expect(card.provider, isNull);
      expect(card.subCategory, isNull);
    });

    test('drops a placeholder provider name', () {
      final card = ListingCard.fromJson({
        'id': 'x',
        'category': 'Transport',
        'provider': {'id': 'p', 'name': 'N/A'},
      });
      expect(card.provider!.name, isNull);
      expect(card.provider!.displayName, 'Unknown');
    });
  });

  group('ListingDetail subclasses', () {
    test('ski hire', () {
      final d = ListingDetail.fromJson(fixtureData('hire_detail'));
      expect(d, isA<SkiHireDetail>());
      d as SkiHireDetail;
      expect(d.priceUnit, 'per_day');
      expect(d.extraChargePerHour, 44);
      expect(d.items.single.name, 'aaa');
      expect(d.items.single.quantity, 44);
      expect(d.items.single.photo, isNull); // "" → null
      expect(d.description, isNull);
    });

    test('transport', () {
      final d = ListingDetail.fromJson(fixtureData('transport_detail')) as TransportDetail;
      expect(d.seats, 4);
      expect(d.extraChargePerHour, 6);
      expect(d.price.unit, 'per_trip');
    });

    test('restaurant', () {
      final d = ListingDetail.fromJson(fixtureData('restaurant_detail')) as RestaurantDetail;
      expect(d.serviceFee, 10);
      expect(d.seats.map((s) => s.type), ['VIP', 'Normal']);
      expect(d.seats.first.quantity, 64);
      expect(d.slots, hasLength(5));
      expect(d.slots.first.label, '8:00 AM – 10:30 PM');
      expect(d.isOpenNow, isFalse);
    });

    test('massage', () {
      final d = ListingDetail.fromJson(fixtureData('massage_detail')) as MassageDetail;
      expect(d.durations.single.minutes, 682);
      expect(d.durations.single.label, '11 h 22 min');
      expect(d.benefits, 'nice to have massage');
    });

    test('ski pass', () {
      final d = ListingDetail.fromJson(fixtureData('pass_detail')) as SkiPassDetail;
      expect(d.passType, PassType.premium);
      expect(d.subCategory, isNull);
      expect(d.services, hasLength(3));
      expect(d.updatedAt, isNotNull);
      expect(d.maxPeoplePerBooking, SkiPassDetail.defaultMaxPeople); // not in the old fixture
      final withLimit = ListingDetail.fromJson({...fixtureData('pass_detail'), 'maxPeoplePerBooking': 6}) as SkiPassDetail;
      expect(withLimit.maxPeoplePerBooking, 6);
    });

    test('uses the expected kind when category is missing', () {
      final d = ListingDetail.fromJson({'id': 'a'}, expected: ServiceKind.restaurant);
      expect(d, isA<RestaurantDetail>());
      expect((d as RestaurantDetail).seats, isEmpty);
    });

    test('restaurant accepts the old items/seat/totalQty names', () {
      final d = ListingDetail.fromJson({
        'id': 'a',
        'category': 'Restaurant',
        'items': [
          {'_id': 's', 'seat': 'VIP', 'price': '50', 'totalQty': 3}
        ],
      }) as RestaurantDetail;
      expect(d.seats.single.type, 'VIP');
      expect(d.seats.single.price, 50);
      expect(d.seats.single.quantity, 3);
    });
  });

  test('MassageDuration label falls back to the raw text', () {
    expect(MassageDuration.fromJson({'duration': '60 min', 'minutes': 60, 'price': 80}).label, '1 h');
    expect(MassageDuration.fromJson({'duration': '90 min', 'minutes': 90, 'price': 80}).label, '1 h 30 min');
    expect(MassageDuration.fromJson({'duration': '45 min', 'minutes': 45, 'price': 1}).label, '45 min');
    expect(MassageDuration.fromJson({'duration': 'legacy', 'minutes': null, 'price': 1}).label, 'legacy');
  });

  test('ServiceKind.parse accepts every spelling', () {
    expect(ServiceKind.parse('Ski_Hire'), ServiceKind.skiHire);
    expect(ServiceKind.parse('ski-hire'), ServiceKind.skiHire);
    expect(ServiceKind.parse('ski_pass'), ServiceKind.skiPass);
    expect(ServiceKind.parse('Restaurant'), ServiceKind.restaurant);
    expect(ServiceKind.parse('boat'), isNull);
    expect(ServiceKind.parse(null), isNull);
    expect(ServiceKind.skiHire.isRental, isTrue);
    expect(ServiceKind.massage.isRental, isFalse);
    expect(ServiceKind.skiPass.needsApproval, isFalse);
  });

  test('PassType', () {
    expect(PassType.parse('vip'), PassType.vip);
    expect(PassType.parse('VIP')!.label, 'VIP');
    expect(PassType.parse('gold'), isNull);
  });

  test('CategoryOption reads _id and categoryPhoto', () {
    final list = fixture('cat_ski-hire')['data'] as List;
    final c = CategoryOption.fromJson(list.first as Map<String, dynamic>);
    expect(c.id, isNotEmpty);
    expect(c.name, 'Ski Essential');
    expect(c.photo, startsWith('https://'));
  });
}
