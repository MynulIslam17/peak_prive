// ==========================================================
// All Models for Massage Service List in a Single File
// ==========================================================

import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart';

class MassageServiceModel {
  int? code;
  String? message;
  Data? data;

  MassageServiceModel({this.code, this.message, this.data});

  // Factory constructor for cleaner null checks in fromJson
  factory MassageServiceModel.fromJson(Map<String, dynamic> json) =>
      MassageServiceModel(
        code: json['code'] as int?,
        message: json['message'] as String?,
        data: json['data'] != null ? Data.fromJson(json['data']) : null,
      );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}

// ================= Data (CORRECTED) =================

class Data {
  Pagination? pagination; // Nested Pagination object
  List<MassageResult>? result; // Renamed to match JSON key "result"

  Data({this.pagination, this.result});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null,
    result: json['result'] != null
        ? (json['result'] as List)
        .map((e) => MassageResult.fromJson(e))
        .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
    'result': result?.map((v) => v.toJson()).toList(),
  };
}

// ================= Pagination (New/Corrected) =================

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int?,
    page: json['page'] as int?,
    limit: json['limit'] as int?,
    totalPages: json['totalPages'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

// ================= MassageResult =================

class MassageResult {
  String? sId;
  Category? category;
  Owner? owner;
  String? thumbnail;
  String? title;
  String? openTime;
  String? closeTime;
  List<PriceByDuration>? priceByDuration;
  String? serviceArea;
  int? amount;
  String? benefits; // Assuming this should be a single String based on JSON
  String? ourRecommendations;
  double? averageRating;
  List<Reviews>? reviews;
  List<dynamic>? refunds;
  String? createdAt;
  String? updatedAt;
  int? iV;

  MassageResult({
    this.sId,
    this.category,
    this.owner,
    this.thumbnail,
    this.title,
    this.openTime,
    this.closeTime,
    this.priceByDuration,
    this.serviceArea,
    this.amount,
    this.benefits,
    this.ourRecommendations,
    this.averageRating,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory MassageResult.fromRecentService(RecentService rs) => MassageResult(
    sId: rs.id,
    category: rs.category != null
        ? Category(
      sId: rs.category!.id,
      name: rs.category!.name,
      categoryPhoto: rs.category!.categoryPhoto,
    )
        : null,
    owner: Owner(
      sId: rs.owner,
      fullName: null,
      email: null,
      phone: null,
      providerType: null,
      status: null,
      role: null,
      profileUrl: null,
    ),
    thumbnail: rs.thumbnail,
    title: rs.title,
    openTime: rs.openTime,
    closeTime: rs.closeTime,
    priceByDuration: rs.priceByDuration.isNotEmpty
        ? rs.priceByDuration
        .map((p) => PriceByDuration(
      duration: p.duration,
      amount: p.amount.toInt(),
      sId: p.id,
    ))
        .toList()
        : null,
    serviceArea: rs.serviceArea,
    amount: rs.amount.toInt(),
    benefits: rs.benefits,
    ourRecommendations: rs.ourRecommendations,
    averageRating: rs.averageRating.toDouble(),
    reviews: rs.reviews.isNotEmpty
        ? rs.reviews
        .map((r) => Reviews(
      sId: r.userId,
      userId: r.userId,
      comment: r.comment,
      rating: r.rating,
      createdAt: r.createdAt,
    ))
        .toList()
        : null,
    refunds: rs.refunds.isNotEmpty ? rs.refunds : null,
    createdAt: rs.createdAt,
    updatedAt: rs.updatedAt,
    iV: rs.v,
  );


  factory MassageResult.fromJson(Map<String, dynamic> json) => MassageResult(
    sId: json['_id'] as String?,
    category: json['category'] != null
        ? Category.fromJson(json['category'])
        : null,
    owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
    thumbnail: json['thumbnail'] as String?,
    title: json['title'] as String?,
    openTime: json['openTime'] as String?,
    closeTime: json['closeTime'] as String?,
    priceByDuration: json['priceByDuration'] != null
        ? (json['priceByDuration'] as List)
        .map((e) => PriceByDuration.fromJson(e))
        .toList()
        : null,
    serviceArea: json['serviceArea'] as String?,
    amount: json['amount'] as int?,
    // Assuming benefits is a string if it's not a List in the final JSON
    benefits: json['benefits'] as String?,
    ourRecommendations: json['ourRecommendations'] as String?,
    averageRating: json['averageRating'] != null
        ? double.tryParse(json['averageRating'].toString())
        : null,
    reviews: json['reviews'] != null
        ? (json['reviews'] as List)
        .map((e) => Reviews.fromJson(e))
        .toList()
        : null,
    refunds: json['refunds'] != null
        ? List<dynamic>.from(json['refunds'] as List)
        : null,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
    iV: json['__v'] as int?,
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'category': category?.toJson(),
    'owner': owner?.toJson(),
    'thumbnail': thumbnail,
    'title': title,
    'openTime': openTime,
    'closeTime': closeTime,
    'priceByDuration': priceByDuration?.map((v) => v.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'benefits': benefits,
    'ourRecommendations': ourRecommendations,
    'averageRating': averageRating,
    'reviews': reviews?.map((v) => v.toJson()).toList(),
    'refunds': refunds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': iV,
  };
}

// ================= Category (CORRECTED) =================

class Category {
  String? sId;
  String? name; // Matches JSON key "name"
  String? categoryPhoto; // Matches JSON key "categoryPhoto"

  Category({this.sId, this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    sId: json['_id'] as String?,
    name: json['name'] as String?,
    categoryPhoto: json['categoryPhoto'] as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'name': name,
    'categoryPhoto': categoryPhoto,
  };
}

// ================= Owner =================

class Owner {
  String? sId;
  String? fullName;
  String? email;
  String? phone;
  // Added fields present in your JSON that weren't in your original Owner model
  String? providerType;
  String? status;
  String? role;
  String? profileUrl;

  Owner({
    this.sId,
    this.fullName,
    this.email,
    this.phone,
    this.providerType,
    this.status,
    this.role,
    this.profileUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    sId: json['_id'] as String?,
    fullName: json['fullName'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    providerType: json['providerType'] as String?,
    status: json['status'] as String?,
    role: json['role'] as String?,
    profileUrl: json['profileUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'providerType': providerType,
    'status': status,
    'role': role,
    'profileUrl': profileUrl,
  };
}

// ================= PriceByDuration =================

class PriceByDuration {
  String? duration;
  int? amount; // Renamed from 'price' to 'amount' to match the JSON key
  String? sId;

  PriceByDuration({this.duration, this.amount, this.sId});

  factory PriceByDuration.fromJson(Map<String, dynamic> json) =>
      PriceByDuration(
        duration: json['duration'] as String?,
        amount: json['amount'] as int?,
        sId: json['_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'amount': amount,
    '_id': sId,
  };
}

// ================= Reviews =================

class Reviews {
  String? sId;

  dynamic reviewer;
  // Using userId (present in the JSON)
  String? userId;

  String? comment;
  double? rating; // Changed to double to match JSON (4.5)
  String? createdAt;

  Reviews({this.sId, this.reviewer, this.comment, this.rating, this.createdAt, this.userId});

  factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
    sId: json['_id'] as String?,
    // Assuming reviewer is a map if it exists, otherwise it's just the userId
    reviewer: json['reviewer'],
    userId: json['userId'] as String?,
    comment: json['comment'] as String?,
    rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    createdAt: json['createdAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'reviewer': reviewer,
    'userId': userId,
    'comment': comment,
    'rating': rating,
    'createdAt': createdAt,
  };
}