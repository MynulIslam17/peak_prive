import '../json_read.dart';
import 'service_kind.dart';

/// `{id, name, photo, email?, phone?}`: listing owner, booking provider or
/// customer, review author.
class PersonRef {
  const PersonRef({
    required this.id,
    this.name,
    this.photo,
    this.email,
    this.phone,
  });

  factory PersonRef.fromJson(Json json) => PersonRef(
        id: readId(json),
        name: readText(json['name']) ?? readText(json['fullName']),
        photo: readString(json['photo']) ?? readString(json['profileUrl']),
        email: readText(json['email']),
        phone: readText(json['phone']) ?? readText(json['phoneNumber']),
      );

  static PersonRef? maybe(dynamic json) {
    final m = readMap(json);
    return m == null ? null : PersonRef.fromJson(m);
  }

  final String id;
  final String? name;
  final String? photo;
  final String? email;
  final String? phone;

  String get displayName => name ?? 'Unknown';
}

/// `price: {amount, unit}`. `unit`: per_person, per_day, per_hour, per_rental,
/// per_trip, per_seat, per_session.
class Price {
  const Price({required this.amount, required this.unit});

  factory Price.fromJson(Json? json) => Price(
        amount: readNum(json?['amount']) ?? 0,
        unit: readString(json?['unit']) ?? '',
      );

  final num amount;
  final String unit;

  /// "/ day", "/ person"…; empty for an unknown unit.
  String get unitLabel => priceUnitLabel(unit);
}

String priceUnitLabel(String unit) {
  switch (unit) {
    case 'per_person':
      return 'person';
    case 'per_day':
      return 'day';
    case 'per_hour':
      return 'hour';
    case 'per_rental':
      return 'rental';
    case 'per_trip':
      return 'trip';
    case 'per_seat':
      return 'seat';
    case 'per_session':
      return 'session';
    default:
      return '';
  }
}

/// `rating: {average, count}`.
class RatingSummary {
  const RatingSummary({required this.average, required this.count});

  factory RatingSummary.fromJson(Json? json) => RatingSummary(
        average: readDouble(json?['average']) ?? 0,
        count: readInt(json?['count']) ?? 0,
      );

  static const empty = RatingSummary(average: 0, count: 0);

  final double average;
  final int count;
}

/// Sub-category on a listing: `{id, name, photo}`.
class SubCategory {
  const SubCategory({required this.id, required this.name, this.photo});

  factory SubCategory.fromJson(Json json) => SubCategory(
        id: readId(json),
        name: readText(json['name']) ?? '',
        photo: readString(json['photo']) ?? readString(json['categoryPhoto']),
      );

  final String id;
  final String name;
  final String? photo;
}

/// Ski pass type.
enum PassType {
  basic('Basic'),
  vip('Vip'),
  premium('Premium');

  const PassType(this.apiValue);
  final String apiValue;

  static PassType? parse(dynamic value) {
    final s = readString(value)?.toLowerCase();
    for (final t in values) {
      if (t.apiValue.toLowerCase() == s) return t;
    }
    return null;
  }

  String get label => this == vip ? 'VIP' : apiValue;
}

/// A listing as it appears in lists (browse and "my listings").
class ListingCard {
  const ListingCard({
    required this.id,
    required this.kind,
    required this.title,
    required this.price,
    required this.rating,
    required this.isActive,
    this.subCategory,
    this.thumbnail,
    this.serviceArea,
    this.provider,
    this.passType,
  });

  factory ListingCard.fromJson(Json json, {ServiceKind? fallbackKind}) =>
      ListingCard(
        id: readId(json),
        kind: ServiceKind.parse(json['category']) ??
            fallbackKind ??
            ServiceKind.skiHire,
        subCategory: _subCategory(json['subCategory']),
        title: readText(json['title']) ?? 'Untitled',
        thumbnail: readString(json['thumbnail']),
        serviceArea: readText(json['serviceArea']),
        price: Price.fromJson(readMap(json['price'])),
        rating: RatingSummary.fromJson(readMap(json['rating'])),
        provider: PersonRef.maybe(json['provider']),
        isActive: readBool(json['isActive']) ?? true,
        passType: PassType.parse(json['passType']),
      );

  final String id;
  final ServiceKind kind;
  final SubCategory? subCategory;
  final String title;
  final String? thumbnail;
  final String? serviceArea;
  final Price price;
  final RatingSummary rating;
  final PersonRef? provider;
  final bool isActive;

  /// Ski pass only.
  final PassType? passType;
}

SubCategory? _subCategory(dynamic json) {
  final m = readMap(json);
  return m == null ? null : SubCategory.fromJson(m);
}

