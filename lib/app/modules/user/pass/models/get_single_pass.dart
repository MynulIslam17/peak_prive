class GetSinglePass {
  final int? code;
  final String? message;
  final BookingData? data;

  GetSinglePass({this.code, this.message, this.data});

  factory GetSinglePass.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GetSinglePass();

    return GetSinglePass(
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? BookingData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}
class BookingData {
  final String? id;
  final User? user;
  final Product? product;
  final String? productModel;
  final String? category;
  final int? personCount;
  final DateTime? date;
  final String? time;
  final List<dynamic> slots;
  final String? bookingStatus;
  final int? totalPrice;
  final bool? isPermitted;
  final bool? isHandOver;
  final List<dynamic> bookingItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  BookingData({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.date,
    this.time,
    this.slots = const [],
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.isHandOver,
    this.bookingItems = const [],
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory BookingData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingData();

    DateTime? _parseDate(String? value) {
      try {
        return value != null ? DateTime.parse(value) : null;
      } catch (_) {
        return null;
      }
    }

    return BookingData(
      id: json['_id'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      product: json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'])
          : null,
      productModel: json['productModel'] as String?,
      category: json['category'] as String?,
      personCount: json['personCount'] as int?,
      date: _parseDate(json['date'] as String?),
      time: json['time'] as String?,
      slots: json['slots'] is List ? List.from(json['slots']) : const [],
      bookingStatus: json['bookingStatus'] as String?,
      totalPrice: json['totalPrice'] as int?,
      isPermitted: json['isPermitted'] as bool?,
      isHandOver: json['isHandOver'] as bool?,
      bookingItems:
      json['bookingItems'] is List ? List.from(json['bookingItems']) : const [],
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String?),
      version: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user?.toJson(),
    'product': product?.toJson(),
    'productModel': productModel,
    'category': category,
    'personCount': personCount,
    'date': date?.toIso8601String(),
    'time': time,
    'slots': slots,
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'isPermitted': isPermitted,
    'isHandOver': isHandOver,
    'bookingItems': bookingItems,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    '__v': version,
  };
}


class User {
  final String? id;
  final String? email;
  final String? status;
  final String? address;
  final String? fullName;
  final String? profileUrl;

  User({
    this.id,
    this.email,
    this.status,
    this.address,
    this.fullName,
    this.profileUrl,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User();

    return User(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
      address: json['address'] as String?,
      fullName: json['fullName'] as String?,
      profileUrl: json['profileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'status': status,
    'address': address,
    'fullName': fullName,
    'profileUrl': profileUrl,
  };
}
class Product {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? skiPassType;
  final List<Service> services;
  final String? serviceArea;
  final int? amount;
  final String? description;

  Product({
    this.id,
    this.title,
    this.thumbnail,
    this.skiPassType,
    this.services = const [],
    this.serviceArea,
    this.amount,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Product();

    return Product(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      skiPassType: json['skiPassType'] as String?,
      services: json['services'] is List
          ? (json['services'] as List)
          .map((e) => e is Map<String, dynamic>
          ? Service.fromJson(e)
          : Service())
          .toList()
          : const [],
      serviceArea: json['serviceArea'] as String?,
      amount: json['amount'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'thumbnail': thumbnail,
    'skiPassType': skiPassType,
    'services': services.map((e) => e.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'description': description,
  };
}

class Service {
  final String? title;
  final String? description;

  Service({this.title, this.description});

  factory Service.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Service();

    return Service(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}

