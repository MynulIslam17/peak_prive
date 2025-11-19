class PassDetails {
  final String id;
  final String title;
  final String thumbnail;
  final Owner owner;
  final String skiPassType;
  final List<Service> services;
  final String serviceArea;
  final double amount;
  final String description;
  final double averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;

  PassDetails({
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
  });

  factory PassDetails.fromJson(Map<String, dynamic> json) {
    // Safe parsing for services
    List<Service> services = [];
    if (json['services'] != null && json['services'] is List) {
      services = (json['services'] as List)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Safe parsing for reviews
    List<Review> reviews = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = (json['reviews'] as List)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PassDetails(
      id: json['_id']?.toString() ?? "",
      title: json['title']?.toString() ?? "",
      thumbnail: json['thumbnail']?.toString() ?? "",
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : Owner(id: "", email: "", phoneNumber: "", profileUrl: ""),
      skiPassType: json['skiPassType']?.toString() ?? "",
      services: services,
      serviceArea: json['serviceArea']?.toString() ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? "",
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviews: reviews,
      refunds: json['refunds'] ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class Service {
  final String title;
  final String description;

  Service({required this.title, required this.description});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
    );
  }
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String parsedUserId = "";
    if (json['userId'] != null) {
      if (json['userId'] is String) {
        parsedUserId = json['userId'];
      } else if (json['userId'] is Map && json['userId']['_id'] != null) {
        parsedUserId = json['userId']['_id'].toString();
      }
    }

    return Review(
      userId: parsedUserId,
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment']?.toString() ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class Owner {
  final String id;
  final String email;
  final String phoneNumber;
  final String profileUrl;

  Owner({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.profileUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      phoneNumber: json['phoneNumber']?.toString() ?? "",
      profileUrl: json['profileUrl']?.toString() ?? "",
    );
  }
}