/// `GET /<service>/:id`. Card fields plus the service's own fields;
/// use the subclass for those (`switch (detail) { SkiHireDetail d => … }`).
sealed class ListingDetail extends ListingCard {
  ListingDetail(Json json, {required ServiceKind kind})
      : description = readText(json['description']),
        createdAt = readDate(json['createdAt']),
        updatedAt = readDate(json['updatedAt']),
        super(
          id: readId(json),
          kind: kind,
          subCategory: _subCategory(json['subCategory']),
          title: readText(json['title']) ?? 'Untitled',
          thumbnail: readString(json['thumbnail']),
          serviceArea: readText(json['serviceArea']),
          price: Price.fromJson(readMap(json['price'])),
          rating: RatingSummary.fromJson(readMap(json['rating'])),
          provider: PersonRef.maybe(json['provider']),
          isActive: readBool(json['isActive']) ?? true,
          passType: PassType.parse(json['passType']),
        );

  /// Picks the subclass from `category`, or [expected] when it is missing.
  static ListingDetail fromJson(Json json, {ServiceKind? expected}) {
    final kind =
        ServiceKind.parse(json['category']) ?? expected ?? ServiceKind.skiHire;
    return switch (kind) {
      ServiceKind.skiPass => SkiPassDetail(json),
      ServiceKind.skiHire => SkiHireDetail(json),
      ServiceKind.transport => TransportDetail(json),
      ServiceKind.restaurant => RestaurantDetail(json),
      ServiceKind.massage => MassageDetail(json),
    };
  }

  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Ski pass perk: `{title, description}`.
class PassService {
  const PassService({required this.title, this.description});

  factory PassService.fromJson(Json json) => PassService(
        title: readText(json['title']) ?? '',
        description: readText(json['description']),
      );

  final String title;
  final String? description;

  Json toJson() => {'title': title, 'description': description ?? ''};
}

class SkiPassDetail extends ListingDetail {
  SkiPassDetail(Json json)
      : services = readList(json['services'], PassService.fromJson),
        maxPeoplePerBooking = (readInt(json['maxPeoplePerBooking']) ?? defaultMaxPeople).clamp(1, 50),
        super(json, kind: ServiceKind.skiPass);

  /// Used when the server doesn't send `maxPeoplePerBooking` (older builds).
  static const defaultMaxPeople = 10;

  final List<PassService> services;

  /// The server's limit per booking (POLICY.SKI_PASS_MAX_PEOPLE).
  final int maxPeoplePerBooking;
}

/// Ski hire item: `{id, name, photo, price, quantity}` (quantity = total stock).
class HireItem {
  const HireItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.photo,
  });

  factory HireItem.fromJson(Json json) => HireItem(
        id: readId(json),
        name: readText(json['name']) ?? readText(json['productName']) ?? 'Item',
        photo: readString(json['photo']) ?? readString(json['productPhoto']),
        price: readNum(json['price']) ?? 0,
        quantity: readInt(json['quantity']) ?? 0,
      );

  final String id;
  final String name;
  final String? photo;
  final num price;
  final int quantity;
}

class SkiHireDetail extends ListingDetail {
  SkiHireDetail(Json json)
      : priceUnit = readString(json['priceUnit']) ??
            readString(readMap(json['price'])?['unit']) ??
            'per_day',
        extraChargePerHour = readNum(json['extraChargePerHour']) ?? 0,
        items = readList(json['items'], HireItem.fromJson),
        super(json, kind: ServiceKind.skiHire);

  /// `per_day` | `per_hour` | `per_rental`.
  final String priceUnit;

  /// Late-return charge per started hour (0 = none).
  final num extraChargePerHour;
  final List<HireItem> items;
}

class TransportDetail extends ListingDetail {
  TransportDetail(Json json)
      : seats = readInt(json['seats']),
        mileage = readText(json['mileage']),
        power = readText(json['power']),
        extraChargePerHour = readNum(json['extraChargePerHour']),
        super(json, kind: ServiceKind.transport);

  /// Passenger seats; null on very old listings.
  final int? seats;
  final String? mileage;
  final String? power;
  final num? extraChargePerHour;
}

/// Restaurant seat type: `{id, type: VIP|Normal, photo, price, quantity, description}`.
class SeatType {
  const SeatType({
    required this.id,
    required this.type,
    required this.price,
    required this.quantity,
    this.photo,
    this.description,
  });

