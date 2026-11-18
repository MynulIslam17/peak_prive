import '../json_read.dart';
import 'listing.dart';
import 'service_kind.dart';

/// Booking `status`.
enum BookingStatus {
  /// Paid, waiting for the provider (`approvalDeadline` says until when).
  pending('Pending', 'Waiting for approval'),

  /// Approved, not started.
  confirmed('Confirmed', 'Confirmed'),

  /// Rental handed over, or the service time has started.
  inProgress('InProgress', 'In progress'),
  completed('Completed', 'Completed'),
  cancelled('Cancelled', 'Cancelled'),

  /// A value this app version doesn't know.
  unknown('', 'Unknown');

  const BookingStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static BookingStatus parse(dynamic value) {
    final s = readString(value)?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final v in values) {
      if (v != unknown && v.apiValue.toLowerCase() == s) return v;
    }
    // Older records still use "Active" for an approved/started booking.
    if (s == 'active') return confirmed;
    return unknown;
  }

  bool get isOpen => this == pending || this == confirmed || this == inProgress;
  bool get isFinished => this == completed || this == cancelled;
}

/// What the viewer may do now (`actions`). Draw buttons from these only.
enum BookingAction {
  approve('approve', 'Accept'),
  reject('reject', 'Reject'),
  handOver('hand_over', 'Hand over'),
  markReturned('return', 'Mark as returned'),
  complete('complete', 'Mark as done'),
  cancel('cancel', 'Cancel booking'),
  payLateFee('pay_late_fee', 'Pay late fee'),
  review('review', 'Write a review');

  const BookingAction(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static BookingAction? parse(dynamic value) {
    final s = readString(value);
    for (final a in values) {
      if (a.apiValue == s) return a;
    }
    return null;
  }

  /// `PATCH /booking/:id/<segment>` for the actions that are simple PATCHes.
  String? get pathSegment => switch (this) {
        approve => 'approve',
        reject => 'reject',
        handOver => 'hand-over',
        markReturned => 'return',
        complete => 'complete',
        cancel => 'cancel',
        payLateFee || review => null,
      };

  /// Provider actions (shown on the provider's booking screen).
  bool get isProviderAction =>
      this == approve ||
      this == reject ||
      this == handOver ||
      this == markReturned ||
      this == complete;
}

/// `listing` on a booking: `{id, title, thumbnail, serviceArea}`.
class BookingListing {
  const BookingListing({required this.id, required this.title, this.thumbnail, this.serviceArea});

  factory BookingListing.fromJson(Json? json) => BookingListing(
        id: json == null ? '' : readId(json),
        title: readText(json?['title']) ?? 'Listing removed',
        thumbnail: readString(json?['thumbnail']),
        serviceArea: readText(json?['serviceArea']),
      );

  final String id;
  final String title;
  final String? thumbnail;
  final String? serviceArea;
}

/// Restaurant slot on a booking: `{startTime, endTime}`.
class SlotTime {
  const SlotTime(this.startTime, this.endTime);

  static SlotTime? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return SlotTime(readText(m['startTime']) ?? '', readText(m['endTime']) ?? '');
  }

  final String startTime;
  final String endTime;

  String get label => '$startTime – $endTime';
}

/// `schedule`: `{date, startAt, endAt, time, duration, slot}`.
class BookingSchedule {
  const BookingSchedule({this.date, this.startAt, this.endAt, this.time, this.duration, this.slot});

  factory BookingSchedule.fromJson(Json? json) => BookingSchedule(
        date: readText(json?['date']),
        startAt: readDate(json?['startAt']),
        endAt: readDate(json?['endAt']),
        time: readText(json?['time']),
        duration: readText(json?['duration']),
        slot: SlotTime.maybe(json?['slot']),
      );

  /// Calendar day `YYYY-MM-DD` (resort day).
  final String? date;

  /// Local time.
  final DateTime? startAt;
  final DateTime? endAt;

  /// Massage: resort clock time ("10:30 AM" or "09:48").
  final String? time;

  /// Massage: "60 min".
  final String? duration;

  /// Restaurant.
  final SlotTime? slot;
}

