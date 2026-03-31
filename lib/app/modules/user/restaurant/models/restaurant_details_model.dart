import 'package:harry_service_app/app/data/models/review_model.dart';

class RestaurantDetailsModel {
  final String id;
  final String title;
  final String? thumbnail;
  final Category? category;
  final Owner? owner;
  final String? openTime;
  final String? closeTime;
  final String? serviceArea;
  final String? foodType;
  final String? status;
  final List<RestaurantItem> items;
  final String? description;
  final List<Slot> slots;
  final double averageRating;
  final List<Slot> availableSlots;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestaurantDetailsModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.category,
    this.owner,
    this.openTime,
    this.closeTime,
    this.serviceArea,
    this.foodType,
    this.status,
    this.items = const [],
    this.description,
    this.slots = const [],
    this.averageRating = 0.0,
    this.availableSlots = const [],
    this.reviews = const [],
    this.refunds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory RestaurantDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return RestaurantDetailsModel(
      id: data['_id'] ?? '',
      title: data['title'] ?? '',
      thumbnail: data['thumbnail'],
      category: data['category'] != null ? Category.fromJson(data['category']) : null,
      owner: data['owner'] != null ? Owner.fromJson(data['owner']) : null,
      openTime: data['openTime'],
      closeTime: data['closeTime'],
      serviceArea: data['serviceArea'],
      foodType: data['foodType'],
      status: data['status'],
      items: (data['items'] as List<dynamic>? ?? []).map((e) => RestaurantItem.fromJson(e)).toList(),
      description: data['description'],
      slots: (data['slots'] as List<dynamic>? ?? []).map((e) => Slot.fromJson(e)).toList(),
      averageRating: (data['averageRating'] is num) ? (data['averageRating'] as num).toDouble() : 0.0,
      availableSlots: (data['availableSlots'] as List<dynamic>? ?? []).map((e) => Slot.fromJson(e)).toList(),
      reviews: (data['reviews'] as List<dynamic>? ?? []).map((e) => Review.fromJson(e)).toList(),
      refunds: (data['refunds'] as List<dynamic>? ?? []),
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'thumbnail': thumbnail,
    'category': category?.toJson(),
    'owner': owner?.toJson(),
    'openTime': openTime,
    'closeTime': closeTime,
    'serviceArea': serviceArea,
    'foodType': foodType,
    'status': status,
    'items': items.map((e) => e.toJson()).toList(),
    'description': description,
    'slots': slots.map((e) => e.toJson()).toList(),
    'averageRating': averageRating,
    'availableSlots': availableSlots.map((e) => e.toJson()).toList(),
    'reviews': reviews.map((e) => {
      'userId': e.userId,
      'user': {
        '_id': e.user.id,
        'fullName': e.user.fullName,
        'profileUrl': e.user.profileUrl,
      },
      'rating': e.rating,
      'comment': e.comment,
      'createdAt': e.createdAt.toIso8601String(),
    }).toList(),
    'refunds': refunds,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}


// ================= CATEGORY =================
class Category {
  final String id;
  final String name;
  final String? categoryPhoto;

  Category({required this.id, required this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    categoryPhoto: json['categoryPhoto'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'categoryPhoto': categoryPhoto,
  };
}

// ================= OWNER =================
class Owner {
  final String id;
  final String? fullName;
  final String? profileUrl;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? providerType;
  final String? status;
  final String? role;
  final bool isAgreedTermsCondition;
  final bool isAgreedTermsConditions;
  final bool isResetPassword;

  Owner({
    required this.id,
    this.fullName,
    this.profileUrl,
    this.address,
    this.email,
    this.providerType,
    this.status,
    this.role,
    this.isAgreedTermsCondition = false,
    this.isAgreedTermsConditions = false,
    this.isResetPassword = false,
    this.phoneNumber,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json['_id'] ?? '',
    fullName: json['fullName'],
    profileUrl: json['profileUrl'],
    address: json['address'],
    email: json['email'],
    providerType: json['providerType'],
    status: json['status'],
    role: json['role'],
    isAgreedTermsCondition: json['isAgreedTermsCondition'] ?? false,
    isAgreedTermsConditions: json['isAgreedTermsConditions'] ?? false,
    isResetPassword: json['isResetPassword'] ?? false,
    phoneNumber: json['phoneNumber']
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'profileUrl': profileUrl,
    'address': address,
    'email': email,
    'providerType': providerType,
    'status': status,
    'role': role,
    'isAgreedTermsCondition': isAgreedTermsCondition,
    'isAgreedTermsConditions': isAgreedTermsConditions,
    'isResetPassword': isResetPassword,
  };
}

// ================= RESTAURANT ITEM =================
class RestaurantItem {
  final String id;
  final String? seat;
  final String? photo;
  final int totalQty;
  final int availableQty;
  final double price;
  final String? description;

  RestaurantItem({
    required this.id,
    this.seat,
    this.photo,
    this.totalQty = 0,
    this.availableQty = 0,
    this.price = 0.0,
    this.description,
  });

  factory RestaurantItem.fromJson(Map<String, dynamic> json) => RestaurantItem(
    id: json['_id'] ?? '',
    seat: json['seat'],
    photo: json['photo'],
    totalQty: json['totalQty'] ?? 0,
    availableQty: json['availableQty'] ?? 0,
    price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'seat': seat,
    'photo': photo,
    'totalQty': totalQty,
    'availableQty': availableQty,
    'price': price,
    'description': description,
  };
}

// ================= SLOT =================
class Slot {
  final String id;
  final String? startTime;
  final String? endTime;

  Slot({required this.id, this.startTime, this.endTime});

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json['_id'] ?? '',
    startTime: json['startTime'],
    endTime: json['endTime'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'startTime': startTime,
    'endTime': endTime,
  };
}
