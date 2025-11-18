class Service {
  final String title;
  final String description;

  Service({
    required this.title,
    required this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'],
      description: json['description'],
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
    return Review(
      userId: json['userId'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
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
      id: json['_id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileUrl: json['profileUrl'],
    );
  }
}

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
  final List<dynamic> refunds; // Refunds structure is not provided, so we use dynamic
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
    var servicesList = json['services'] as List;
    List<Service> services = servicesList.map((i) => Service.fromJson(i)).toList();

    var reviewsList = json['reviews'] as List;
    List<Review> reviews = reviewsList.map((i) => Review.fromJson(i)).toList();

    return PassDetails(
      id: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      owner: Owner.fromJson(json['owner']),
      skiPassType: json['skiPassType'],
      services: services,
      serviceArea: json['serviceArea'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      averageRating: json['averageRating'].toDouble(),
      reviews: reviews,
      refunds: json['refunds'], // Keeping refunds dynamic as no specific structure is provided
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
