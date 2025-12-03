class RestaurantServiceModel {
  int code;
  String message;
  Data data;

  RestaurantServiceModel({
    this.code = 0,
    this.message = '',
    Data? data,
  }) : data = data ?? Data();

  factory RestaurantServiceModel.fromJson(Map<String, dynamic> json) =>
      RestaurantServiceModel(
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
        data: json['data'] != null ? Data.fromJson(json['data']) : Data(),
      );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data.toJson(),
  };
}

class Data {
  Pagination? pagination; // nullable
  List<Result> result;

  Data({
    this.pagination,
    List<Result>? result,
  }) : result = result ?? [];

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null,
    result: json['result'] != null
        ? (json['result'] as List)
        .map((e) => Result.fromJson(e))
        .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    if (pagination != null) 'pagination': pagination!.toJson(),
    'result': result.map((e) => e.toJson()).toList(),
  };
}

class Pagination {
  int total;
  int page;
  int limit;
  int totalPages;

  Pagination({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] ?? 0,
    page: json['page'] ?? 1,
    limit: json['limit'] ?? 10,
    totalPages: json['totalPages'] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

class Result {
  String sId;
  String title;
  String thumbnail;
  Category? category;
  Owner? owner;
  String openTime;
  String closeTime;
  String serviceArea;
  String foodType;
  String status;
  List<Item> items;
  String description;
  List<Slot> slots;
  double averageRating;
  List<Slot> availableSlots;
  List<Review> reviews;
  List<Refund> refunds;
  String createdAt;
  String updatedAt;
  int iV;
  int serviceFee;

  Result({
    this.sId = '',
    this.title = '',
    this.thumbnail = '',
    this.category,
    this.owner,
    this.openTime = '',
    this.closeTime = '',
    this.serviceArea = '',
    this.foodType = '',
    this.status = '',
    List<Item>? items,
    this.description = '',
    List<Slot>? slots,
    this.averageRating = 0.0,
    List<Slot>? availableSlots,
    List<Review>? reviews,
    List<Refund>? refunds,
    this.createdAt = '',
    this.updatedAt = '',
    this.iV = 0,
    this.serviceFee = 0,
  })  : items = items ?? [],
        slots = slots ?? [],
        availableSlots = availableSlots ?? [],
        reviews = reviews ?? [],
        refunds = refunds ?? [];

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    sId: json['_id'] ?? '',
    title: json['title'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    category: json['category'] != null ? Category.fromJson(json['category']) : null,
    owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
    openTime: json['openTime'] ?? '',
    closeTime: json['closeTime'] ?? '',
    serviceArea: json['serviceArea'] ?? '',
    foodType: json['foodType'] ?? '',
    status: json['status'] ?? '',
    items: json['items'] != null
        ? (json['items'] as List).map((e) => Item.fromJson(e)).toList()
        : [],
    description: json['description'] ?? '',
    slots: json['slots'] != null
        ? (json['slots'] as List).map((e) => Slot.fromJson(e)).toList()
        : [],
    averageRating: (json['averageRating'] ?? 0).toDouble(),
    availableSlots: json['availableSlots'] != null
        ? (json['availableSlots'] as List).map((e) => Slot.fromJson(e)).toList()
        : [],
    reviews: json['reviews'] != null
        ? (json['reviews'] as List).map((e) => Review.fromJson(e)).toList()
        : [],
    refunds: json['refunds'] != null
        ? (json['refunds'] as List).map((e) => Refund.fromJson(e)).toList()
        : [],
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    iV: json['__v'] ?? 0,
    serviceFee: json['serviceFee'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'title': title,
    'thumbnail': thumbnail,
    if (category != null) 'category': category!.toJson(),
    if (owner != null) 'owner': owner!.toJson(),
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
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'refunds': refunds.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': iV,
    'serviceFee': serviceFee,
  };
}

class Category {
  String name;
  String categoryPhoto;
  String sId;

  Category({
    this.name = '',
    this.categoryPhoto = '',
    this.sId = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json['name'] ?? '',
    categoryPhoto: json['categoryPhoto'] ?? '',
    sId: json['_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'categoryPhoto': categoryPhoto,
    '_id': sId,
  };
}

class Owner {
  String sId;
  String email;
  String address;
  String fullName;
  String profileUrl;

  Owner({
    this.sId = '',
    this.email = '',
    this.address = '',
    this.fullName = '',
    this.profileUrl = '',
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    sId: json['_id'] ?? '',
    email: json['email'] ?? '',
    address: json['address'] ?? '',
    fullName: json['fullName'] ?? '',
    profileUrl: json['profileUrl'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'email': email,
    'address': address,
    'fullName': fullName,
    'profileUrl': profileUrl,
  };
}

class Item {
  String seat;
  String photo;
  int totalQty;
  int availableQty;
  int price;
  String description;
  String sId;

  Item({
    this.seat = '',
    this.photo = '',
    this.totalQty = 0,
    this.availableQty = 0,
    this.price = 0,
    this.description = '',
    this.sId = '',
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    seat: json['seat'] ?? '',
    photo: json['photo'] ?? '',
    totalQty: json['totalQty'] ?? 0,
    availableQty: json['availableQty'] ?? 0,
    price: json['price'] ?? 0,
    description: json['description'] ?? '',
    sId: json['_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'photo': photo,
    'totalQty': totalQty,
    'availableQty': availableQty,
    'price': price,
    'description': description,
    '_id': sId,
  };
}

class Slot {
  String startTime;
  String endTime;
  String sId;

  Slot({
    this.startTime = '',
    this.endTime = '',
    this.sId = '',
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
    sId: json['_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
    '_id': sId,
  };
}

class Review {
  String userId;
  double rating;
  String comment;
  String createdAt;

  Review({
    this.userId = '',
    this.rating = 0.0,
    this.comment = '',
    this.createdAt = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    userId: json['userId'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    comment: json['comment'] ?? '',
    createdAt: json['createdAt'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
  };
}

class Refund {
  String userId;
  String reason;
  String createdAt;

  Refund({
    this.userId = '',
    this.reason = '',
    this.createdAt = '',
  });

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    userId: json['userId'] ?? '',
    reason: json['reason'] ?? '',
    createdAt: json['createdAt'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'reason': reason,
    'createdAt': createdAt,
  };
}
