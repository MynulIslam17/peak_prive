// =======================
// Helper for flexibility
// =======================
Map<String, dynamic> extractExtra(
    Map<String, dynamic> json,
    List<String> knownKeys,
    ) {
  final extra = Map<String, dynamic>.from(json);
  for (final key in knownKeys) {
    extra.remove(key);
  }
  return extra;
}

// =======================
// Root Model
// =======================
class MassageItemModel {
  int? code;
  String? message;
  Data? data;
  Map<String, dynamic>? extra;

  MassageItemModel({
    this.code,
    this.message,
    this.data,
    this.extra,
  });

  factory MassageItemModel.fromJson(Map<String, dynamic> json) {
    return MassageItemModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      extra: extractExtra(json, ['code', 'message', 'data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
    if (extra != null) ...extra!,
  };
}

// =======================
// Data
// =======================
class Data {
  String? id;
  User? user;
  Product? product;
  String? productModel;
  String? category;

  String? date;
  String? time;
  String? duration;

  List<dynamic>? slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  bool? isHandOver;

  List<dynamic>? bookingItems;
  String? createdAt;
  String? updatedAt;
  int? version;

  Map<String, dynamic>? extra;

  Data({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.date,
    this.time,
    this.duration,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.isHandOver,
    this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.extra,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      date: json['date'],
      time: json['time'],
      duration: json['duration'],
      slots: json['slots'] ?? [],
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      isPermitted: json['isPermitted'],
      isHandOver: json['isHandOver'],
      bookingItems: json['bookingItems'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
      extra: extractExtra(json, [
        '_id',
        'user',
        'product',
        'productModel',
        'category',
        'date',
        'time',
        'duration',
        'slots',
        'bookingStatus',
        'totalPrice',
        'isPermitted',
        'isHandOver',
        'bookingItems',
        'createdAt',
        'updatedAt',
        '__v',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user?.toJson(),
    'product': product?.toJson(),
    'productModel': productModel,
    'category': category,
    'date': date,
    'time': time,
    'duration': duration,
    'slots': slots,
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'isPermitted': isPermitted,
    'isHandOver': isHandOver,
    'bookingItems': bookingItems,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': version,
    if (extra != null) ...extra!,
  };
}

// =======================
// User
// =======================
class User {
  String? id;
  String? fullName;
  String? email;
  String? profileUrl;
  String? address;
  String? status;
  String? phoneNumber;
  Map<String, dynamic>? extra;

  User({
    this.id,
    this.fullName,
    this.email,
    this.profileUrl,
    this.address,
    this.status,
    this.phoneNumber,
    this.extra,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      profileUrl: json['profileUrl'],
      address: json['address'],
      status: json['status'],
      phoneNumber: json['phoneNumber'],
      extra: extractExtra(json, [
        '_id',
        'fullName',
        'email',
        'profileUrl',
        'address',
        'status',
        'phoneNumber',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'email': email,
    'profileUrl': profileUrl,
    'address': address,
    'status': status,
    'phoneNumber': phoneNumber,
    if (extra != null) ...extra!,
  };
}

// =======================
// Product
// =======================
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
  Map<String, dynamic>? extra;

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
    this.extra,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
      thumbnail: json['thumbnail'],
      title: json['title'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      priceByDuration: (json['priceByDuration'] as List?)
          ?.map((e) => PriceByDuration.fromJson(e))
          .toList(),
      serviceArea: json['serviceArea'],
      amount: json['amount'],
      benefits: json['benefits'],
      ourRecommendations: json['ourRecommendations'],
      extra: extractExtra(json, [
        '_id',
        'category',
        'thumbnail',
        'title',
        'openTime',
        'closeTime',
        'priceByDuration',
        'serviceArea',
        'amount',
        'benefits',
        'ourRecommendations',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'category': category?.toJson(),
    'thumbnail': thumbnail,
    'title': title,
    'openTime': openTime,
    'closeTime': closeTime,
    'priceByDuration': priceByDuration?.map((e) => e.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'benefits': benefits,
    'ourRecommendations': ourRecommendations,
    if (extra != null) ...extra!,
  };
}

// =======================
// Category
// =======================
class Category {
  String? id;
  String? name;
  String? categoryPhoto;
  Map<String, dynamic>? extra;

  Category({
    this.id,
    this.name,
    this.categoryPhoto,
    this.extra,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      categoryPhoto: json['categoryPhoto'],
      extra: extractExtra(json, ['_id', 'name', 'categoryPhoto']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'categoryPhoto': categoryPhoto,
    if (extra != null) ...extra!,
  };
}

// =======================
// PriceByDuration
// =======================
class PriceByDuration {
  String? id;
  String? duration;
  int? amount;
  Map<String, dynamic>? extra;

  PriceByDuration({
    this.id,
    this.duration,
    this.amount,
    this.extra,
  });

  factory PriceByDuration.fromJson(Map<String, dynamic> json) {
    return PriceByDuration(
      id: json['_id'],
      duration: json['duration'],
      amount: json['amount'],
      extra: extractExtra(json, ['_id', 'duration', 'amount']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'duration': duration,
    'amount': amount,
    if (extra != null) ...extra!,
  };
}
