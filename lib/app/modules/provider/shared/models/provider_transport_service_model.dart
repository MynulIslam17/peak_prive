import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart';
import '../../../../core/utils/json_helper.dart';

class TransportServiceModel {
  int? code;
  String? message;
  Data? data;

  TransportServiceModel({this.code, this.message, this.data});

  factory TransportServiceModel.fromJson(Map<String, dynamic> json) {
    return TransportServiceModel(
      code: JsonHelper.getInt(json['code']),
      message: JsonHelper.getString(json['message']),
      data: JsonHelper.getMap(json['data']) != null
          ? Data.fromJson(JsonHelper.getMap(json['data'])!)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  Pagination? pagination;
  List<TransportResult>? result;

  Data({this.pagination, this.result});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      pagination: JsonHelper.getMap(json['pagination']) != null
          ? Pagination.fromJson(JsonHelper.getMap(json['pagination'])!)
          : null,
      result: List<TransportResult>.from(
        JsonHelper.getList(json['result'])
            .map((x) => TransportResult.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (pagination != null) data['pagination'] = pagination!.toJson();
    data['result'] = result?.map((x) => x.toJson()).toList();
    return data;
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
      total: JsonHelper.getInt(json['total']),
      page: JsonHelper.getInt(json['page']),
      limit: JsonHelper.getInt(json['limit']),
      totalPages: JsonHelper.getInt(json['totalPages']),
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

class TransportResult {
  String? sId;
  String? owner;
  Category? category;
  String? thumbnail;
  String? title;
  String? personCount;
  String? milage;
  String? power;
  String? extraChargePerHours;
  int? insuranceFee;
  int? maintainCharge;
  String? serviceArea;
  int? amount;
  String? description;
  int? averageRating;
  List<dynamic>? reviews;
  List<dynamic>? refunds;
  String? createdAt;
  String? updatedAt;
  int? iV;

  TransportResult({
    this.sId,
    this.owner,
    this.category,
    this.thumbnail,
    this.title,
    this.personCount,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.serviceArea,
    this.amount,
    this.description,
    this.averageRating,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory TransportResult.fromRecentService(RecentService recentService) {
    try {
      return TransportResult(
        sId: recentService.id,
        owner: recentService.owner,
        category: recentService.category != null
            ? Category(
          name: recentService.category!.name,
          categoryPhoto: recentService.category!.categoryPhoto,
          sId: recentService.category!.id,
        )
            : null,
        thumbnail: recentService.thumbnail,
        title: recentService.title,
        personCount: recentService.personCount,
        milage: recentService.milage,
        power: recentService.power,
        extraChargePerHours: recentService.extraChargePerHours,
        insuranceFee: (recentService.insuranceFee ?? 0).toInt(),
        maintainCharge: (recentService.maintainCharge ?? 0).toInt(),
        serviceArea: recentService.serviceArea,
        amount: (recentService.amount ?? 0).toInt(),
        description: recentService.description,
        averageRating: (recentService.averageRating ?? 0).toInt(),
        reviews: recentService.reviews.isNotEmpty ? recentService.reviews : [],
        refunds: recentService.refunds.isNotEmpty ? recentService.refunds : [],
        createdAt: recentService.createdAt,
        updatedAt: recentService.updatedAt,
        iV: recentService.v,
      );
    } catch (e) {
      rethrow;
    }
  }

  factory TransportResult.fromJson(Map<String, dynamic> json) {
    return TransportResult(
      sId: JsonHelper.getString(json['_id']),
      owner: JsonHelper.getString(json['owner']),
      category: JsonHelper.getMap(json['category']) != null
          ? Category.fromJson(JsonHelper.getMap(json['category'])!)
          : null,
      thumbnail: JsonHelper.getString(json['thumbnail']),
      title: JsonHelper.getString(json['title']),
      personCount: JsonHelper.getString(json['personCount']),
      milage: JsonHelper.getString(json['milage']),
      power: JsonHelper.getString(json['power']),
      extraChargePerHours:
      JsonHelper.getString(json['extraChargePerHours']),
      insuranceFee: JsonHelper.getInt(json['insuranceFee']),
      maintainCharge: JsonHelper.getInt(json['maintainCharge']),
      serviceArea: JsonHelper.getString(json['serviceArea']),
      amount: JsonHelper.getInt(json['amount']),
      description: JsonHelper.getString(json['description']),
      averageRating: JsonHelper.getInt(json['averageRating']),
      reviews: JsonHelper.getList(json['reviews']),
      refunds: JsonHelper.getList(json['refunds']),
      createdAt: JsonHelper.getString(json['createdAt']),
      updatedAt: JsonHelper.getString(json['updatedAt']),
      iV: JsonHelper.getInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['owner'] = owner;
    if (category != null) data['category'] = category!.toJson();
    data['thumbnail'] = thumbnail;
    data['title'] = title;
    data['personCount'] = personCount;
    data['milage'] = milage;
    data['power'] = power;
    data['extraChargePerHours'] = extraChargePerHours;
    data['insuranceFee'] = insuranceFee;
    data['maintainCharge'] = maintainCharge;
    data['serviceArea'] = serviceArea;
    data['amount'] = amount;
    data['description'] = description;
    data['averageRating'] = averageRating;
    data['reviews'] = reviews ?? [];
    data['refunds'] = refunds ?? [];
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Category {
  String? name;
  String? categoryPhoto;
  String? sId;

  Category({this.name, this.categoryPhoto, this.sId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: JsonHelper.getString(json['name']),
      categoryPhoto: JsonHelper.getString(json['categoryPhoto']),
      sId: JsonHelper.getString(json['_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryPhoto': categoryPhoto,
      '_id': sId,
    };
  }
}