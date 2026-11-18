import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';

void main() {
  final photo = File('test/fixtures/hire_detail.json'); // any existing file

  test('ski pass create form', () {
    final f = ListingForm.skiPass(
      title: ' Day pass ',
      passType: PassType.vip,
      price: 45,
      services: const [PassService(title: 'Lifts', description: 'All'), PassService(title: '  ')],
      serviceArea: 'Courchevel',
      description: 'One day',
      thumbnail: photo,
    );
    expect(f.fields['title'], 'Day pass');
    expect(f.fields['passType'], 'Vip');
    expect(jsonDecode(f.fields['services']!), [
      {'title': 'Lifts', 'description': 'All'}
    ]);
    expect(f.files.keys, ['file']);
    expect(f.validateForCreate(), isEmpty);
  });

  test('update form sends only what changed', () {
    final f = ListingForm.skiPass(price: 55);
    expect(f.fields, {'price': '55'});
    expect(f.files, isEmpty);
    expect(f.validateForCreate(), isNotEmpty);
  });

  test('ski hire items, photos and removals', () {
    final f = ListingForm.skiHire(
      categoryId: 'c',
      title: 'Alpine',
      serviceArea: 'X',
      priceUnit: 'per_day',
      extraChargePerHour: 5,
      items: [
        const HireItemInput(id: 'i1', name: 'Skis', price: 30, quantity: 10),
        HireItemInput(name: 'Boots', price: 15, quantity: 5, photo: photo),
      ],
      removeItemIds: const ['old'],
      thumbnail: photo,
    );
    final items = jsonDecode(f.fields['items']!) as List;
    expect(items.first, {'id': 'i1', 'name': 'Skis', 'price': 30, 'quantity': 10});
    expect((items.last as Map).containsKey('id'), isFalse);
    expect(f.files.keys, containsAll(['thumbnail', 'itemPhoto_1']));
    expect(f.files.containsKey('itemPhoto_0'), isFalse);
    expect(jsonDecode(f.fields['removeItemIds']!), ['old']);
    expect(f.validateForCreate(), isEmpty);
  });

  test('ski hire item rules', () {
    final f = ListingForm.skiHire(
      categoryId: 'c',
      title: 't',
      serviceArea: 's',
      items: const [HireItemInput(name: '1', price: 0, quantity: 0)],
      thumbnail: photo,
    );
    expect(f.validateForCreate(), containsAll([
      'Item names need at least 2 characters, with letters.',
      'Item prices must be above 0.',
      'Item quantities must be at least 1.',
    ]));
  });

  test('transport create form', () {
    final ok = ListingForm.transport(
      categoryId: 'c', title: 'Van', serviceArea: 'X', amount: 120, seats: 7, mileage: '15 km/l',
      extraChargePerHour: 0, insuranceFee: 0, maintenanceFee: 0, thumbnail: photo,
    );
    expect(ok.validateForCreate(), isEmpty);
    expect(ok.fields['insuranceFee'], '0');
    final missing = ListingForm.transport(categoryId: 'c', title: 'Van', serviceArea: 'X', amount: 120, seats: 0, mileage: 'm', thumbnail: photo);
    expect(missing.validateForCreate(), contains('Enter at least 1 seat.'));
    expect(missing.validateForCreate().where((m) => m.contains('insurance')), isEmpty);
  });

  test('restaurant seats, slots and photos', () {
    final f = ListingForm.restaurant(
      categoryId: 'c', title: 'Le Chalet', serviceArea: 'X', openTime: '10:00 AM', closeTime: '11:00 PM',
      seats: [
        SeatInput(type: 'VIP', price: 80, quantity: 10, photo: photo),
        const SeatInput(id: 's2', type: 'Normal', price: 40, quantity: 30, photoUrl: 'https://x/n.png'),
      ],
      slots: const [SlotInput(startTime: '12:00 PM', endTime: '2:00 PM')],
      removeSlotIds: const ['old'],
      thumbnail: photo,
    );
    final seats = jsonDecode(f.fields['seats']!) as List;
    expect((seats.first as Map).containsKey('photo'), isFalse);
    expect((seats.last as Map)['photo'], 'https://x/n.png');
    expect(f.files.keys, containsAll(['thumbnail', 'files[0]']));
    expect(f.validateForCreate(), isEmpty);

    final dup = ListingForm.restaurant(
      categoryId: 'c', title: 't', serviceArea: 's', openTime: 'a', closeTime: 'b',
      seats: [SeatInput(type: 'VIP', price: 1, quantity: 1, photo: photo), SeatInput(type: 'vip', price: 1, quantity: 1, photo: photo)],
      slots: const [SlotInput(startTime: 'a', endTime: 'b')],
      thumbnail: photo,
    );
    expect(dup.validateForCreate(), ['Each seat type can be added once.']);
  });

  test('massage durations', () {
    final f = ListingForm.massage(
      categoryId: 'c', title: 'Deep', openTime: '9:00 AM', closeTime: '9:00 PM', serviceArea: 'X',
      benefits: 'b', recommendations: 'r',
      durations: const [DurationInput(duration: '60 min', price: 80), DurationInput(id: 'd2', duration: '90', price: 120)],
      thumbnail: photo,
    );
    expect(jsonDecode(f.fields['durations']!), [
      {'duration': '60 min', 'price': 80},
      {'id': 'd2', 'duration': '90', 'price': 120},
    ]);
    expect(f.validateForCreate(), isEmpty);
    final dup = ListingForm.massage(
      categoryId: 'c', title: 'Deep', openTime: 'a', closeTime: 'b', serviceArea: 'X', benefits: 'b', recommendations: 'r',
      durations: const [DurationInput(duration: '60 min', price: 80), DurationInput(duration: '60 MIN', price: 0)],
      thumbnail: photo,
    );
    expect(dup.validateForCreate(), containsAll(['Each duration can be added once.', 'Duration prices must be above 0.']));
  });

  test('massage capacity is sent and checked', () {
    expect(ListingForm.massage(capacity: 3).fields['capacity'], '3');
    expect(ListingForm.massage().fields.containsKey('capacity'), isFalse);
  });
}
