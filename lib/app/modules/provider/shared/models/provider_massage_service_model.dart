import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart';
import '../../../../core/utils/json_helper.dart';

class MassageServiceModel {
  int? code;
  String? message;
  Data? data;

  MassageServiceModel({this.code, this.message, this.data});

  factory MassageServiceModel.fromJson(Map<String, dynamic> json) =>
      MassageServiceModel(
        code: JsonHelper.getInt(json['code']),
        message: JsonHelper.getString(json['message']),
        data: JsonHelper.getMap(json['data']) != null
            ? Data.fromJson(JsonHelper.getMap(json['data'])!)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  Pagination? pagination;
  List<MassageResult>? result;

  Data({this.pagination, this.result});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: JsonHelper.getMap(json['pagination']) != null
        ? Pagination.fromJson(JsonHelper.getMap(json['pagination'])!)
        : null,
    result: json['result'] != null
        ? JsonHelper.getList(json['result'])
        .map((e) => MassageResult.fromJson(e))
        .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
    'result': result?.map((v) => v.toJson()).toList(),
  };
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: JsonHelper.getInt(json['total']),
    page: JsonHelper.getInt(json['page']),
    limit: JsonHelper.getInt(json['limit']),
    totalPages: JsonHelper.getInt(json['totalPages']),
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

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
  String? benefits;
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

  factory MassageResult.fromJson(Map<String, dynamic> json) =>
      MassageResult(
        sId: JsonHelper.getString(json['_id']),
        category: json['category'] != null
            ? Category.fromJson(json['category'])
            : null,
        owner: json['owner'] != null
            ? Owner.fromJson(json['owner'])
            : null,
        thumbnail: JsonHelper.getString(json['thumbnail']),
        title: JsonHelper.getString(json['title']),
        openTime: JsonHelper.getString(json['openTime']),
        closeTime: JsonHelper.getString(json['closeTime']),
        priceByDuration: json['priceByDuration'] != null
            ? JsonHelper.getList(json['priceByDuration'])
            .map((e) => PriceByDuration.fromJson(e))
            .toList()
            : null,
        serviceArea: JsonHelper.getString(json['serviceArea']),
        amount: JsonHelper.getInt(json['amount']),
        benefits: JsonHelper.getString(json['benefits']),
        ourRecommendations:
        JsonHelper.getString(json['ourRecommendations']),
        averageRating:
        JsonHelper.getDouble(json['averageRating']),
        reviews: json['reviews'] != null
            ? JsonHelper.getList(json['reviews'])
            .map((e) => Reviews.fromJson(e))
            .toList()
            : null,
        refunds: json['refunds'] != null
            ? JsonHelper.getList(json['refunds'])
            : null,
        createdAt: JsonHelper.getString(json['createdAt']),
        updatedAt: JsonHelper.getString(json['updatedAt']),
        iV: JsonHelper.getInt(json['__v']),
      );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'category': category?.toJson(),
    'owner': owner?.toJson(),
    'thumbnail': thumbnail,
    'title': title,
    'openTime': openTime,
    'closeTime': closeTime,
    'priceByDuration':
    priceByDuration?.map((v) => v.toJson()).toList(),
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

class Category {
  String? sId;
  String? name;
  String? categoryPhoto;

  Category({this.sId, this.name, this.categoryPhoto});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    sId: JsonHelper.getString(json['_id']),
    name: JsonHelper.getString(json['name']),
    categoryPhoto:
    JsonHelper.getString(json['categoryPhoto']),
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'name': name,
    'categoryPhoto': categoryPhoto,
  };
}

class Owner {
  String? sId;
  String? fullName;
  String? email;
  String? phone;
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
    sId: JsonHelper.getString(json['_id']),
    fullName: JsonHelper.getString(json['fullName']),
    email: JsonHelper.getString(json['email']),
    phone: JsonHelper.getString(json['phoneNumber']),
    providerType:
    JsonHelper.getString(json['providerType']),
    status: JsonHelper.getString(json['status']),
    role: JsonHelper.getString(json['role']),
    profileUrl:
    JsonHelper.getString(json['profileUrl']),
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

class PriceByDuration {
  String? duration;
  int? amount;
  String? sId;

  PriceByDuration({this.duration, this.amount, this.sId});

  factory PriceByDuration.fromJson(Map<String, dynamic> json) =>
      PriceByDuration(
        duration: JsonHelper.getString(json['duration']),
        amount: JsonHelper.getInt(json['amount']),
        sId: JsonHelper.getString(json['_id']),
      );

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'amount': amount,
    '_id': sId,
  };
}

class Reviews {
  String? sId;
  dynamic reviewer;
  String? userId;
  String? comment;
  double? rating;
  String? createdAt;

  Reviews({
    this.sId,
    this.reviewer,
    this.userId,
    this.comment,
    this.rating,
    this.createdAt,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
    sId: JsonHelper.getString(json['_id']),
    reviewer: json['reviewer'],
    userId: JsonHelper.getString(json['userId']),
    comment: JsonHelper.getString(json['comment']),
    rating: JsonHelper.getDouble(json['rating']),
    createdAt: JsonHelper.getString(json['createdAt']),
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