import 'dart:convert';

class SkiHireModel {
  final List<SkiHireItem> result;

  SkiHireModel({required this.result});

  factory SkiHireModel.fromJson(Map<String, dynamic> json) {
    return SkiHireModel(
      result: (json['result'] as List)
          .map((e) => SkiHireItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((e) => e.toJson()).toList(),
    };
  }
}

class SkiHireItem {
  final String id;
  final Category? category;
  final String title;
  final String thumbnail;
  final Owner owner;
  final double extraChargePerHour;
  final double totalPrice;
  final String serviceArea;
  final List<Item> items;
  final double averageRating;
  final List<dynamic> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;

  SkiHireItem({
    required this.id,
    this.category,
    required this.title,
    required this.thumbnail,
    required this.owner,
    required this.extraChargePerHour,
    required this.totalPrice,
    required this.serviceArea,
    required this.items,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkiHireItem.fromJson(Map<String, dynamic> json) {
    return SkiHireItem(
      id: json['_id'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      owner: Owner.fromJson(json['owner']),
      extraChargePerHour:
      (json['extraChargePerHour']?.toDouble() ?? 0.0),
      totalPrice: (json['totalPrice']?.toDouble() ?? 0.0),
      serviceArea: json['serviceArea'] ?? '',
      items: (json['items'] as List)
          .map((e) => Item.fromJson(e))
          .toList(),
      averageRating: (json['averageRating']?.toDouble() ?? 0.0),
      reviews: json['reviews'] ?? [],
      refunds: json['refunds'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category?.toJson(),
      'title': title,
      'thumbnail': thumbnail,
      'owner': owner.toJson(),
      'extraChargePerHour': extraChargePerHour,
      'totalPrice': totalPrice,
      'serviceArea': serviceArea,
      'items': items.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'reviews': reviews,
      'refunds': refunds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String categoryPhoto;

  Category({required this.id, required this.name, required this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'] ?? '',
      categoryPhoto: json['categoryPhoto'] ?? '',
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

class Owner {
  final String id;
  final String fullName;
  final String profileUrl;
  final String address;
  final String email;
  final String providerType;
  final String status;
  final String role;
  final bool isAgreedTermsCondition;
  final bool isAgreedTermsConditions;
  final bool isResetPassword;

  Owner({
    required this.id,
    required this.fullName,
    required this.profileUrl,
    required this.address,
    required this.email,
    required this.providerType,
    required this.status,
    required this.role,
    required this.isAgreedTermsCondition,
    required this.isAgreedTermsConditions,
    required this.isResetPassword,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'],
      fullName: json['fullName'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      providerType: json['providerType'] ?? '',
      status: json['status'] ?? '',
      role: json['role'] ?? '',
      isAgreedTermsCondition: json['isAgreedTermsCondition'] ?? false,
      isAgreedTermsConditions: json['isAgreedTermsConditions'] ?? false,
      isResetPassword: json['isResetPassword'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'profileUrl': profileUrl,
      'address': address,
      'email': email,
      'providerType': providerType,
      'status': status,
      'role': role,
      'isAgreedTermsCondition': isAgreedTermsCondition,
      'isAgreedTermsConditions': isAgreedTermsConditions,
      'isResetPassword': isResetPassword,
    };
  }
}

class Item {
  final String id;
  final String productName;
  final String productPhoto;
  final double price;
  final int totalQty;
  final int availableQty;

  Item({
    required this.id,
    required this.productName,
    required this.productPhoto,
    required this.price,
    required this.totalQty,
    required this.availableQty,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      productName: json['productName'] ?? '',
      productPhoto: json['productPhoto'] ?? '',
      price: (json['price']?.toDouble() ?? 0.0),
      totalQty: json['totalQty'] ?? 0,
      availableQty: json['availableQty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': productName,
      'productPhoto': productPhoto,
      'price': price,
      'totalQty': totalQty,
      'availableQty': availableQty,
    };
  }
}