/// Booked item / seat type: `{id, name, quantity, price}`.
class BookingLine {
  const BookingLine({required this.id, required this.name, required this.quantity, required this.price, this.photo});

  factory BookingLine.fromJson(Json json) => BookingLine(
        id: readId(json),
        name: readText(json['name']) ?? 'Item',
        quantity: readInt(json['quantity']) ?? 1,
        price: readNum(json['price']) ?? 0,
        photo: readText(json['photo']) ?? readText(json['image']),
      );

  final String id;
  final String name;
  final int quantity;
  final num price;

  /// Item photo, when the server sends one.
  final String? photo;
}

/// Live banner state for rentals.
enum TimerState {
  startsIn('starts_in'),
  pickupDue('pickup_due'),
  returnIn('return_in'),
  overdue('overdue');

  const TimerState(this.apiValue);
  final String apiValue;

  static TimerState? parse(dynamic v) {
    final s = readString(v);
    for (final t in values) {
      if (t.apiValue == s) return t;
    }
    return null;
  }
}

/// `timer: {state, minutes, lateFee}` (Ski Hire, Transport).
///
/// `minutes` was computed when the response was built; [minutesNow] counts it
/// forward from [receivedAt].
class BookingTimer {
  BookingTimer({required this.state, required this.minutes, required this.lateFee, DateTime? receivedAt})
      : receivedAt = receivedAt ?? DateTime.now();

  static BookingTimer? maybe(dynamic json, {DateTime? receivedAt}) {
    final m = readMap(json);
    if (m == null) return null;
    final state = TimerState.parse(m['state']);
    if (state == null) return null;
    return BookingTimer(
      state: state,
      minutes: readInt(m['minutes']) ?? 0,
      lateFee: readNum(m['lateFee']) ?? 0,
      receivedAt: receivedAt,
    );
  }

  final TimerState state;
  final int minutes;

  /// Late fee so far (only while overdue).
  final num lateFee;
  final DateTime receivedAt;

  /// A countdown (`starts_in` / `return_in`) that has reached zero: the
  /// server has moved on to the next state, so the booking should be reloaded.
  bool hasRunOut([DateTime? now]) {
    final counting = state == TimerState.startsIn || state == TimerState.returnIn;
    if (!counting) return false;
    return (now ?? DateTime.now()).difference(receivedAt) >= Duration(minutes: minutes);
  }

  /// Minutes now: counting down for `starts_in`/`return_in`, up otherwise.
  /// Never below zero.
  int minutesNow([DateTime? now]) {
    final elapsed = (now ?? DateTime.now()).difference(receivedAt).inMinutes;
    final counting = state == TimerState.startsIn || state == TimerState.returnIn;
    final v = counting ? minutes - elapsed : minutes + elapsed;
    return v < 0 ? 0 : v;
  }
}

enum LateFeeStatus {
  due('due'),
  paid('paid'),
  unknown('');

  const LateFeeStatus(this.apiValue);
  final String apiValue;

  static LateFeeStatus parse(dynamic v) {
    final s = readString(v)?.toLowerCase();
    for (final x in values) {
      if (x != unknown && x.apiValue == s) return x;
    }
    return unknown;
  }
}

/// `lateFee: {hours, amount, status}`.
class LateFee {
  const LateFee({required this.hours, required this.amount, required this.status});

  static LateFee? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return LateFee(
      hours: readNum(m['hours']) ?? 0,
      amount: readNum(m['amount']) ?? 0,
      status: LateFeeStatus.parse(m['status']),
    );
  }

  final num hours;
  final num amount;
  final LateFeeStatus status;

  bool get isDue => status == LateFeeStatus.due && amount > 0;
}

/// Detail `contact: {phoneNumber, address, destination}`.
class BookingContact {
  const BookingContact({this.phoneNumber, this.address, this.destination});

  static BookingContact? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return BookingContact(
      phoneNumber: readText(m['phoneNumber']),
      address: readText(m['address']),
      destination: readText(m['destination']),
    );
  }

  final String? phoneNumber;
  final String? address;
  final String? destination;

  bool get isEmpty => phoneNumber == null && address == null && destination == null;
}

