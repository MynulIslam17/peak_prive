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
  Category? category;
  String? title;
  String? thumbnail;
  Owner? owner;
  int? extraChargePerHour;
  int? totalPrice;
  String? serviceArea;
  List<HireItem>? items;
  num? averageRating;
  List<Review>? reviews;
  List<dynamic>? refunds;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  // Legacy/Compatibility fields
  User? user;
  Product? product;
  String? productModel;
  DateTime? startDateAndTime;
  DateTime? endDateAndTime;
  List<BookingItem>? bookingItems;
  List<dynamic>? slots;
  String? bookingStatus;
  bool? isPermitted;
  bool? isHandOver;
  String? timeLabel;
  double? overTimeAmount;

  Data({
    this.id,
    this.category,
    this.title,
    this.thumbnail,
    this.owner,
    this.extraChargePerHour,
    this.totalPrice,
    this.serviceArea,
    this.items,
    this.averageRating,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.product,
    this.productModel,
    this.startDateAndTime,
    this.endDateAndTime,
    this.bookingItems,
    this.slots,
    this.bookingStatus,
    this.isPermitted,
    this.isHandOver,
    this.timeLabel,
    this.overTimeAmount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    category: json["category"] is Map<String, dynamic>
        ? Category.fromJson(json["category"])
        : null,
    title: json["title"],
    thumbnail: json["thumbnail"],
    owner: json["owner"] is Map<String, dynamic>
        ? Owner.fromJson(json["owner"])
        : null,
    extraChargePerHour: json["extraChargePerHour"],
    totalPrice: json["totalPrice"],
    serviceArea: json["serviceArea"],
    items: json["items"] == null
        ? []
        : List<HireItem>.from(json["items"]!.map((x) => HireItem.fromJson(x))),
    averageRating: json["averageRating"],
    reviews: json["reviews"] == null
        ? []
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
    refunds: json["refunds"] == null ? [] : List<dynamic>.from(json["refunds"]!.map((x) => x)),
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
    v: json["__v"],
    user: json["user"] is Map<String, dynamic> ? User.fromJson(json["user"]) : null,
    product: json["product"] is Map<String, dynamic> ? Product.fromJson(json["product"]) : null,
    productModel: json["productModel"],
    startDateAndTime: _parseDate(json["startDateAndTime"]),
    endDateAndTime: _parseDate(json["endDateAndTime"]),
    bookingItems: json["bookingItems"] == null
        ? []
        : List<BookingItem>.from(json["bookingItems"]!.map((x) => BookingItem.fromJson(x))),
    slots: json["slots"] == null ? [] : List<dynamic>.from(json["slots"]!.map((x) => x)),
    bookingStatus: json["bookingStatus"],
    isPermitted: json["isPermitted"],
    isHandOver: json["isHandOver"],
    timeLabel: json["timeLabel"],
    overTimeAmount: json["overTimeAmount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category?.toJson(),
    "title": title,
    "thumbnail": thumbnail,
    "owner": owner?.toJson(),
    "extraChargePerHour": extraChargePerHour,
    "totalPrice": totalPrice,
    "serviceArea": serviceArea,
    "items": items?.map((x) => x.toJson()).toList(),
    "averageRating": averageRating,
    "reviews": reviews?.map((x) => x.toJson()).toList(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
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

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "categoryPhoto": categoryPhoto};
}

class Owner {
  String? id;
  String? email;
  String? fullName;
  String? profileUrl;
  String? address;
  String? phoneNumber;
  String? role;
  String? status;
  String? providerType;
  // Added missing fields from JSON
  bool? isAgreedTermsCondition;
  bool? isAgreedTermsConditions;
  bool? isResetPassword;

  Owner({
    this.id,
    this.email,
    this.fullName,
    this.profileUrl,
    this.address,
    this.phoneNumber,
    this.role,
    this.status,
    this.providerType,
    this.isAgreedTermsCondition,
    this.isAgreedTermsConditions,
    this.isResetPassword,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json["_id"],
    email: json["email"],
    fullName: json["fullName"],
    profileUrl: json["profileUrl"],
    address: json["address"],
    phoneNumber: json["phoneNumber"],
    role: json["role"],
    status: json["status"],
    providerType: json["providerType"],
    isAgreedTermsCondition: json["isAgreedTermsCondition"],
    isAgreedTermsConditions: json["isAgreedTermsConditions"],
    isResetPassword: json["isResetPassword"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "fullName": fullName,
    "profileUrl": profileUrl,
    "isResetPassword": isResetPassword,
  };
}

class HireItem {
  String? id;
  String? productName;
  String? productPhoto;
  int? price;
  int? totalQty;
  int? availableQty;

  HireItem({this.id, this.productName, this.productPhoto, this.price, this.totalQty, this.availableQty});

  factory HireItem.fromJson(Map<String, dynamic> json) => HireItem(
    id: json["_id"],
    productName: json["productName"],
    productPhoto: json["productPhoto"],
    price: json["price"],
    totalQty: json["totalQty"],
    availableQty: json["availableQty"],
  );

  Map<String, dynamic> toJson() => {"_id": id, "productName": productName, "price": price};
}

class Review {
  ReviewUser? userId;
  num? rating;
  String? comment;
  DateTime? createdAt;

  Review({this.userId, this.rating, this.comment, this.createdAt});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    userId: json["userId"] is Map<String, dynamic> ? ReviewUser.fromJson(json["userId"]) : null,
    rating: json["rating"],
    comment: json["comment"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {"userId": userId?.toJson(), "rating": rating, "comment": comment};
}

class ReviewUser {
  String? id;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? profileUrl;
  DateTime? createdAt;

  ReviewUser({this.id, this.fullName, this.email, this.phoneNumber, this.profileUrl, this.createdAt});

  factory ReviewUser.fromJson(Map<String, dynamic> json) => ReviewUser(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    profileUrl: json["profileUrl"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {"_id": id, "fullName": fullName, "profileUrl": profileUrl};
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

  Map<String, dynamic> toJson() => {"itemId": itemId, "quantity": quantity, "item": item?.toJson()};
}

class Item {
  String? productName;
  String? productPhoto;
  int? price;
  int? totalQty;
  int? availableQty;
  String? id;

  Item({this.productName, this.productPhoto, this.price, this.totalQty, this.availableQty, this.id});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productName: json["productName"],
    productPhoto: json["productPhoto"],
    price: json["price"],
    totalQty: json["totalQty"],
    availableQty: json["availableQty"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {"_id": id, "productName": productName};
}

class Product {
  String? id;
  String? category; // This stays a String for your UI
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
    // FIX: Check if category is a Map. If yes, take the name. If no, take it as a String.
    category: json["category"] is Map<String, dynamic>
        ? json["category"]["name"]?.toString()
        : json["category"]?.toString(),
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

  Map<String, dynamic> toJson() => {"_id": id, "fullName": fullName};
}