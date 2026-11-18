import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';

import 'fixtures.dart';

void main() {
  group('Booking (customer detail)', () {
    final b = Booking.fromJson(fixtureData('u_booking_detail'), receivedAt: DateTime(2026, 11, 16, 9));

    test('core fields', () {
      expect(b.id, '6afa86679a13dd70cc0c8cb8');
      expect(b.kind, ServiceKind.skiHire);
      expect(b.status, BookingStatus.confirmed);
      expect(b.actions, [BookingAction.cancel]);
      expect(b.listing.title, 'sushilaaaaaa');
      expect(b.total, 175);
      expect(b.currency, 'eur');
      expect(b.items.single.quantity, 1);
      expect(b.itemCount, 1);
    });

    test('is a detail with contact and timeline', () {
      expect(b.isDetail, isTrue);
      expect(b.contact!.address, 'demaraa');
      expect(b.contact!.destination, isNull);
      expect(b.timeline!.bookedAt, isNotNull);
      expect(b.timeline!.handedOverAt, isNull);
      expect(b.cancellation, isNull);
      expect(b.noShow, isFalse);
      expect(b.refundedAmount, 0);
    });

    test('customer sees the provider, not a customer', () {
      expect(b.provider!.name, 'Sushil Hemrom');
      expect(b.customer, isNull);
      expect(b.counterpart!.name, 'Sushil Hemrom');
      expect(b.earning, isNull);
    });

    test('schedule converted to local time', () {
      expect(b.schedule.startAt!.toUtc(), DateTime.utc(2026, 11, 19, 3));
      expect(b.schedule.endAt!.toUtc(), DateTime.utc(2026, 11, 26, 3));
      expect(b.schedule.date, '2026-11-19');
    });

    test('timer counts down from when it was received', () {
      final t = b.timer!;
      expect(t.state, TimerState.startsIn);
      expect(t.minutes, 3977);
      expect(t.minutesNow(DateTime(2026, 11, 16, 10)), 3917);
      expect(t.minutesNow(DateTime(2027)), 0); // never negative
    });
  });

  test('provider detail has customer, earning and provider actions', () {
    final b = Booking.fromJson(fixtureData('p_booking_detail'));
    expect(b.customer!.name, 'Azaan');
    expect(b.provider, isNull);
    expect(b.actions, [BookingAction.reject, BookingAction.handOver]);
    expect(b.actions.every((a) => a.isProviderAction), isTrue);
    expect(b.earning!.gross, 175);
    expect(b.earning!.net, isNull);
    expect(b.earning!.status, EarningStatus.pending);
  });

  test('every category in the customer list parses', () {
    final list = (fixture('u_all')['data'] as List).cast<Map<String, dynamic>>();
    final bookings = list.map(Booking.fromJson).toList();
    expect(bookings, hasLength(list.length));
    expect(bookings.any((b) => b.status == BookingStatus.unknown), isFalse);

    final pass = bookings.firstWhere((b) => b.kind == ServiceKind.skiPass);
    expect(pass.ticketNumber, startsWith('TKT-'));
    expect(pass.people, 3);
    expect(pass.isDetail, isFalse);

    final massage = bookings.firstWhere((b) => b.kind == ServiceKind.massage);
    expect(massage.schedule.time, isNotNull);
    expect(massage.schedule.duration, isNotNull);

    final restaurant = bookings.firstWhere((b) => b.kind == ServiceKind.restaurant);
    expect(restaurant.schedule.slot, isNotNull);
    expect(restaurant.items, isNotEmpty);
  });

  group('status and actions', () {
    test('parse statuses, including legacy Active and unknown values', () {
      expect(BookingStatus.parse('InProgress'), BookingStatus.inProgress);
      expect(BookingStatus.parse('inprogress'), BookingStatus.inProgress);
      expect(BookingStatus.parse('In Progress'), BookingStatus.inProgress);
      expect(BookingStatus.parse('Active'), BookingStatus.confirmed);
      expect(BookingStatus.parse('Weird'), BookingStatus.unknown);
      expect(BookingStatus.parse(null), BookingStatus.unknown);
      expect(BookingStatus.pending.isOpen, isTrue);
      expect(BookingStatus.cancelled.isFinished, isTrue);
    });

    test('unknown and duplicate actions are dropped', () {
      final b = Booking.fromJson({
        'id': 'x',
        'status': 'Pending',
        'actions': ['approve', 'teleport', 'approve', 7, null, 'reject'],
      });
      expect(b.actions, [BookingAction.approve, BookingAction.reject]);
      expect(b.can(BookingAction.approve), isTrue);
      expect(b.can(BookingAction.cancel), isFalse);
    });

    test('action paths', () {
      expect(BookingAction.handOver.pathSegment, 'hand-over');
      expect(BookingAction.markReturned.pathSegment, 'return');
      expect(BookingAction.payLateFee.pathSegment, isNull);
      expect(BookingAction.review.pathSegment, isNull);
      expect(BookingAction.parse('pay_late_fee'), BookingAction.payLateFee);
    });
  });

  test('a minimal booking does not crash', () {
    final b = Booking.fromJson({'id': 'x'});
    expect(b.status, BookingStatus.unknown);
    expect(b.listing.title, 'Listing removed');
    expect(b.actions, isEmpty);
    expect(b.total, 0);
    expect(b.timer, isNull);
    expect(b.counterpart, isNull);
  });

  group('late fee, cancellation, refund', () {
    final b = Booking.fromJson({
      'id': 'x',
      'category': 'Transport',
      'status': 'Completed',
      'actions': ['pay_late_fee'],
      'timer': {'state': 'overdue', 'minutes': 70, 'lateFee': 50},
      'lateFee': {'hours': 2, 'amount': 50, 'status': 'due'},
      'cancellation': {'by': 'system', 'reason': '', 'refundAmount': 25},
      'refund': {'amount': 22.5, 'percent': 90},
      'timeline': {'handedOverAt': '2026-11-16T08:00:00Z'},
    }, receivedAt: DateTime(2026, 11, 16, 10));

    test('late fee due', () {
      expect(b.lateFee!.isDue, isTrue);
      expect(b.lateFee!.hours, 2);
      expect(b.isOverdue, isTrue);
      expect(b.timer!.minutesNow(DateTime(2026, 11, 16, 10, 30)), 100); // counts up
    });

    test('paid late fee is not due', () {
      expect(LateFee.maybe({'amount': 50, 'status': 'paid'})!.isDue, isFalse);
      expect(LateFee.maybe({'amount': 0, 'status': 'due'})!.isDue, isFalse);
      expect(LateFee.maybe(null), isNull);
    });

    test('cancellation wording from both sides', () {
      expect(b.cancellation!.by, CancelledBy.system);
      expect(b.cancellation!.reason, isNull);
      expect(b.cancellation!.refundAmount, 25);
      final byProvider = Cancellation.maybe({'by': 'provider'})!;
      expect(byProvider.describe(viewerIsProvider: false), 'Declined by the provider');
      expect(byProvider.describe(viewerIsProvider: true), 'Declined by you');
      expect(Cancellation.maybe({'by': 'alien'})!.by, CancelledBy.unknown);
    });

    test('refund info', () {
      expect(b.refund!.amount, 22.5);
      expect(b.refund!.percent, 90);
    });

    test('unknown timer state is ignored', () {
      expect(BookingTimer.maybe({'state': 'warp', 'minutes': 1}), isNull);
    });
  });

  test('provider dashboard', () {
    final d = ProviderDashboard.fromJson(fixtureData('p_dashboard'));
    expect(d.bookings.requests, 1);
    expect(d.bookings.completed, 3);
    expect(d.earnings.earned, 20);
    expect(d.earnings.platformFees, 5);
    expect(d.listings, 11);
    expect(d.today, isNotEmpty);
    expect(d.recent.first.status, BookingStatus.pending);
    expect(ProviderDashboard.fromJson({}).bookings.total, 0);
  });

  test('availability for hire and restaurant', () {
    final hire = Availability.fromJson(fixtureData('hire_avail'));
    expect(hire.items.single.available, 44);
    expect(hire.availableFor('6939508f6fd3cd7f26c29699'), 44);
    expect(hire.availableFor('nope'), 0);

    final rest = Availability.fromJson(fixtureData('rest_avail'));
    expect(rest.slots, isNotEmpty);
    final slot = rest.slots.first;
    expect(slot.isBookable, isTrue);
    expect(slot.freeSeats, 64 + 58);
    expect(slot.seat('69ce460f50976c8d2c921f98')!.type, 'VIP');

    final past = SlotAvailability.fromJson({'slotId': 's', 'isPast': true, 'seats': [{'itemId': 'a', 'available': 3}]});
    expect(past.isBookable, isFalse);
    final full = SlotAvailability.fromJson({'slotId': 's', 'seats': [{'itemId': 'a', 'available': -2}]});
    expect(full.seats.single.available, 0);
    expect(full.isBookable, isFalse);
  });

  test('transport availability reason', () {
    final out = Availability.fromJson({'available': false, 'reason': 'not_returned'});
    expect(out.available, isFalse);
    expect(out.notReturned, isTrue);
    final taken = Availability.fromJson({'available': false});
    expect(taken.notReturned, isFalse);
    expect(Availability.fromJson({'available': true}).reason, isNull);
  });

  test('wallet, withdrawals and payments', () {
    final w = WalletAccount.fromJson(fixtureData('p_account'));
    expect(w.balance, 565808);
    expect(w.accounts.single.card, '•••• 5458');

    final list = (fixture('p_withdraw')['data'] as List).cast<Map<String, dynamic>>();
    final ws = list.map(Withdrawal.fromJson).toList();
    expect(ws.first.status, WithdrawalStatus.rejected);
    expect(ws.last.status, WithdrawalStatus.pending);

    final p = PaymentRecord.fromJson({'id': 'p', 'status': 'Partially_Refunded', 'purpose': 'late_fee', 'amount': '10'});
    expect(p.status, PaymentStatus.partiallyRefunded);
    expect(p.isLateFee, isTrue);
    expect(p.amount, 10);
  });

  test('notification', () {
    final n = AppNotification.fromJson({
      'id': 'n',
      'title': 'Booking approved',
      'event': 'booking.approved',
      'bookingId': 'b1',
      'isRead': false,
    });
    expect(n.bookingId, 'b1');
    expect(n.description, '');
    expect(n.copyWith(isRead: true).isRead, isTrue);
    expect(AppNotification.fromJson({'id': 'n', 'event': null}).event, isNull);
  });

  test('earning.lateFee: parsed when sent, null on older servers', () {
    final e = Earning.maybe({
      'gross': 38, 'platformFee': 7.6, 'net': 30.4, 'status': 'paid',
      'lateFee': {'gross': 10, 'platformFee': 2, 'net': 8, 'status': 'paid'},
    })!;
    expect(e.net, 30.4);
    expect(e.lateFee!.net, 8);
    expect(e.lateFee!.status, EarningStatus.paid);
    expect(Earning.maybe({'gross': 38, 'net': 30.4, 'status': 'paid'})!.lateFee, isNull);
  });

  test('earning.serviceFee: restaurant fee split out of the platform share', () {
    final e = Earning.maybe({'gross': 65, 'serviceFee': 5, 'platformFee': 17, 'net': 48, 'status': 'paid'})!;
    expect(e.serviceFee, 5);
    expect(e.splitsServiceFee, isTrue);
    expect(e.commission, 12);
    expect(e.gross - e.serviceFee! - e.commission!, e.net);

    // Before completion: fee known, commission not yet.
    final pending = Earning.maybe({'gross': 65, 'serviceFee': 5, 'status': 'pending'})!;
    expect(pending.splitsServiceFee, isTrue);
    expect(pending.commission, isNull);

    // Other services, and a fee larger than what the platform kept: no split.
    final plain = Earning.maybe({'gross': 80, 'platformFee': 16, 'net': 64, 'status': 'paid'})!;
    expect(plain.splitsServiceFee, isFalse);
    expect(plain.commission, 16);
    final late = Earning.maybe({'gross': 65, 'serviceFee': 5, 'platformFee': 1.7, 'net': 4.8, 'status': 'paid'})!;
    expect(late.splitsServiceFee, isFalse);
    expect(late.commission, 1.7);
  });

  test('massage availability: day slots with places left', () {
    final a = Availability.fromJson({
      'capacity': 2,
      'slots': [
        {'time': '9:00 AM', 'startAt': '2026-11-18T08:00:00.000Z', 'left': 2, 'available': true, 'isPast': false},
        {'time': '9:30 AM', 'left': 0, 'available': false, 'isPast': false},
      ],
    });
    expect(a.capacity, 2);
    expect(a.slots, isEmpty); // not restaurant slots
    expect(a.sessions.map((s) => '${s.time} ${s.left} ${s.available}'), ['9:00 AM 2 true', '9:30 AM 0 false']);
    final r = Availability.fromJson({
      'slots': [
        {'slotId': 's1', 'startTime': '12:00', 'endTime': '14:00', 'seats': []},
      ],
    });
    expect(r.slots, hasLength(1));
    expect(r.sessions, isEmpty);
  });
}
