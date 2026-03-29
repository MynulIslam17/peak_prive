import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart';
import '../../../../core/utils/json_helper.dart';


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
        code: JsonHelper.getInt(json['code']),
        message: JsonHelper.getString(json['message']),
        data: json['data'] != null
            ? Data.fromJson(JsonHelper.getMap(json['data'])!)
            : Data(),
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
        ? Pagination.fromJson(JsonHelper.getMap(json['pagination'])!)
        : null,
    result: JsonHelper.getList(json['result'])
        .map((e) => Result.fromJson(JsonHelper.getMap(e)!))
        .toList(),
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
    total: JsonHelper.getInt(json['total']),
    page: JsonHelper.getInt(json['page']),
    limit: JsonHelper.getInt(json['limit']),
    totalPages: JsonHelper.getInt(json['totalPages']),
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
    sId: JsonHelper.getString(json['_id']),
    title: JsonHelper.getString(json['title']),
    thumbnail: JsonHelper.getString(json['thumbnail']),
    category: json['category'] != null
        ? Category.fromJson(JsonHelper.getMap(json['category'])!)
        : null,
    owner: json['owner'] != null
        ? Owner.fromJson(JsonHelper.getMap(json['owner'])!)
        : null,
    openTime: JsonHelper.getString(json['openTime']),
    closeTime: JsonHelper.getString(json['closeTime']),
    serviceArea: JsonHelper.getString(json['serviceArea']),
    foodType: JsonHelper.getString(json['foodType']),
    status: JsonHelper.getString(json['status']),
    items: JsonHelper.getList(json['items'])
        .map((e) => Item.fromJson(JsonHelper.getMap(e)!))
        .toList(),
    description: JsonHelper.getString(json['description']),
    slots: JsonHelper.getList(json['slots'])
        .map((e) => Slot.fromJson(JsonHelper.getMap(e)!))
        .toList(),
    averageRating: JsonHelper.getDouble(json['averageRating']),
    availableSlots: JsonHelper.getList(json['availableSlots'])
        .map((e) => Slot.fromJson(JsonHelper.getMap(e)!))
        .toList(),
    reviews: JsonHelper.getList(json['reviews'])
        .map((e) => Review.fromJson(JsonHelper.getMap(e)!))
        .toList(),
    refunds: JsonHelper.getList(json['refunds'])
        .map((e) => Refund.fromJson(JsonHelper.getMap(e)!))
        .toList(),
    createdAt: JsonHelper.getString(json['createdAt']),
    updatedAt: JsonHelper.getString(json['updatedAt']),
    iV: JsonHelper.getInt(json['__v']),
    serviceFee: JsonHelper.getInt(json['serviceFee']),
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

  factory Result.fromRecentService(RecentService service) {
    final Category? targetCategory = service.category != null
        ? Category(
      sId: service.category!.id,
      name: service.category!.name,
      categoryPhoto: service.category!.categoryPhoto,
    )
        : null;

    final List<Item> targetItems = service.items
        .map((si) => Item(
      sId: JsonHelper.getString(si.id),
      seat: JsonHelper.getString(si.seat),
      photo: JsonHelper.getString(si.photo),
      totalQty: JsonHelper.getInt(si.totalQty),
      availableQty: JsonHelper.getInt(si.availableQty),
      price: JsonHelper.getInt(si.price),
      description: JsonHelper.getString(si.description),
    ))
        .toList();

    final List<Refund> targetRefunds = service.refunds
        .whereType<Map<String, dynamic>>()
        .map((json) => Refund.fromJson(json))
        .toList();

    final List<Slot> targetSlots =
    service.slots.map((s) => Slot.fromJson(s.toJson())).toList();
    final List<Slot> targetAvailableSlots =
    service.availableSlots.map((s) => Slot.fromJson(s.toJson())).toList();
    final List<Review> targetReviews =
    service.reviews.map((r) => Review.fromJson(r.toJson())).toList();

    return Result(
      sId: service.id,
      title: service.title,
      thumbnail: service.thumbnail,
      openTime: service.openTime,
      closeTime: service.closeTime,
      serviceArea: service.serviceArea,
      foodType: service.foodType,
      status: service.status,
      createdAt: service.createdAt,
      updatedAt: service.updatedAt,
      serviceFee: JsonHelper.getInt(service.serviceFee),
      averageRating: JsonHelper.getDouble(service.averageRating),
      iV: JsonHelper.getInt(service.v),
      category: targetCategory,
      items: targetItems,
      refunds: targetRefunds,
      slots: targetSlots,
      availableSlots: targetAvailableSlots,
      reviews: targetReviews,
      owner: null,
      description: '',
    );
  }
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
    name: JsonHelper.getString(json['name']),
    categoryPhoto: JsonHelper.getString(json['categoryPhoto']),
    sId: JsonHelper.getString(json['_id']),
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
    sId: JsonHelper.getString(json['_id']),
    email: JsonHelper.getString(json['email']),
    address: JsonHelper.getString(json['address']),
    fullName: JsonHelper.getString(json['fullName']),
    profileUrl: JsonHelper.getString(json['profileUrl']),
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
    seat: JsonHelper.getString(json['seat']),
    photo: JsonHelper.getString(json['photo']),
    totalQty: JsonHelper.getInt(json['totalQty']),
    availableQty: JsonHelper.getInt(json['availableQty']),
    price: JsonHelper.getInt(json['price']),
    description: JsonHelper.getString(json['description']),
    sId: JsonHelper.getString(json['_id']),
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
    startTime: JsonHelper.getString(json['startTime']),
    endTime: JsonHelper.getString(json['endTime']),
    sId: JsonHelper.getString(json['_id']),
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
    userId: JsonHelper.getString(json['userId']),
    rating: JsonHelper.getDouble(json['rating']),
    comment: JsonHelper.getString(json['comment']),
    createdAt: JsonHelper.getString(json['createdAt']),
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
    userId: JsonHelper.getString(json['userId']),
    reason: JsonHelper.getString(json['reason']),
    createdAt: JsonHelper.getString(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'reason': reason,
    'createdAt': createdAt,
  };
}