/// Detail `timeline`.
class BookingTimeline {
  const BookingTimeline({
    this.bookedAt,
    this.approvedAt,
    this.handedOverAt,
    this.returnedAt,
    this.completedAt,
    this.cancelledAt,
  });

  static BookingTimeline? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return BookingTimeline(
      bookedAt: readDate(m['bookedAt']),
      approvedAt: readDate(m['approvedAt']),
      handedOverAt: readDate(m['handedOverAt']),
      returnedAt: readDate(m['returnedAt']),
      completedAt: readDate(m['completedAt']),
      cancelledAt: readDate(m['cancelledAt']),
    );
  }

  final DateTime? bookedAt;
  final DateTime? approvedAt;
  final DateTime? handedOverAt;
  final DateTime? returnedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
}

/// Who cancelled.
enum CancelledBy { user, provider, admin, system, unknown }

/// Detail `cancellation: {by, reason, refundAmount}`.
class Cancellation {
  const Cancellation({required this.by, this.reason, this.refundAmount});

  static Cancellation? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    final by = readString(m['by'])?.toLowerCase();
    return Cancellation(
      by: CancelledBy.values.firstWhere(
        (c) => c.name == by,
        orElse: () => CancelledBy.unknown,
      ),
      reason: readText(m['reason']),
      refundAmount: readNum(m['refundAmount']),
    );
  }

  final CancelledBy by;
  final String? reason;
  final num? refundAmount;

  /// "Cancelled by you", "Declined by the provider"… from the viewer's side.
  String describe({required bool viewerIsProvider}) => switch (by) {
        CancelledBy.user => viewerIsProvider ? 'Cancelled by the guest' : 'Cancelled by you',
        CancelledBy.provider => viewerIsProvider ? 'Declined by you' : 'Declined by the provider',
        CancelledBy.admin => 'Cancelled by support',
        CancelledBy.system => 'Cancelled automatically (not approved in time)',
        CancelledBy.unknown => 'Cancelled',
      };
}

enum EarningStatus { pending, paid, none, unknown }

/// Provider detail `earning: {gross, platformFee, net, status}`.
class Earning {
  const Earning({required this.gross, this.platformFee, this.net, required this.status, this.lateFee, this.serviceFee});

  static Earning? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    final s = readString(m['status'])?.toLowerCase();
    return Earning(
      gross: readNum(m['gross']) ?? 0,
      platformFee: readNum(m['platformFee']),
      net: readNum(m['net']),
      serviceFee: readNum(m['serviceFee']),
      status: EarningStatus.values.firstWhere((e) => e.name == s, orElse: () => EarningStatus.unknown),
      lateFee: Earning.maybe(m['lateFee']),
    );
  }

  /// The booking price alone (a late fee is in [lateFee]).
  final num gross;

  /// Everything the platform keeps: commission plus [serviceFee].
  /// Null until the booking completes.
  final num? platformFee;

  /// Restaurant booking fee; it goes to the platform in full and is part of
  /// [platformFee]. Null for services without one.
  final num? serviceFee;

  /// The platform's commission alone, when [platformFee] can be split.
  num? get commission {
    final fee = platformFee;
    if (fee == null) return null;
    final service = serviceFee ?? 0;
    return service > 0 && service <= fee ? fee - service : fee;
  }

  /// Whether [platformFee] is shown as service fee + commission.
  bool get splitsServiceFee {
    final service = serviceFee ?? 0;
    return service > 0 && (platformFee == null || service <= platformFee!);
  }
  final num? net;
  final EarningStatus status;

  /// The provider's share of a late fee: `earning.lateFee {gross, platformFee,
  /// net, status}`. Null when there is none, or on servers that don't send it.
  final Earning? lateFee;
}

/// Cancel response `refund: {amount, percent, status: refunded|pending}`.
class RefundInfo {
  const RefundInfo({required this.amount, this.percent, this.status});

  static RefundInfo? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return RefundInfo(
      amount: readNum(m['amount']) ?? 0,
      percent: readNum(m['percent']),
      status: readString(m['status'])?.toLowerCase(),
    );
  }

  final num amount;
  final num? percent;

  /// `refunded` (Stripe accepted it) or `pending` (a server job finishes it
  /// within minutes). Null on older servers.
  final String? status;

  bool get isDone => status == 'refunded';
}

