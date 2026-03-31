import '../../../../data/models/review_model.dart';

class MassageDetailsModel {
  final int code;
  final String message;
  final MassageDetails data;

  MassageDetailsModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MassageDetailsModel.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) {
        return MassageDetailsModel(
          code: 0,
          message: '',
          data: MassageDetails.empty(),
        );
      }

      return MassageDetailsModel(
        code: json['code'] is int ? json['code'] : 0,
        message: json['message']?.toString() ?? '',
        data: MassageDetails.fromJson(json['data']),
      );
    } catch (_) {
      return MassageDetailsModel(code: 0, message: '', data: MassageDetails.empty());
    }
  }
}

class MassageDetails {
  final String id;
  final Category category;
  final Owner owner;
  final String thumbnail;
  final String title;
  final String openTime;
  final String closeTime;
  final List<PriceByDuration> priceByDuration;
  final String serviceArea;
  final num amount;
  final String benefits;
  final String ourRecommendations;
  final num averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;

  MassageDetails({
    required this.id,
    required this.category,
    required this.owner,
    required this.thumbnail,
    required this.title,
    required this.openTime,
    required this.closeTime,
    required this.priceByDuration,
    required this.serviceArea,
    required this.amount,
    required this.benefits,
    required this.ourRecommendations,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MassageDetails.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) return MassageDetails.empty();

      return MassageDetails(
        id: json['_id']?.toString() ?? '',
        category: Category.fromJson(json['category']),
        owner: Owner.fromJson(json['owner']),
        thumbnail: json['thumbnail']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        openTime: json['openTime']?.toString() ?? '',
        closeTime: json['closeTime']?.toString() ?? '',
        priceByDuration: (json['priceByDuration'] as List? ?? [])
            .map((e) => PriceByDuration.fromJson(e))
            .toList(),
        serviceArea: json['serviceArea']?.toString() ?? '',
        amount: json['amount'] is num ? json['amount'] : 0,
        benefits: json['benefits']?.toString() ?? '',
        ourRecommendations: json['ourRecommendations']?.toString() ?? '',
        averageRating: json['averageRating'] is num ? json['averageRating'] : 0,
        reviews: (json['reviews'] as List? ?? [])
            .map((e) => Review.fromJson(e))
            .toList(),
        refunds: json['refunds'] is List ? json['refunds'] : [],
        createdAt: _safeDate(json['createdAt']),
        updatedAt: _safeDate(json['updatedAt']),
      );
    } catch (_) {
      return MassageDetails.empty();
    }
  }

  static MassageDetails empty() {
    return MassageDetails(
      id: '',
      category: Category.empty(),
      owner: Owner.empty(),
      thumbnail: '',
      title: '',
      openTime: '',
      closeTime: '',
      priceByDuration: [],
      serviceArea: '',
      amount: 0,
      benefits: '',
      ourRecommendations: '',
      averageRating: 0,
      reviews: [],
      refunds: [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

DateTime _safeDate(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);

  try {
    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class Category {
  final String id;
  final String name;
  final String categoryPhoto;

  Category({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory Category.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) return Category.empty();

      return Category(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        categoryPhoto: json['categoryPhoto']?.toString() ?? '',
      );
    } catch (_) {
      return Category.empty();
    }
  }

  static Category empty() => Category(id: '', name: '', categoryPhoto: '');
}

class Owner {
  final String id;
  final String fullName;
  final String profileUrl;
  final String address;
  final String email;
  final String providerType;
  final String status;
  final String role;
  final String phoneNumber;

  Owner({
    required this.id,
    required this.fullName,
    required this.profileUrl,
    required this.address,
    required this.email,
    required this.providerType,
    required this.status,
    required this.role,
    required this.phoneNumber,
  });

  factory Owner.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) return Owner.empty();

      return Owner(
        id: json['_id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        profileUrl: json['profileUrl']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        providerType: json['providerType']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        phoneNumber: json["phoneNumber"]?.toString() ?? '',
      );
    } catch (_) {
      return Owner.empty();
    }
  }

  static Owner empty() {
    return Owner(
      id: '',
      fullName: '',
      profileUrl: '',
      address: '',
      email: '',
      providerType: '',
      status: '',
      role: '',
      phoneNumber: '',
    );
  }
}

class PriceByDuration {
  final String id;
  final String duration;
  final num amount;

  PriceByDuration({
    required this.id,
    required this.duration,
    required this.amount,
  });

  factory PriceByDuration.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) return PriceByDuration.empty();

      return PriceByDuration(
        id: json['_id']?.toString() ?? '',
        duration: json['duration']?.toString() ?? '',
        amount: json['amount'] is num ? json['amount'] : 0,
      );
    } catch (_) {
      return PriceByDuration.empty();
    }
  }

  static PriceByDuration empty() =>
      PriceByDuration(id: '', duration: '', amount: 0);
}


