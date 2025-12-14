class MassageItemModel {
  int? code;
  String? message;
  Data? data;
  Map<String, dynamic>? extra; // catch-all for unexpected fields

  MassageItemModel({this.code, this.message, this.data, this.extra});

  factory MassageItemModel.fromJson(Map<String, dynamic> json) {
    return MassageItemModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      extra: json, // store everything else
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    if (extra != null) map.addAll(extra!); // keep extra fields
    return map;
  }
}

class Data {
  String? sId;
  User? user;
  Product? product;
  String? productModel;
  String? category;
  int? personCount;
  String? date;
  String? time;
  List<dynamic>? slots;
  String? duration;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  List<dynamic>? bookingItems;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Map<String, dynamic>? extra;

  Data({
    this.sId,
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
    this.iV,
    this.extra,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sId: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      personCount: json['personCount'],
      date: json['date'],
      time: json['time'],
      slots: json['slots'] != null ? List<dynamic>.from(json['slots']) : [],
      duration: json['duration'],
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      isPermitted: json['isPermitted'],
      bookingItems: json['bookingItems'] != null ? List<dynamic>.from(json['bookingItems']) : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'user': user?.toJson(),
    'product': product?.toJson(),
    'productModel': productModel,
    'category': category,
    'personCount': personCount,
    'date': date,
    'time': time,
    'slots': slots,
    'duration': duration,
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'isPermitted': isPermitted,
    'bookingItems': bookingItems,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': iV,
    if (extra != null) ...extra!,
  };
}

class User {
  String? sId;
  String? fullName;
  String? email;
  String? profileUrl;
  String? address;
  String? status;
  String? phoneNumber;
  Map<String, dynamic>? extra;

  User({
    this.sId,
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
      sId: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      profileUrl: json['profileUrl'],
      address: json['address'],
      status: json['status'],
      phoneNumber: json['phoneNumber'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'fullName': fullName,
    'email': email,
    'profileUrl': profileUrl,
    'address': address,
    'status': status,
    'phoneNumber': phoneNumber,
    if (extra != null) ...extra!,
  };
}

class Product {
  String? sId;
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
    this.sId,
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
      sId: json['_id'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      thumbnail: json['thumbnail'],
      title: json['title'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      priceByDuration: json['priceByDuration'] != null
          ? List<PriceByDuration>.from(json['priceByDuration'].map((x) => PriceByDuration.fromJson(x)))
          : [],
      serviceArea: json['serviceArea'],
      amount: json['amount'],
      benefits: json['benefits'],
      ourRecommendations: json['ourRecommendations'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'category': category?.toJson(),
    'thumbnail': thumbnail,
    'title': title,
    'openTime': openTime,
    'closeTime': closeTime,
    'priceByDuration': priceByDuration?.map((x) => x.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'benefits': benefits,
    'ourRecommendations': ourRecommendations,
    if (extra != null) ...extra!,
  };
}

class Category {
  String? name;
  String? categoryPhoto;
  String? sId;
  Map<String, dynamic>? extra;

  Category({this.name, this.categoryPhoto, this.sId, this.extra});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      categoryPhoto: json['categoryPhoto'],
      sId: json['_id'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'categoryPhoto': categoryPhoto,
    '_id': sId,
    if (extra != null) ...extra!,
  };
}

class PriceByDuration {
  String? duration;
  int? amount;
  String? sId;
  Map<String, dynamic>? extra;

  PriceByDuration({this.duration, this.amount, this.sId, this.extra});

  factory PriceByDuration.fromJson(Map<String, dynamic> json) {
    return PriceByDuration(
      duration: json['duration'],
      amount: json['amount'],
      sId: json['_id'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'amount': amount,
    '_id': sId,
    if (extra != null) ...extra!,
  };
}
