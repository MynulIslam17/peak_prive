import '../../../../core/utils/json_helper.dart';

class SkiPassResponse {
  final int code;
  final String message;
  final List<SkiPass> result;

  SkiPassResponse({
    required this.code,
    required this.message,
    required this.result,
  });

  factory SkiPassResponse.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    final data = JsonHelper.getMap(json['data']) ?? {};

    return SkiPassResponse(
      code: JsonHelper.getInt(json['code']),
      message: JsonHelper.getString(json['message']),
      result: JsonHelper.getList(data['result'])
          .map((e) => SkiPass.fromJson(JsonHelper.getMap(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "result": result.map((e) => e.toJson()).toList(),
  };
}

class SkiPass {
  final String id;
  final String title;
  final String thumbnail;
  final String owner;
  final String skiPassType;
  final List<ProductService> services;
  final String serviceArea;
  final num amount;
  final String description;
  final num averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final String createdAt;
  final String updatedAt;
  final int v;

  SkiPass({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.owner,
    required this.skiPassType,
    required this.services,
    required this.serviceArea,
    required this.amount,
    required this.description,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SkiPass.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return SkiPass(
      id: JsonHelper.getString(json['_id']),
      title: JsonHelper.getString(json['title']),
      thumbnail: JsonHelper.getString(json['thumbnail']),
      owner: JsonHelper.getString(json['owner']),
      skiPassType: JsonHelper.getString(json['skiPassType']),
      services: JsonHelper.getList(json['services'])
          .map((e) => ProductService.fromJson(JsonHelper.getMap(e)))
          .toList(),
      serviceArea: JsonHelper.getString(json['serviceArea']),
      amount: JsonHelper.getInt(json['amount']),
      description: JsonHelper.getString(json['description']),
      averageRating: JsonHelper.getDouble(json['averageRating']),
      reviews: JsonHelper.getList(json['reviews'])
          .map((e) => Review.fromJson(JsonHelper.getMap(e)))
          .toList(),
      refunds: JsonHelper.getList(json['refunds']),
      createdAt: JsonHelper.getString(json['createdAt']),
      updatedAt: JsonHelper.getString(json['updatedAt']),
      v: JsonHelper.getInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "thumbnail": thumbnail,
    "owner": owner,
    "skiPassType": skiPassType,
    "services": services.map((e) => e.toJson()).toList(),
    "serviceArea": serviceArea,
    "amount": amount,
    "description": description,
    "averageRating": averageRating,
    "reviews": reviews.map((e) => e.toJson()).toList(),
    "refunds": refunds,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class ProductService {
  final String title;
  final String description;

  ProductService({
    required this.title,
    required this.description,
  });

  factory ProductService.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return ProductService(
      title: JsonHelper.getString(json['title']),
      description: JsonHelper.getString(json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
  };
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final String createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Review(
      userId: JsonHelper.getString(json['userId']),
      rating: JsonHelper.getDouble(json['rating']),
      comment: JsonHelper.getString(json['comment']),
      createdAt: JsonHelper.getString(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt,
  };
}

