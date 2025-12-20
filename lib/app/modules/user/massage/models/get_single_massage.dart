import 'dart:convert';

GetSingleMassage getSingleMassageFromJson(String str) =>
    GetSingleMassage.fromJson(json.decode(str));

String getSingleMassageToJson(GetSingleMassage data) =>
    json.encode(data.toJson());

class GetSingleMassage {
  int? code;
  String? message;
  MassageBookingData? data;

  GetSingleMassage({
    this.code,
    this.message,
    this.data,
  });

  factory GetSingleMassage.fromJson(Map<String, dynamic> json) {
    return GetSingleMassage(
      code: json["code"],
      message: json["message"],
      data: json["data"] == null
          ? null
          : MassageBookingData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}
class MassageBookingData {
  String? id;
  User? user;
  Product? product;

  String? productModel;
  String? category;

  int? personCount;
  DateTime? date;
  String? time;

  List<Slot>? slots;
  String? duration;

  String? bookingStatus;
  int? totalPrice;

  bool? isPermitted;
  List<BookingItem>? bookingItems;

  DateTime? createdAt;
  DateTime? updatedAt;

  bool? isHandOver;
  int? v;

  MassageBookingData({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.date,
    this.time,
    this.slots,
    this.duration,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isHandOver,
  });

  factory MassageBookingData.fromJson(Map<String, dynamic> json) {
    return MassageBookingData(
      id: json["_id"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      product:
      json["product"] == null ? null : Product.fromJson(json["product"]),
      productModel: json["productModel"],
      category: json["category"],
      personCount: json["personCount"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      time: json["time"],
      slots: json["slots"] == null
          ? []
          : List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
      duration: json["duration"],
      bookingStatus: json["bookingStatus"],
      totalPrice: json["totalPrice"],
      isPermitted: json["isPermitted"],
      bookingItems: json["bookingItems"] == null
          ? []
          : List<BookingItem>.from(
          json["bookingItems"].map((x) => BookingItem.fromJson(x))),
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
    "personCount": personCount,
    "date": date?.toIso8601String(),
    "time": time,
    "slots": slots?.map((x) => x.toJson()).toList(),
    "duration": duration,
    "bookingStatus": bookingStatus,
    "totalPrice": totalPrice,
    "isPermitted": isPermitted,
    "bookingItems": bookingItems?.map((x) => x.toJson()).toList(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isHandOver": isHandOver,
  };
}

class Product {
  String? id;
  Category? category;

  String? thumbnail;
  String? title;

  String? openTime;
  String? closeTime;

  List<PriceByDuration>? priceByDuration;

  String? serviceArea;
  int? amount;

  String? benefits;
  String? ourRecommendations;

  Product({
    this.id,
    this.category,
    this.thumbnail,
    this.title,
    this.openTime,
    this.closeTime,
    this.priceByDuration,
    this.serviceArea,
    this.amount,
    this.benefits,
    this.ourRecommendations,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    category: json["category"] == null
        ? null
        : Category.fromJson(json["category"]),
    thumbnail: json["thumbnail"],
    title: json["title"],
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    priceByDuration: json["priceByDuration"] == null
        ? []
        : List<PriceByDuration>.from(json["priceByDuration"]
        .map((x) => PriceByDuration.fromJson(x))),
    serviceArea: json["serviceArea"],
    amount: json["amount"],
    benefits: json["benefits"],
    ourRecommendations: json["ourRecommendations"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category?.toJson(),
    "thumbnail": thumbnail,
    "title": title,
    "openTime": openTime,
    "closeTime": closeTime,
    "priceByDuration":
    priceByDuration?.map((x) => x.toJson()).toList(),
    "serviceArea": serviceArea,
    "amount": amount,
    "benefits": benefits,
    "ourRecommendations": ourRecommendations,
  };
}


class Category {
  String? id;
  String? name;
  String? categoryPhoto;

  Category({this.id, this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
    categoryPhoto: json["categoryPhoto"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categoryPhoto": categoryPhoto,
  };
}


class PriceByDuration {
  String? id;
  String? duration;
  int? amount;

  PriceByDuration({this.id, this.duration, this.amount});

  factory PriceByDuration.fromJson(Map<String, dynamic> json) =>
      PriceByDuration(
        id: json["_id"],
        duration: json["duration"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "duration": duration,
    "amount": amount,
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

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    email: json["email"],
    status: json["status"],
    address: json["address"],
    fullName: json["fullName"],
    profileUrl: json["profileUrl"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "status": status,
    "address": address,
    "fullName": fullName,
    "profileUrl": profileUrl,
  };
}

class Slot {
  String? startTime;
  String? endTime;

  Slot({this.startTime, this.endTime});

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    startTime: json["startTime"],
    endTime: json["endTime"],
  );

  Map<String, dynamic> toJson() => {
    "startTime": startTime,
    "endTime": endTime,
  };
}



class BookingItem {
  String? id;
  int? quantity;

  BookingItem({this.id, this.quantity});

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    id: json["_id"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "quantity": quantity,
  };
}
