import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/listing_drafts.dart';

import '../api/fixtures.dart';

T detail<T extends ListingDetail>(String name) => ListingDetail.fromJson(fixtureData(name)) as T;

void main() {
  final photo = File('test/fixtures/hire_detail.json');

  group('numbers and clock', () {
    test('parseAmount / parseCount', () {
      expect(parseAmount(' 12,5 '), 12.5);
      expect(parseAmount(''), isNull);
      expect(parseAmount('x'), isNull);
      expect(parseCount('3'), 3);
      expect(parseCount('3.5'), isNull);
    });

    test('formatClock / parseClock round trip', () {
      expect(formatClock(const TimeOfDay(hour: 19, minute: 5)), '7:05 PM');
      expect(formatClock(const TimeOfDay(hour: 0, minute: 0)), '12:00 AM');
      expect(formatClock(const TimeOfDay(hour: 12, minute: 30)), '12:30 PM');
      expect(parseClock('7:05 PM'), const TimeOfDay(hour: 19, minute: 5));
      expect(parseClock('12:00 am'), const TimeOfDay(hour: 0, minute: 0));
      expect(parseClock('21:30'), const TimeOfDay(hour: 21, minute: 30));
      expect(parseClock('7 PM'), const TimeOfDay(hour: 19, minute: 0));
      expect(parseClock('25:00'), isNull);
      expect(parseClock('13:00 PM'), isNull);
      expect(parseClock(''), isNull);
    });

    test('checkSlot: length, order and opening hours (incl. past midnight)', () {
      expect(checkSlot(start: '12:00 PM', end: '2:00 PM', openTime: '10:00 AM', closeTime: '11:00 PM'), isNull);
      expect(checkSlot(start: '9:00 AM', end: '11:00 AM', openTime: '10:00 AM', closeTime: '11:00 PM'), contains('opening hours'));
      expect(checkSlot(start: '10:00 AM', end: '5:00 PM', openTime: null, closeTime: null), 'A slot can be at most 6 hours.');
      expect(checkSlot(start: '1:00 PM', end: '1:00 PM', openTime: null, closeTime: null), contains('same time'));
      expect(checkSlot(start: '11:00 PM', end: '1:00 AM', openTime: '6:00 PM', closeTime: '2:00 AM'), isNull);
      expect(checkSlot(start: '1:00 AM', end: '3:00 AM', openTime: '6:00 PM', closeTime: '2:00 AM'), contains('opening hours'));
      expect(checkSlot(start: '', end: '1:00 AM', openTime: null, closeTime: null), 'Pick a start and end time.');
    });
  });

  group('ski pass', () {
    final original = detail<SkiPassDetail>('pass_detail');

    test('prefill then unchanged → nothing to send', () {
      final d = SkiPassDraft.from(original);
      expect(d.title, 'New Ticket');
      expect(d.price, '220');
      expect(d.passType, PassType.premium);
      expect(d.services, hasLength(3));
      expect(d.toForm(original).isEmpty, isTrue);
    });

    test('only changed fields', () {
      final d = SkiPassDraft.from(original)
        ..price = '250'
        ..passType = PassType.vip;
      expect(d.toForm(original).fields, {'price': '250', 'passType': 'Vip'});
    });

    test('a service edit sends the whole services list', () {
      final d = SkiPassDraft.from(original);
      d.services[0] = const PassService(title: 'Free Parking', description: '10 cars');
      final f = d.toForm(original).fields;
      expect(f.keys, ['services']);
      expect((jsonDecode(f['services']!) as List).first, {'title': 'Free Parking', 'description': '10 cars'});
    });

    test('create sends everything and validates', () {
      final d = SkiPassDraft(title: 'Day', passType: PassType.basic, price: '45', services: [const PassService(title: 'Lifts')], serviceArea: 'X', description: 'Y', thumbnail: photo);
      final f = d.toForm();
      expect(f.validateForCreate(), isEmpty);
      expect(f.fields.keys, containsAll(['title', 'passType', 'price', 'services', 'serviceArea', 'description']));
      expect(SkiPassDraft().toForm().validateForCreate().first, 'Add a title.');
    });
  });

  group('ski hire', () {
    final original = detail<SkiHireDetail>('hire_detail');

    test('prefill', () {
      final d = SkiHireDraft.from(original);
      expect(d.categoryId, original.subCategory!.id);
      expect(d.lateFee, '44');
      expect(d.priceUnit, 'per_day');
      expect(d.items.single.id, '6939508f6fd3cd7f26c29699');
      expect(d.items.single.quantity, '44');
      expect(d.toForm(original).isEmpty, isTrue);
    });

    test('changed late fee and one item quantity only', () {
      final d = SkiHireDraft.from(original)..lateFee = '10';
      d.items.single.quantity = '50';
      final f = d.toForm(original).fields;
      expect(f['extraChargePerHour'], '10');
      expect(jsonDecode(f['items']!), [
        {'id': '6939508f6fd3cd7f26c29699', 'name': 'aaa', 'price': 25, 'quantity': 50}
      ]);
      expect(f.containsKey('removeItemIds'), isFalse);
      expect(f.containsKey('title'), isFalse);
    });

    test('removing an item → removeItemIds; new item with photo → itemPhoto_0', () {
      final d = SkiHireDraft.from(original);
      d.items
        ..clear()
        ..add(HireItemDraft(name: 'Boots', price: '15', quantity: '5', photo: photo));
      expect(d.removedItemIds(original), ['6939508f6fd3cd7f26c29699']);
      final form = d.toForm(original);
      expect(jsonDecode(form.fields['removeItemIds']!), ['6939508f6fd3cd7f26c29699']);
      expect(jsonDecode(form.fields['items']!), [
        {'name': 'Boots', 'price': 15, 'quantity': 5}
      ]);
      expect(form.files.keys, ['itemPhoto_0']);
    });

    test('a new photo on an unchanged item sends that item', () {
      final d = SkiHireDraft.from(original);
      d.items.single.photo = photo;
      final form = d.toForm(original);
      expect((jsonDecode(form.fields['items']!) as List).single['id'], '6939508f6fd3cd7f26c29699');
      expect(form.files.keys, ['itemPhoto_0']);
    });

    test('description can be cleared on edit', () {
      final withDesc = ListingDetail.fromJson({...fixtureData('hire_detail'), 'description': 'Old'}) as SkiHireDetail;
      final d = SkiHireDraft.from(withDesc)..description = '';
      expect(d.toForm(withDesc).fields, {'description': ''});
    });

    test('create: late fee defaults to 0; item rules come from the form', () {
      final d = SkiHireDraft(categoryId: 'c', title: 'Shop', serviceArea: 'X', items: [HireItemDraft(name: 'Skis', price: '30', quantity: '10')], thumbnail: photo);
      final f = d.toForm();
      expect(f.fields['extraChargePerHour'], '0');
      expect(f.fields['priceUnit'], 'per_day');
      expect(f.validateForCreate(), isEmpty);
      final bad = SkiHireDraft(categoryId: 'c', title: 'Shop', serviceArea: 'X', items: [HireItemDraft(name: '1', price: '0', quantity: '0')], thumbnail: photo);
      expect(bad.toForm().validateForCreate(), contains('Item prices must be above 0.'));
    });
  });

  group('transport', () {
    final original = detail<TransportDetail>('transport_detail');

    test('prefill and diff', () {
      final d = TransportDraft.from(original);
      expect(d.seats, '4');
      expect(d.toForm(original).isEmpty, isTrue);
      d.seats = '6';
      // Editing never sends the removed fees.
      expect(d.toForm(original).fields, {'seats': '6'});
    });

    test('create sends 0 for the removed fees', () {
      final d = TransportDraft(categoryId: 'c', title: 'Van', serviceArea: 'X', amount: '120', seats: '7', mileage: '15', lateFee: '0', thumbnail: photo);
      final form = d.toForm();
      expect(form.validateForCreate(), isEmpty);
      expect(form.fields['insuranceFee'], '0');
      expect(form.fields['maintenanceFee'], '0');
    });
  });

  group('restaurant', () {
    final original = detail<RestaurantDetail>('restaurant_detail');

    test('prefill, unchanged → empty', () {
      final d = RestaurantDraft.from(original);
      expect(d.seats.map((s) => s.type), ['VIP', 'Normal']);
      expect(d.slots, hasLength(5));
      expect(d.openTime, '4:32 PM');
      expect(d.toForm(original).isEmpty, isTrue);
    });

    test('seat price change, slot removed, slot added', () {
      final d = RestaurantDraft.from(original);
      d.seats.first.price = '50';
      final removed = d.slots.removeAt(1);
      d.slots.add(SlotDraft(startTime: '6:00 PM', endTime: '8:00 PM'));
      final f = d.toForm(original).fields;
      final seats = jsonDecode(f['seats']!) as List;
      expect(seats.single['id'], '69ce460f50976c8d2c921f98');
      expect(seats.single['price'], 50);
      expect(seats.single['photo'], startsWith('https://')); // keeps the saved photo
      expect(jsonDecode(f['slots']!), [
        {'startTime': '6:00 PM', 'endTime': '8:00 PM'}
      ]);
      expect(jsonDecode(f['removeSlotIds']!), [removed.id]);
      expect(f.containsKey('removeSeatIds'), isFalse);
    });

    test('removing a seat type → removeSeatIds', () {
      final d = RestaurantDraft.from(original);
      d.seats.removeLast();
      expect(jsonDecode(d.toForm(original).fields['removeSeatIds']!), ['69ce460f50976c8d2c921f99']);
    });

    test('slotProblem flags slots outside the hours (the saved data has some)', () {
      final d = RestaurantDraft.from(original);
      expect(d.slotProblem(), isNotNull);
    });

    test('create: new seat photo goes to files[i]', () {
      final d = RestaurantDraft(
        categoryId: 'c', title: 'T', serviceArea: 'X', openTime: '10:00 AM', closeTime: '11:00 PM',
        seats: [SeatDraft(type: 'VIP', price: '80', quantity: '10', photo: photo)],
        slots: [SlotDraft(startTime: '12:00 PM', endTime: '2:00 PM')],
        thumbnail: photo,
      );
      final f = d.toForm();
      expect(f.validateForCreate(), isEmpty);
      expect(f.files.keys, containsAll(['thumbnail', 'files[0]']));
    });
  });

  group('massage', () {
    final original = detail<MassageDetail>('massage_detail');

    test('prefill; unchanged → empty', () {
      final d = MassageDraft.from(original);
      expect(d.durations.single.minutes, 682);
      expect(d.durations.single.duration, '11 hr 22 min');
      expect(d.toForm(original).isEmpty, isTrue);
    });

    test('any duration change sends the full list with ids', () {
      final d = MassageDraft.from(original);
      d.durations.add(DurationDraft(minutes: 60, price: '40'));
      final f = d.toForm(original).fields;
      expect(jsonDecode(f['durations']!), [
        {'id': '69350faa4ccb065ddc691d50', 'duration': '11 hr 22 min', 'price': 36},
        {'duration': '60 min', 'price': 40},
      ]);
      expect(f.keys, ['durations']);
    });

    test('changing a saved length sends "<minutes> min"', () {
      final d = MassageDraft.from(original);
      d.durations.single.minutes = 90;
      expect((jsonDecode(d.toForm(original).fields['durations']!) as List).single['duration'], '90 min');
    });

    test('legacy duration text without minutes is kept as is', () {
      final d = DurationDraft(raw: '1 hour', price: '10');
      expect(d.duration, '1 hour');
      expect(d.label, '1 hour');
      expect(DurationDraft(minutes: 90).label, '1 h 30 min');
    });

    test('create validates duplicates', () {
      final d = MassageDraft(
        categoryId: 'c', title: 'Deep', openTime: '9:00 AM', closeTime: '9:00 PM', serviceArea: 'X', benefits: 'b', recommendations: 'r',
        durations: [DurationDraft(minutes: 60, price: '80'), DurationDraft(minutes: 60, price: '90')],
        thumbnail: photo,
      );
      expect(d.toForm().validateForCreate(), contains('Each duration can be added once.'));
    });
  });
}
