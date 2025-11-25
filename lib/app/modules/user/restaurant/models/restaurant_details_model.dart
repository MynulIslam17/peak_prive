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
  final List<RestaurantItem>? items;
  final String? description;
  final List<Slot>? slots;
  final double averageRating;
  final List<Slot>? availableSlots;
  final List<dynamic>? reviews;
  final List<dynamic>? refunds;
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
    this.items,
    this.description,
    this.slots,
    required this.averageRating,
    this.availableSlots,
    this.reviews,
    this.refunds,
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
      items: data['items'] != null
          ? List<RestaurantItem>.from(
          (data['items'] as List).map((e) => RestaurantItem.fromJson(e)))
          : [],
      description: data['description'],
      slots: data['slots'] != null
          ? List<Slot>.from((data['slots'] as List).map((e) => Slot.fromJson(e)))
          : [],
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      availableSlots: data['availableSlots'] != null
          ? List<Slot>.from(
          (data['availableSlots'] as List).map((e) => Slot.fromJson(e)))
          : [],
      reviews: data['reviews'] ?? [],
      refunds: data['refunds'] ?? [],
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
    'items': items?.map((e) => e.toJson()).toList(),
    'description': description,
    'slots': slots?.map((e) => e.toJson()).toList(),
    'averageRating': averageRating,
    'availableSlots': availableSlots?.map((e) => e.toJson()).toList(),
    'reviews': reviews,
    'refunds': refunds,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

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

class Owner {
  final String id;
  final String? fullName;
  final String? profileUrl;
  final String? address;
  final String? email;
  final String? providerType;
  final String? status;
  final String? role;
  final bool? isAgreedTermsCondition;
  final bool? isAgreedTermsConditions;
  final bool? isResetPassword;

  Owner({
    required this.id,
    this.fullName,
    this.profileUrl,
    this.address,
    this.email,
    this.providerType,
    this.status,
    this.role,
    this.isAgreedTermsCondition,
    this.isAgreedTermsConditions,
    this.isResetPassword,
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
    required this.totalQty,
    required this.availableQty,
    required this.price,
    this.description,
  });

  factory RestaurantItem.fromJson(Map<String, dynamic> json) => RestaurantItem(
    id: json['_id'] ?? '',
    seat: json['seat'],
    photo: json['photo'],
    totalQty: json['totalQty'] ?? 0,
    availableQty: json['availableQty'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
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
