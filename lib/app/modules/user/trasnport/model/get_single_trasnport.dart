// To parse this JSON data, do
//
//     final getSingleTransport = getSingleTransportFromJson(jsonString);

import 'dart:convert';

GetSingleTransport getSingleTransportFromJson(String str) =>
    GetSingleTransport.fromJson(json.decode(str));

String getSingleTransportToJson(GetSingleTransport data) =>
    json.encode(data.toJson());

class GetSingleTransport {
  int? code;
  String? message;
  Data? data;

  GetSingleTransport({this.code, this.message, this.data});

  factory GetSingleTransport.fromJson(Map<String, dynamic> json) =>
      GetSingleTransport(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  User? user;
  Product? product;
  String? productModel;
  String? category;
  int? personCount;
  DateTime? startDateAndTime;
  DateTime? endDateAndTime;
  List<dynamic>? slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  List<BookingItem>? bookingItems;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isHandOver;
  String? timeLabel;
  double? overTimeAmount;

  Data({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.startDateAndTime,
    this.endDateAndTime,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isHandOver,
    this.timeLabel,
    this.overTimeAmount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    product:
    json["product"] == null ? null : Product.fromJson(json["product"]),
    productModel: json["productModel"],
    category: json["category"],
    personCount: json["personCount"] is String
        ? int.tryParse(json["personCount"])
        : json["personCount"],
    startDateAndTime: json["startDateAndTime"] == null
        ? null
        : DateTime.parse(json["startDateAndTime"]),
    endDateAndTime: json["endDateAndTime"] == null
        ? null
        : DateTime.parse(json["endDateAndTime"]),
    slots: json["slots"] == null
        ? []
        : List<dynamic>.from(json["slots"]!.map((x) => x)),
    bookingStatus: json["bookingStatus"],
    totalPrice: json["totalPrice"],
    isPermitted: json["isPermitted"],
    bookingItems: json["bookingItems"] == null
        ? []
        : List<BookingItem>.from(
        json["bookingItems"]!.map((x) => BookingItem.fromJson(x))),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    isHandOver: json["isHandOver"],
    timeLabel: json["timeLabel"],
    overTimeAmount: json["overTimeAmount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user?.toJson(),
    "product": product?.toJson(),
    "productModel": productModel,
    "category": category,
    "personCount": personCount,
    "startDateAndTime": startDateAndTime?.toIso8601String(),
    "endDateAndTime": endDateAndTime?.toIso8601String(),
    "slots": slots == null ? [] : List<dynamic>.from(slots!.map((x) => x)),
    "bookingStatus": bookingStatus,
    "totalPrice": totalPrice,
    "isPermitted": isPermitted,
    "bookingItems": bookingItems == null
        ? []
        : List<dynamic>.from(bookingItems!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isHandOver": isHandOver,
    "timeLabel": timeLabel,
    "overTimeAmount": overTimeAmount,
  };
}

class BookingItem {
  // Add fields as per API if needed
  BookingItem();

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem();

  Map<String, dynamic> toJson() => {};
}

class Product {
  String? id;
  String? thumbnail;
  String? title;
  String? personCount;
  String? milage;
  String? power;
  String? extraChargePerHours;
  int? insuranceFee;
  int? maintainCharge;
  String? serviceArea;
  int? amount;
  String? description;
  Category? category;

  Product({
    this.id,
    this.thumbnail,
    this.title,
    this.personCount,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.serviceArea,
    this.amount,
    this.description,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    thumbnail: json["thumbnail"],
    title: json["title"],
    personCount: json["personCount"],
    milage: json["milage"],
    power: json["power"],
    extraChargePerHours: json["extraChargePerHours"],
    insuranceFee: json["insuranceFee"],
    maintainCharge: json["maintainCharge"],
    serviceArea: json["serviceArea"],
    amount: json["amount"],
    description: json["description"],
    category:
    json["category"] == null ? null : Category.fromJson(json["category"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "thumbnail": thumbnail,
    "title": title,
    "personCount": personCount,
    "milage": milage,
    "power": power,
    "extraChargePerHours": extraChargePerHours,
    "insuranceFee": insuranceFee,
    "maintainCharge": maintainCharge,
    "serviceArea": serviceArea,
    "amount": amount,
    "description": description,
    "category": category?.toJson(),
  };
}

class Category {
  String? name;
  String? categoryPhoto;
  String? id;

  Category({this.name, this.categoryPhoto, this.id});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json["name"],
    categoryPhoto: json["categoryPhoto"],
    id: json["_id"],
  );

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

  User({this.id, this.email, this.status, this.address, this.fullName, this.profileUrl});

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
