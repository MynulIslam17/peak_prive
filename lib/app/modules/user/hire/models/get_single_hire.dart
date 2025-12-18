import 'dart:convert';

GetSingleHire getSingleHireFromJson(String str) =>
    GetSingleHire.fromJson(json.decode(str));

String getSingleHireToJson(GetSingleHire data) => json.encode(data.toJson());

class GetSingleHire {
  int? code;
  String? message;
  Data? data;

  GetSingleHire({this.code, this.message, this.data});

  factory GetSingleHire.fromJson(Map<String, dynamic> json) => GetSingleHire(
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
  DateTime? startDateAndTime;
  DateTime? endDateAndTime;
  List<BookingItem>? bookingItems;
  List<dynamic>? slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
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
    this.startDateAndTime,
    this.endDateAndTime,
    this.bookingItems,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
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
    startDateAndTime: _parseDate(json["startDateAndTime"]),
    endDateAndTime: _parseDate(json["endDateAndTime"]),
    bookingItems: json["bookingItems"] == null
        ? []
        : List<BookingItem>.from(
        json["bookingItems"]!.map((x) => BookingItem.fromJson(x))),
    slots: json["slots"] == null
        ? []
        : List<dynamic>.from(json["slots"]!.map((x) => x)),
    bookingStatus: json["bookingStatus"],
    totalPrice: json["totalPrice"],
    isPermitted: json["isPermitted"],
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
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
    "startDateAndTime": startDateAndTime?.toIso8601String(),
    "endDateAndTime": endDateAndTime?.toIso8601String(),
    "bookingItems": bookingItems == null
        ? []
        : List<dynamic>.from(bookingItems!.map((x) => x.toJson())),
    "slots": slots == null ? [] : List<dynamic>.from(slots!.map((x) => x)),
    "bookingStatus": bookingStatus,
    "totalPrice": totalPrice,
    "isPermitted": isPermitted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isHandOver": isHandOver,
    "timeLabel": timeLabel,
    "overTimeAmount": overTimeAmount,
  };

  // Safe DateTime parser
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

class BookingItem {
  String? itemId;
  int? quantity;
  Item? item;

  BookingItem({this.itemId, this.quantity, this.item});

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    itemId: json["itemId"],
    quantity: json["quantity"],
    item: json["item"] == null ? null : Item.fromJson(json["item"]),
  );

  Map<String, dynamic> toJson() => {
    "itemId": itemId,
    "quantity": quantity,
    "item": item?.toJson(),
  };
}

class Item {
  String? productName;
  String? productPhoto;
  int? price;
  int? totalQty;
  int? availableQty;
  String? id;

  Item({
    this.productName,
    this.productPhoto,
    this.price,
    this.totalQty,
    this.availableQty,
    this.id,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productName: json["productName"],
    productPhoto: json["productPhoto"],
    price: json["price"],
    totalQty: json["totalQty"],
    availableQty: json["availableQty"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "productName": productName,
    "productPhoto": productPhoto,
    "price": price,
    "totalQty": totalQty,
    "availableQty": availableQty,
    "_id": id,
  };
}

class Product {
  String? id;
  String? category;
  String? title;
  String? thumbnail;
  int? extraChargePerHour;
  String? serviceArea;

  Product({
    this.id,
    this.category,
    this.title,
    this.thumbnail,
    this.extraChargePerHour,
    this.serviceArea,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    category: json["category"],
    title: json["title"],
    thumbnail: json["thumbnail"],
    extraChargePerHour: json["extraChargePerHour"],
    serviceArea: json["serviceArea"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category,
    "title": title,
    "thumbnail": thumbnail,
    "extraChargePerHour": extraChargePerHour,
    "serviceArea": serviceArea,
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
