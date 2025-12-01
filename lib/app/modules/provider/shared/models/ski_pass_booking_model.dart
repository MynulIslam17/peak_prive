class ProviderBookingModel {
  final int? code;
  final String? message;
  final Data? data;

  ProviderBookingModel({this.code, this.message, this.data});

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    return ProviderBookingModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }
}

class Data {
  final Pagination? pagination;
  final List<Result>? result;

  Data({this.pagination, this.result});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      pagination:
      json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      result: json['result'] != null
          ? (json['result'] as List).map((e) => Result.fromJson(e)).toList()
          : null,
    );
  }
}

class Pagination {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }
}

class Result {
  final String? id;
  final User? user;
  final Product? product;
  final String? productModel;
  final String? category;
  final int? personCount;
  final String? date;
  final String? time;
  final List<String>? slots;
  final String? bookingStatus;
  final int? totalPrice;
  final bool? isPermitted;
  final List<dynamic>? bookingItems;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  Result({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.date,
    this.time,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      personCount: json['personCount'],
      date: json['date'],
      time: json['time'],
      slots: json['slots'] != null ? List<String>.from(json['slots']) : null,
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      isPermitted: json['isPermitted'],
      bookingItems: json['bookingItems'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? address;
  final String? phoneNumber;

  User({this.id, this.fullName, this.email, this.address, this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class Product {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? owner;
  final String? skiPassType;
  final List<Services>? services;
  final int? amount;
  final String? description;

  Product({
    this.id,
    this.title,
    this.thumbnail,
    this.owner,
    this.skiPassType,
    this.services,
    this.amount,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      owner: json['owner'],
      skiPassType: json['skiPassType'],
      services: json['services'] != null
          ? (json['services'] as List).map((e) => Services.fromJson(e)).toList()
          : null,
      amount: json['amount'],
      description: json['description'],
    );
  }
}

class Services {
  final String? title;
  final String? description;

  Services({this.title, this.description});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      title: json['title'],
      description: json['description'],
    );
  }
}
