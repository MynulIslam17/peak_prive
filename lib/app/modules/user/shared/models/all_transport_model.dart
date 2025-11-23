import 'dart:convert';

class TransportModel {
  final Pagination? pagination;
  final List<TransportItem> results;

  TransportModel({
    this.pagination,
    this.results = const [],
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      pagination: json["data"]?["pagination"] != null
          ? Pagination.fromJson(json["data"]["pagination"])
          : null,
      results: (json["data"]?["result"] as List<dynamic>? ?? [])
          .map((e) => TransportItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pagination": pagination?.toJson(),
      "result": results.map((e) => e.toJson()).toList(),
    };
  }
}

/// ----------------------
/// PAGINATION MODEL
/// ----------------------
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    this.total = 0,
    this.page = 0,
    this.limit = 0,
    this.totalPages = 0,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json["total"] ?? 0,
      page: json["page"] ?? 0,
      limit: json["limit"] ?? 0,
      totalPages: json["totalPages"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "page": page,
      "limit": limit,
      "totalPages": totalPages,
    };
  }
}

/// ----------------------
/// TRANSPORT ITEM MODEL
/// ----------------------
class TransportItem {
  final String id;
  final String owner;
  final Category? category;
  final String thumbnail;
  final String title;
  final String personCount;
  final String milage;
  final String power;
  final String extraChargePerHours;
  final int insuranceFee;
  final int maintainCharge;
  final String serviceArea;
  final int amount;
  final String description;
  final double averageRating;
  final List<dynamic> reviews;
  final List<dynamic> refunds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransportItem({
    this.id = "",
    this.owner = "",
    this.category,
    this.thumbnail = "",
    this.title = "",
    this.personCount = "0",
    this.milage = "0",
    this.power = "0",
    this.extraChargePerHours = "0",
    this.insuranceFee = 0,
    this.maintainCharge = 0,
    this.serviceArea = "",
    this.amount = 0,
    this.description = "",
    this.averageRating = 0.0,
    this.reviews = const [],
    this.refunds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TransportItem.fromJson(Map<String, dynamic> json) {
    return TransportItem(
      id: json["_id"] ?? "",
      owner: json["owner"] ?? "",
      category:
      json["category"] != null ? Category.fromJson(json["category"]) : null,
      thumbnail: json["thumbnail"] ?? "",
      title: json["title"] ?? "",
      personCount: json["personCount"] ?? "0",
      milage: json["milage"] ?? "0",
      power: json["power"] ?? "0",
      extraChargePerHours: json["extraChargePerHours"] ?? "0",
      insuranceFee: json["insuranceFee"] ?? 0,
      maintainCharge: json["maintainCharge"] ?? 0,
      serviceArea: json["serviceArea"] ?? "",
      amount: json["amount"] ?? 0,
      description: json["description"] ?? "",
      averageRating:
      (json["averageRating"] is int) ? (json["averageRating"] + 0.0) : (json["averageRating"] ?? 0.0),
      reviews: json["reviews"] ?? [],
      refunds: json["refunds"] ?? [],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "owner": owner,
      "category": category?.toJson(),
      "thumbnail": thumbnail,
      "title": title,
      "personCount": personCount,
      "milage": milage,
      "power": power,
      "extraChargePerHours": extraChargePerHours,
      "insuranceFee": insuranceFee,
      "maintainCharge": maintainCharge,
      "serviceArea": serviceArea,
      "amount": amount,
      "description": description,
      "averageRating": averageRating,
      "reviews": reviews,
      "refunds": refunds,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

/// ----------------------
/// CATEGORY MODEL
/// ----------------------
class Category {
  final String name;
  final String categoryPhoto;
  final String id;

  Category({
    this.name = "",
    this.categoryPhoto = "",
    this.id = "",
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"] ?? "",
      categoryPhoto: json["categoryPhoto"] ?? "",
      id: json["_id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "categoryPhoto": categoryPhoto,
      "_id": id,
    };
  }
}
