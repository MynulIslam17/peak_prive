import 'dart:convert';
import '../../../../core/utils/json_helper.dart';


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
      total: JsonHelper.getInt(json["total"]),
      page: JsonHelper.getInt(json["page"]),
      limit: JsonHelper.getInt(json["limit"]),
      totalPages: JsonHelper.getInt(json["totalPages"]),
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
  final int personCount;
  final int milage;
  final int power;
  final int extraChargePerHours;
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
    this.personCount = 0,
    this.milage = 0,
    this.power = 0,
    this.extraChargePerHours = 0,
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
      id: JsonHelper.getString(json["_id"]),
      owner: JsonHelper.getString(json["owner"]),
      category:
      JsonHelper.getMap(json["category"]) != null ? Category.fromJson(json["category"]) : null,
      thumbnail: JsonHelper.getString(json["thumbnail"]),
      title: JsonHelper.getString(json["title"]),
      personCount: JsonHelper.getInt(json["personCount"]),
      milage: JsonHelper.getInt(json["milage"]),
      power: JsonHelper.getInt(json["power"]),
      extraChargePerHours: JsonHelper.getInt(json["extraChargePerHours"]),
      insuranceFee: JsonHelper.getInt(json["insuranceFee"]),
      maintainCharge: JsonHelper.getInt(json["maintainCharge"]),
      serviceArea: JsonHelper.getString(json["serviceArea"]),
      amount: JsonHelper.getInt(json["amount"]),
      description: JsonHelper.getString(json["description"]),
      averageRating: JsonHelper.getDouble(json["averageRating"]),
      reviews: JsonHelper.getList(json["reviews"]),
      refunds: JsonHelper.getList(json["refunds"]),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(JsonHelper.getString(json["createdAt"]))
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(JsonHelper.getString(json["updatedAt"]))
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
      name: JsonHelper.getString(json["name"]),
      categoryPhoto: JsonHelper.getString(json["categoryPhoto"]),
      id: JsonHelper.getString(json["_id"]),
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