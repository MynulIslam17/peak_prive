import 'package:flutter/foundation.dart';

class HireServiceModel {
  int? code;
  String? message;
  List<HireResult>? result;
  Pagination? pagination;

  HireServiceModel({
    this.code,
    this.message,
    this.result,
    this.pagination,
  });

  factory HireServiceModel.fromJson(Map<String, dynamic> json) {
    return HireServiceModel(
      code: json['code'],
      message: json['message'],
      pagination: json['data']?['pagination'] != null
          ? Pagination.fromJson(json['data']['pagination'])
          : null,
      result: json['data']?['result'] != null
          ? List<HireResult>.from(
          json['data']['result'].map((e) => HireResult.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': {
        'pagination': pagination?.toJson(),
        'result': result?.map((e) => e.toJson()).toList(),
      },
    };
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class HireResult {
  String? id;
  String? title;
  String? thumbnail;
  String? serviceArea;
  num? extraChargePerHour;
  num? totalPrice;
  num? averageRating;
  List<Item>? items;
  List<dynamic>? reviews;
  List<dynamic>? refunds;
  DateTime? createdAt;
  DateTime? updatedAt;
  Owner? owner;
  Category? category;

  HireResult({
    this.id,
    this.title,
    this.thumbnail,
    this.serviceArea,
    this.extraChargePerHour,
    this.totalPrice,
    this.averageRating,
    this.items,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.owner,
    this.category,
  });

  factory HireResult.fromJson(Map<String, dynamic> json) {
    return HireResult(
      id: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      serviceArea: json['serviceArea'],
      extraChargePerHour: json['extraChargePerHour'],
      totalPrice: json['totalPrice'],
      averageRating: json['averageRating'],
      items: json['items'] != null
          ? List<Item>.from(json['items'].map((e) => Item.fromJson(e)))
          : null,
      reviews: json['reviews'] != null ? List<dynamic>.from(json['reviews']) : [],
      refunds: json['refunds'] != null ? List<dynamic>.from(json['refunds']) : [],
      createdAt:
      json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'thumbnail': thumbnail,
      'serviceArea': serviceArea,
      'extraChargePerHour': extraChargePerHour,
      'totalPrice': totalPrice,
      'averageRating': averageRating,
      'items': items?.map((e) => e.toJson()).toList(),
      'reviews': reviews,
      'refunds': refunds,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'owner': owner?.toJson(),
      'category': category?.toJson(),
    };
  }
}

class Item {
  String? id;
  String? name;
  String? productPhoto;
  num? price;
  num? quantity;
  num? availableQty;

  Item({this.id, this.name, this.productPhoto, this.price, this.quantity, this.availableQty});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      name: json['productName'],
      productPhoto: json['productPhoto'],
      price: json['price'],
      quantity: json['totalQty'],
      availableQty: json['availableQty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': name,
      'productPhoto': productPhoto,
      'price': price,
      'totalQty': quantity,
      'availableQty': availableQty,
    };
  }
}

class Owner {
  String? id;
  String? fullName;
  String? email;
  String? profileUrl;
  String? providerType;
  String? status;
  String? role;
  String? phoneNumber;
  String? address;
  bool? isAgreedTermsCondition;
  bool? isAgreedTermsConditions;
  bool? isResetPassword;

  Owner({
    this.id,
    this.fullName,
    this.email,
    this.profileUrl,
    this.providerType,
    this.status,
    this.role,
    this.phoneNumber,
    this.address,
    this.isAgreedTermsCondition,
    this.isAgreedTermsConditions,
    this.isResetPassword,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      profileUrl: json['profileUrl'],
      providerType: json['providerType'],
      status: json['status'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      isAgreedTermsCondition: json['isAgreedTermsCondition'] ?? false,
      isAgreedTermsConditions: json['isAgreedTermsConditions'] ?? false,
      isResetPassword: json['isResetPassword'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profileUrl': profileUrl,
      'providerType': providerType,
      'status': status,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'isAgreedTermsCondition': isAgreedTermsCondition,
      'isAgreedTermsConditions': isAgreedTermsConditions,
      'isResetPassword': isResetPassword,
    };
  }
}

class Category {
  String? id;
  String? name;
  String? categoryPhoto;

  Category({this.id, this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      categoryPhoto: json['categoryPhoto'] ?? json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'categoryPhoto': categoryPhoto,
    };
  }
}
