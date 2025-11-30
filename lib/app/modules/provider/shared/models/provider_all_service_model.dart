class SkiPassResponse {
  final int code;
  final String message;
  final SkiPassData data;

  SkiPassResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SkiPassResponse.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return SkiPassResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: SkiPassData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class SkiPassData {
  final Pagination pagination;
  final List<SkiPass> result;

  SkiPassData({
    required this.pagination,
    required this.result,
  });

  factory SkiPassData.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return SkiPassData(
      pagination: Pagination.fromJson(json['pagination']),
      result: (json['result'] as List<dynamic>? ?? [])
          .map((e) => SkiPass.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "pagination": pagination.toJson(),
    "result": result.map((e) => e.toJson()).toList(),
  };
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
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
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      owner: json['owner'] ?? '',
      skiPassType: json['skiPassType'] ?? '',
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ProductService.fromJson(e as Map<String, dynamic>?))
          .toList(),
      serviceArea: json['serviceArea'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      averageRating: json['averageRating'] ?? 0,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>?))
          .toList(),
      refunds: json['refunds'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
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
      title: json['title'] ?? '',
      description: json['description'] ?? '',
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
      userId: json['userId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt,
  };
}
