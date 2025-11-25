class RestaurantModel {
  final int? code;
  final String? message;
  final RestaurantData? data;

  RestaurantModel({this.code, this.message, this.data});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? RestaurantData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RestaurantData {
  final Pagination? pagination;
  final List<RestaurantItem> result;

  RestaurantData({this.pagination, required this.result});

  factory RestaurantData.fromJson(Map<String, dynamic> json) {
    final resultList = (json['result'] as List<dynamic>?)
        ?.map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];
    return RestaurantData(
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      result: resultList,
    );
  }
}

class Pagination {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
}

class RestaurantItem {
  final String? id;
  final String? title;
  final String? thumbnail;
  final Category? category;
  final Owner? owner;
  final String? openTime;
  final String? closeTime;
  final String? serviceArea;
  final String? foodType;
  final String? status;
  final List<Item> items;
  final String? description;
  final List<Slot> slots;
  final double? averageRating;
  final List<Slot> availableSlots;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestaurantItem({
    this.id,
    this.title,
    this.thumbnail,
    this.category,
    this.owner,
    this.openTime,
    this.closeTime,
    this.serviceArea,
    this.foodType,
    this.status,
    required this.items,
    this.description,
    required this.slots,
    this.averageRating,
    required this.availableSlots,
    required this.reviews,
    required this.refunds,
    this.createdAt,
    this.updatedAt,
  });

  factory RestaurantItem.fromJson(Map<String, dynamic> json) {
    return RestaurantItem(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      serviceArea: json['serviceArea'] as String?,
      foodType: json['foodType'] as String?,
      status: json['status'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      description: json['description'] as String?,
      slots: (json['slots'] as List<dynamic>?)
          ?.map((e) => Slot.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      averageRating: (json['averageRating'] != null)
          ? (json['averageRating'] as num).toDouble()
          : 0,
      availableSlots: (json['availableSlots'] as List<dynamic>?)
          ?.map((e) => Slot.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      refunds: json['refunds'] as List<dynamic>? ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class Category {
  final String? id;
  final String? name;
  final String? categoryPhoto;

  Category({this.id, this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      categoryPhoto: json['categoryPhoto'] as String?,
    );
  }
}

class Owner {
  final String? id;
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
    this.id,
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

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String?,
      profileUrl: json['profileUrl'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      providerType: json['providerType'] as String?,
      status: json['status'] as String?,
      role: json['role'] as String?,
      isAgreedTermsCondition: json['isAgreedTermsCondition'] as bool? ?? false,
      isAgreedTermsConditions: json['isAgreedTermsConditions'] as bool? ?? false,
      isResetPassword: json['isResetPassword'] as bool? ?? false,
    );
  }
}

class Item {
  final String? id;
  final String? seat;
  final String? photo;
  final int? totalQty;
  final int? availableQty;
  final double? price;
  final String? description;

  Item({
    this.id,
    this.seat,
    this.photo,
    this.totalQty,
    this.availableQty,
    this.price,
    this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] as String?,
      seat: json['seat'] as String?,
      photo: json['photo'] as String?,
      totalQty: json['totalQty'] as int?,
      availableQty: json['availableQty'] as int?,
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0,
      description: json['description'] as String?,
    );
  }
}

class Slot {
  final String? id;
  final String? startTime;
  final String? endTime;

  Slot({this.id, this.startTime, this.endTime});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['_id'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }
}

class Review {
  final String? userId;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;

  Review({this.userId, this.rating, this.comment, this.createdAt});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] as String?,
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
