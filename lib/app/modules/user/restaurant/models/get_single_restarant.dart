import 'dart:convert';

GetSingleRestaurant getSingleRestaurantFromJson(String str) =>
    GetSingleRestaurant.fromJson(json.decode(str));

String getSingleRestaurantToJson(GetSingleRestaurant data) =>
    json.encode(data.toJson());

class GetSingleRestaurant {
  int? code;
  String? message;
  RestaurantBookingData? data;

  GetSingleRestaurant({
    this.code,
    this.message,
    this.data,
  });

  factory GetSingleRestaurant.fromJson(Map<String, dynamic> json) {
    return GetSingleRestaurant(
      code: json["code"],
      message: json["message"],
      data: json["data"] == null
          ? null
          : RestaurantBookingData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class RestaurantBookingData {
  String? id;
  User? user;
  RestaurantProduct? product;
  String? productModel;
  String? category;
  DateTime? date;
  List<BookingItem>? bookingItems;
  List<Slot>? slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isHandOver;

  RestaurantBookingData({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.date,
    this.bookingItems,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isHandOver,
  });

  factory RestaurantBookingData.fromJson(Map<String, dynamic> json) {
    return RestaurantBookingData(
      id: json["_id"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      product:
      json["product"] == null ? null : RestaurantProduct.fromJson(json["product"]),
      productModel: json["productModel"],
      category: json["category"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      bookingItems: json["bookingItems"] == null
          ? []
          : List<BookingItem>.from(
          json["bookingItems"].map((x) => BookingItem.fromJson(x))),
      slots: json["slots"] == null
          ? []
          : List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
      bookingStatus: json["bookingStatus"],
      totalPrice: json["totalPrice"],
      isPermitted: json["isPermitted"],
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
      v: json["__v"],
      isHandOver: json["isHandOver"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user?.toJson(),
    "product": product?.toJson(),
    "productModel": productModel,
    "category": category,
    "date": date?.toIso8601String(),
    "bookingItems":
    bookingItems?.map((x) => x.toJson()).toList() ?? [],
    "slots": slots?.map((x) => x.toJson()).toList() ?? [],
    "bookingStatus": bookingStatus,
    "totalPrice": totalPrice,
    "isPermitted": isPermitted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isHandOver": isHandOver,
  };
}

class BookingItem {
  String? itemId;
  int? quantity;
  RestaurantSeat? item;

  BookingItem({
    this.itemId,
    this.quantity,
    this.item,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json["itemId"],
      quantity: json["quantity"],
      item:
      json["item"] == null ? null : RestaurantSeat.fromJson(json["item"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "itemId": itemId,
    "quantity": quantity,
    "item": item?.toJson(),
  };
}

class RestaurantSeat {
  String? seat;
  String? photo;
  int? totalQty;
  int? availableQty;
  int? price;
  String? description;
  String? id;

  RestaurantSeat({
    this.seat,
    this.photo,
    this.totalQty,
    this.availableQty,
    this.price,
    this.description,
    this.id,
  });

  factory RestaurantSeat.fromJson(Map<String, dynamic> json) {
    return RestaurantSeat(
      seat: json["seat"],
      photo: json["photo"],
      totalQty: json["totalQty"],
      availableQty: json["availableQty"],
      price: json["price"],
      description: json["description"],
      id: json["_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "seat": seat,
    "photo": photo,
    "totalQty": totalQty,
    "availableQty": availableQty,
    "price": price,
    "description": description,
    "_id": id,
  };
}

class RestaurantProduct {
  String? id;
  String? title;
  String? thumbnail;
  Category? category;
  String? openTime;
  String? closeTime;
  String? serviceArea;
  String? foodType;
  String? status;
  String? description;
  List<Slot>? slots;
  List<Slot>? availableSlots;
  int? serviceFee;

  RestaurantProduct({
    this.id,
    this.title,
    this.thumbnail,
    this.category,
    this.openTime,
    this.closeTime,
    this.serviceArea,
    this.foodType,
    this.status,
    this.description,
    this.slots,
    this.availableSlots,
    this.serviceFee,
  });

  factory RestaurantProduct.fromJson(Map<String, dynamic> json) {
    return RestaurantProduct(
      id: json["_id"],
      title: json["title"],
      thumbnail: json["thumbnail"],
      category:
      json["category"] == null ? null : Category.fromJson(json["category"]),
      openTime: json["openTime"],
      closeTime: json["closeTime"],
      serviceArea: json["serviceArea"],
      foodType: json["foodType"],
      status: json["status"],
      description: json["description"],
      slots: json["slots"] == null
          ? []
          : List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
      availableSlots: json["availableSlots"] == null
          ? []
          : List<Slot>.from(
          json["availableSlots"].map((x) => Slot.fromJson(x))),
      serviceFee: json["serviceFee"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "thumbnail": thumbnail,
    "category": category?.toJson(),
    "openTime": openTime,
    "closeTime": closeTime,
    "serviceArea": serviceArea,
    "foodType": foodType,
    "status": status,
    "description": description,
    "slots": slots?.map((x) => x.toJson()).toList() ?? [],
    "availableSlots":
    availableSlots?.map((x) => x.toJson()).toList() ?? [],
    "serviceFee": serviceFee,
  };
}

class Slot {
  String? id;
  String? startTime;
  String? endTime;

  Slot({
    this.id,
    this.startTime,
    this.endTime,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json["_id"],
      startTime: json["startTime"],
      endTime: json["endTime"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "startTime": startTime,
    "endTime": endTime,
  };
}

class Category {
  String? name;
  String? categoryPhoto;
  String? id;

  Category({
    this.name,
    this.categoryPhoto,
    this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"],
      categoryPhoto: json["categoryPhoto"],
      id: json["_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "categoryPhoto": categoryPhoto,
    "_id": id,
  };
}

class User {
  String? id;
  String? email;
  String? status;
  String? address;
  String? fullName;
  String? profileUrl;

  User({
    this.id,
    this.email,
    this.status,
    this.address,
    this.fullName,
    this.profileUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      email: json["email"],
      status: json["status"],
      address: json["address"],
      fullName: json["fullName"],
      profileUrl: json["profileUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "status": status,
    "address": address,
    "fullName": fullName,
    "profileUrl": profileUrl,
  };
}
