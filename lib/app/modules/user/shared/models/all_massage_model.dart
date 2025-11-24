
class MassageModel {
  final int code;
  final String message;
  final MassageData data;

  MassageModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MassageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MassageModel(
        code: 0,
        message: "",
        data: MassageData.empty(),
      );
    }

    return MassageModel(
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: MassageData.fromJson(json["data"]),
    );
  }
}

class MassageData {
  final Pagination pagination;
  final List<Massage> result;

  MassageData({
    required this.pagination,
    required this.result,
  });

  factory MassageData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MassageData.empty();

    return MassageData(
      pagination: Pagination.fromJson(json["pagination"]),
      result: (json["result"] as List? ?? [])
          .map((e) => Massage.fromJson(e))
          .toList(),
    );
  }

  factory MassageData.empty() {
    return MassageData(
      pagination: Pagination.empty(),
      result: [],
    );
  }
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
    if (json == null) return Pagination.empty();

    return Pagination(
      total: json["total"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 10,
      totalPages: json["totalPages"] ?? 1,
    );
  }

  factory Pagination.empty() {
    return Pagination(total: 0, page: 1, limit: 10, totalPages: 1);
  }
}

class Massage {
  final String id;
  final Category category;
  final Owner owner;
  final String thumbnail;
  final String title;
  final String openTime;
  final String closeTime;
  final List<PriceByDuration> priceByDuration;
  final String serviceArea;
  final num amount;
  final String benefits;
  final String ourRecommendations;
  final num averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Massage({
    required this.id,
    required this.category,
    required this.owner,
    required this.thumbnail,
    required this.title,
    required this.openTime,
    required this.closeTime,
    required this.priceByDuration,
    required this.serviceArea,
    required this.amount,
    required this.benefits,
    required this.ourRecommendations,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Massage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Massage.empty();

    return Massage(
      id: json["_id"] ?? "",
      category: Category.fromJson(json["category"]),
      owner: Owner.fromJson(json["owner"]),
      thumbnail: json["thumbnail"] ?? "",
      title: json["title"] ?? "",
      openTime: json["openTime"] ?? "",
      closeTime: json["closeTime"] ?? "",
      priceByDuration: (json["priceByDuration"] as List? ?? [])
          .map((e) => PriceByDuration.fromJson(e))
          .toList(),
      serviceArea: json["serviceArea"] ?? "",
      amount: json["amount"] ?? 0,
      benefits: json["benefits"] ?? "",
      ourRecommendations: json["ourRecommendations"] ?? "",
      averageRating: json["averageRating"] ?? 0,
      reviews: (json["reviews"] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      refunds: json["refunds"] ?? [],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory Massage.empty() {
    return Massage(
      id: "",
      category: Category.empty(),
      owner: Owner.empty(),
      thumbnail: "",
      title: "",
      openTime: "",
      closeTime: "",
      priceByDuration: [],
      serviceArea: "",
      amount: 0,
      benefits: "",
      ourRecommendations: "",
      averageRating: 0,
      reviews: [],
      refunds: [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String categoryPhoto;

  Category({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory Category.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Category.empty();

    return Category(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      categoryPhoto: json["categoryPhoto"] ?? "",
    );
  }

  factory Category.empty() {
    return Category(id: "", name: "", categoryPhoto: "");
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

  Owner({
    required this.id,
    required this.fullName,
    required this.profileUrl,
    required this.address,
    required this.email,
    required this.providerType,
    required this.status,
    required this.role,
  });

  factory Owner.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Owner.empty();

    return Owner(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "",
      profileUrl: json["profileUrl"] ?? "",
      address: json["address"] ?? "",
      email: json["email"] ?? "",
      providerType: json["providerType"] ?? "",
      status: json["status"] ?? "",
      role: json["role"] ?? "",
    );
  }

  factory Owner.empty() {
    return Owner(
      id: "",
      fullName: "",
      profileUrl: "",
      address: "",
      email: "",
      providerType: "",
      status: "",
      role: "",
    );
  }
}

class PriceByDuration {
  final String id;
  final String duration;
  final num amount;

  PriceByDuration({
    required this.id,
    required this.duration,
    required this.amount,
  });

  factory PriceByDuration.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PriceByDuration.empty();

    return PriceByDuration(
      id: json["_id"] ?? "",
      duration: json["duration"] ?? "",
      amount: json["amount"] ?? 0,
    );
  }

  factory PriceByDuration.empty() {
    return PriceByDuration(id: "", duration: "", amount: 0);
  }
}

class Review {
  final String userId;
  final num rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Review.empty();

    return Review(
      userId: json["userId"] ?? "",
      rating: json["rating"] ?? 0,
      comment: json["comment"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory Review.empty() {
    return Review(
      userId: "",
      rating: 0,
      comment: "",
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
