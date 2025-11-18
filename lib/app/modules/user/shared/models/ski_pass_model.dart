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
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      skiPassType: json["skiPassType"] ?? "",
      services: (json["services"] as List<dynamic>)
          .map((e) => ServiceItem.fromJson(e))
          .toList(),
      serviceArea: json["serviceArea"] ?? "",
      amount: json["amount"] ?? 0,
      description: json["description"] ?? "",
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      reviews: (json["reviews"] as List<dynamic>)
          .map((e) => ReviewItem.fromJson(e))
          .toList(),
    );
  }
}

class ServiceItem {
  final String title;
  final String description;

  ServiceItem({required this.title, required this.description});

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
    );
  }
}

class ReviewItem {
  final String? userId;
  final double rating;
  final String comment;
  final String? createdAt;

  ReviewItem({
    this.userId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      userId: json["userId"],
      rating: (json["rating"] ?? 0).toDouble(),
      comment: json["comment"] ?? "",
      createdAt: json["createdAt"],
    );
  }
}
