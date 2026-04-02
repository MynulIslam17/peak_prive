class SkiPassItemModel {
  final int code;
  final String message;
  final Data? data;

  SkiPassItemModel({
    required this.code,
    required this.message,
    this.data,
  });

  factory SkiPassItemModel.fromJson(Map<String, dynamic> json) {
    return SkiPassItemModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  final String sId;
  final User? user;
  final Product? product;
  final String productModel;
  final String category;
  final int personCount;
  final String date;
  String? phoneNumber;
  final String time;
  final List<dynamic> slots;
  final String bookingStatus;
  final int totalPrice;
  final bool isPermitted;
  final List<dynamic> bookingItems;
  final String createdAt;
  final String updatedAt;
  final int iV;

  Data({
    required this.sId,
    this.user,
    this.product,
    this.phoneNumber,
    required this.productModel,
    required this.category,
    required this.personCount,
    required this.date,
    required this.time,
    required this.slots,
    required this.bookingStatus,
    required this.totalPrice,
    required this.isPermitted,
    required this.bookingItems,
    required this.createdAt,
    required this.updatedAt,
    required this.iV,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sId: json['_id'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'] ?? '',
      category: json['category'] ?? '',
      personCount: json['personCount'] ?? 0,
      phoneNumber: json['phoneNumber'],
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      slots: json['slots'] ?? [],
      bookingStatus: json['bookingStatus'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      isPermitted: json['isPermitted'] ?? false,
      bookingItems: json['bookingItems'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      iV: json['__v'] ?? 0,
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
  final String sId;
  final String fullName;
  final String email;
  final String profileUrl;
  final String address;
  final String status;
  final String phoneNumber;

  User({
    required this.sId,
    required this.fullName,
    required this.email,
    required this.profileUrl,
    required this.address,
    required this.status,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
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
  };
}

class Product {
  final String sId;
  final String title;
  final String thumbnail;
  final String skiPassType;
  final List<Services> services;
  final String serviceArea;
  final int amount;
  final String description;

  Product({
    required this.sId,
    required this.title,
    required this.thumbnail,
    required this.skiPassType,
    required this.services,
    required this.serviceArea,
    required this.amount,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sId: json['_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      skiPassType: json['skiPassType'] ?? '',
      services: json['services'] != null
          ? List<Services>.from(json['services'].map((x) => Services.fromJson(x)))
          : [],
      serviceArea: json['serviceArea'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'title': title,
    'thumbnail': thumbnail,
    'skiPassType': skiPassType,
    'services': services.map((x) => x.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'description': description,
  };
}

class Services {
  final String title;
  final String description;

  Services({
    required this.title,
    required this.description,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}