/// Provider/admin detail `dispute: {status, amount, reason}`.
class Dispute {
  const Dispute({this.status, this.amount, this.reason});

  static Dispute? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return Dispute(status: readText(m['status']), amount: readNum(m['amount']), reason: readText(m['reason']));
  }

  final String? status;
  final num? amount;
  final String? reason;
}

/// A booking: list card, or detail when [isDetail] (`GET /booking/:id`).
class Booking {
  Booking({
    required this.id,
    required this.kind,
    required this.status,
    required this.actions,
    required this.listing,
    required this.schedule,
    required this.items,
    required this.total,
    required this.currency,
    this.people,
    this.ticketNumber,
    this.approvalDeadline,
    this.timer,
    this.lateFee,
    this.provider,
    this.customer,
    this.createdAt,
    this.isDetail = false,
    this.contact,
    this.timeline,
    this.cancellation,
    this.noShow = false,
    this.refundedAmount = 0,
    this.refund,
    this.dispute,
    this.earning,
  });

  factory Booking.fromJson(Json json, {DateTime? receivedAt}) {
    final price = readMap(json['price']);
    return Booking(
      id: readId(json),
      kind: ServiceKind.parse(json['category']) ?? ServiceKind.skiHire,
      status: BookingStatus.parse(json['status']),
      actions: List.unmodifiable(
        (json['actions'] is List ? json['actions'] as List : const [])
            .map(BookingAction.parse)
            .whereType<BookingAction>()
            .toSet(),
      ),
      listing: BookingListing.fromJson(readMap(json['listing'])),
      schedule: BookingSchedule.fromJson(readMap(json['schedule'])),
      people: readInt(json['people']),
      items: readList(json['items'], BookingLine.fromJson),
      total: readNum(price?['total']) ?? 0,
      currency: readString(price?['currency']) ?? 'eur',
      ticketNumber: readText(json['ticketNumber']),
      approvalDeadline: readDate(json['approvalDeadline']),
      timer: BookingTimer.maybe(json['timer'], receivedAt: receivedAt),
      lateFee: LateFee.maybe(json['lateFee']),
      provider: PersonRef.maybe(json['provider']),
      customer: PersonRef.maybe(json['customer']),
      createdAt: readDate(json['createdAt']),
      isDetail: json.containsKey('timeline') || json.containsKey('contact'),
      contact: BookingContact.maybe(json['contact']),
      timeline: BookingTimeline.maybe(json['timeline']),
      cancellation: Cancellation.maybe(json['cancellation']),
      noShow: readBool(json['noShow']) ?? false,
      refundedAmount: readNum(json['refundedAmount']) ?? 0,
      refund: RefundInfo.maybe(json['refund']),
      dispute: Dispute.maybe(json['dispute']),
      earning: Earning.maybe(json['earning']),
    );
  }

  final String id;
  final ServiceKind kind;
  final BookingStatus status;
  final List<BookingAction> actions;
  final BookingListing listing;
  final BookingSchedule schedule;

  /// Persons (ski pass), passengers (transport) or seats.
  final int? people;
  final List<BookingLine> items;
  final num total;
  final String currency;

  /// Ski pass.
  final String? ticketNumber;

  /// Pending only.
  final DateTime? approvalDeadline;
  final BookingTimer? timer;
  final LateFee? lateFee;

  /// Set in customer responses.
  final PersonRef? provider;

  /// Set in provider responses.
  final PersonRef? customer;
  final DateTime? createdAt;

  // ── detail only ──
  final bool isDetail;
  final BookingContact? contact;
  final BookingTimeline? timeline;
  final Cancellation? cancellation;

  /// Rental never picked up.
  final bool noShow;
  final num refundedAmount;

  /// Returned by the cancel action.
  final RefundInfo? refund;
  final Dispute? dispute;

  /// Provider only.
  final Earning? earning;

  bool can(BookingAction a) => actions.contains(a);

  /// The other party from the viewer's side.
  PersonRef? get counterpart => customer ?? provider;

  bool get isOverdue => timer?.state == TimerState.overdue;

  /// Total quantity of items/seats.
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
}
