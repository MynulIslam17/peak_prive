class SkiPass {
  final String id;
  final String title;
  final String thumbnail;
  final String skiPassType;
  final List<ServiceItem> services;
  final String serviceArea;
  final int amount;
  final String description;
  final double averageRating;
  final List<ReviewItem> reviews;

  SkiPass({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.skiPassType,
    required this.services,
    required this.serviceArea,
    required this.amount,
    required this.description,
    required this.averageRating,
    required this.reviews,
  });

  factory SkiPass.fromJson(Map<String, dynamic> json) {
    return SkiPass(
      id: json["_id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      thumbnail: json["thumbnail"]?.toString() ?? "",
      skiPassType: json["skiPassType"]?.toString() ?? "",
      services: (json["services"] as List<dynamic>?)
          ?.map((e) => ServiceItem.fromJson(e))
          .toList() ??
          [],
      serviceArea: json["serviceArea"]?.toString() ?? "",
      amount: (json["amount"] ?? 0) is int
          ? json["amount"]
          : int.tryParse(json["amount"].toString()) ?? 0,
      description: json["description"]?.toString() ?? "",
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      reviews: (json["reviews"] as List<dynamic>?)
          ?.map((e) => ReviewItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ServiceItem {
  final String title;
  final String description;

  ServiceItem({required this.title, required this.description});

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
    );
  }
}

class ReviewItem {
  final String userId;
  final double rating;
  final String comment;
  final String createdAt;

  ReviewItem({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      userId: json["userId"]?.toString() ?? "",
      rating: (json["rating"] ?? 0).toDouble(),
      comment: json["comment"]?.toString() ?? "",
      createdAt: json["createdAt"]?.toString() ?? "",
    );
  }
}
