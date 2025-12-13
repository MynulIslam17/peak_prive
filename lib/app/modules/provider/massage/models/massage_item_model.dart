class MassageItemModel {
  int? code;
  String? message;
  Data? data;

  MassageItemModel({this.code, this.message, this.data});

  factory MassageItemModel.fromJson(Map<String, dynamic> json) {
    return MassageItemModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
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
  List<dynamic>? slots; // corrected
  String? duration;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  List<dynamic>? bookingItems; // corrected
  String? createdAt;
  String? updatedAt;
  int? iV;

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
  };
}

class User {
  String? sId;
  String? email;
  String? status;
  String? address;
  String? fullName;
  String? profileUrl;

  User({this.sId, this.email, this.status, this.address, this.fullName, this.profileUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      email: json['email'],
      status: json['status'],
      address: json['address'],
      fullName: json['fullName'],
      profileUrl: json['profileUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'email': email,
    'status': status,
    'address': address,
    'fullName': fullName,
    'profileUrl': profileUrl,
  };
}

class Product {
  String? sId;
  String? category;
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sId: json['_id'],
      category: json['category'],
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
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'category': category,
    'thumbnail': thumbnail,
    'title': title,
    'openTime': openTime,
    'closeTime': closeTime,
    'priceByDuration': priceByDuration?.map((x) => x.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'benefits': benefits,
    'ourRecommendations': ourRecommendations,
  };
}

class PriceByDuration {
  String? duration;
  int? amount;
  String? sId;

  PriceByDuration({this.duration, this.amount, this.sId});

  factory PriceByDuration.fromJson(Map<String, dynamic> json) {
    return PriceByDuration(
      duration: json['duration'],
      amount: json['amount'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'amount': amount,
    '_id': sId,
  };
}