  factory SeatType.fromJson(Json json) => SeatType(
        id: readId(json),
        type: readText(json['type']) ?? readText(json['seat']) ?? 'Normal',
        photo: readString(json['photo']),
        price: readNum(json['price']) ?? 0,
        quantity: readInt(json['quantity']) ?? readInt(json['totalQty']) ?? 0,
        description: readText(json['description']),
      );

  final String id;

  /// `VIP` or `Normal`.
  final String type;
  final String? photo;
  final num price;
  final int quantity;
  final String? description;
}

/// Restaurant time slot: `{id, startTime, endTime}` in resort time ("7:00 PM").
class TimeSlot {
  const TimeSlot({required this.id, required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Json json) => TimeSlot(
        id: readId(json),
        startTime: readText(json['startTime']) ?? '',
        endTime: readText(json['endTime']) ?? '',
      );

  final String id;
  final String startTime;
  final String endTime;

  String get label => '$startTime – $endTime';
}

class RestaurantDetail extends ListingDetail {
  RestaurantDetail(Json json)
      : openTime = readText(json['openTime']),
        closeTime = readText(json['closeTime']),
        isOpenNow = readBool(json['isOpenNow']),
        foodType = readText(json['foodType']),
        serviceFee = readNum(json['serviceFee']) ?? 0,
        seats = readList(json['seats'] ?? json['items'], SeatType.fromJson),
        slots = readList(json['slots'], TimeSlot.fromJson),
        super(json, kind: ServiceKind.restaurant);

  final String? openTime;
  final String? closeTime;
  final bool? isOpenNow;
  final String? foodType;

  /// Added once per booking.
  final num serviceFee;
  final List<SeatType> seats;
  final List<TimeSlot> slots;
}

/// Massage option: `{id, duration: "60 min", minutes, price}`.
class MassageDuration {
  const MassageDuration({
    required this.id,
    required this.duration,
    required this.price,
    this.minutes,
  });

  factory MassageDuration.fromJson(Json json) => MassageDuration(
        id: readId(json),
        duration: readText(json['duration']) ?? '',
        minutes: readInt(json['minutes']),
        price: readNum(json['price']) ?? readNum(json['amount']) ?? 0,
      );

  final String id;

  /// Send exactly this string when booking.
  final String duration;

  /// Null for a legacy value the server can't read.
  final int? minutes;
  final num price;

  /// "1 h 30 min" from [minutes], else the raw [duration].
  String get label {
    final m = minutes;
    if (m == null || m <= 0) return duration;
    final h = m ~/ 60, r = m % 60;
    if (h == 0) return '$r min';
    if (r == 0) return '$h h';
    return '$h h $r min';
  }
}

class MassageDetail extends ListingDetail {
  MassageDetail(Json json)
      : openTime = readText(json['openTime']),
        closeTime = readText(json['closeTime']),
        durations = readList(json['durations'], MassageDuration.fromJson),
        benefits = readText(json['benefits']),
        recommendations = readText(json['recommendations']),
        capacity = readInt(json['capacity']) ?? readInt(json['therapists']) ?? 1,
        super(json, kind: ServiceKind.massage);

  /// Guests treated at the same time (number of therapists). Older listings: 1.
  final int capacity;

  final String? openTime;
  final String? closeTime;

  /// Shortest first.
  final List<MassageDuration> durations;
  final String? benefits;
  final String? recommendations;
}

/// Sub-category option for filters and listing forms
/// (`GET /common/category/<service>`: `{_id, name, categoryPhoto}`).
class CategoryOption {
  const CategoryOption({required this.id, required this.name, this.photo});

  factory CategoryOption.fromJson(Json json) => CategoryOption(
        id: readId(json),
        name: readText(json['name']) ?? '',
        photo: readString(json['categoryPhoto']) ?? readString(json['photo']),
      );

  final String id;
  final String name;
  final String? photo;
}

/// A review: `{id?, rating, comment, user {id,name,photo}, createdAt}`.
class Review {
  const Review({
    required this.rating,
    required this.comment,
    this.id,
    this.user,
    this.createdAt,
  });

  factory Review.fromJson(Json json) => Review(
        id: readString(json['id']) ?? readString(json['_id']),
        rating: readInt(json['rating']) ?? 0,
        comment: readText(json['comment']) ?? '',
        user: PersonRef.maybe(json['user']),
        createdAt: readDate(json['createdAt']),
      );

  final String? id;
  final int rating;
  final String comment;
  final PersonRef? user;
  final DateTime? createdAt;
}

/// `GET /<service>/:id/reviews`.
class ReviewsPage {
  const ReviewsPage({required this.reviews, required this.rating});

  final List<Review> reviews;
  final RatingSummary rating;
}
