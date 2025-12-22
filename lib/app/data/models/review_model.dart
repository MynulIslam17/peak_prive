class Review {
  final String userId;
  final User user;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] is Map ? json['userId']['_id'] ?? '' : json['userId'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      rating: (json['rating']?.toDouble() ?? 0.0),
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String? profileUrl;

  User({required this.id, required this.fullName, this.profileUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profileUrl: json['profileUrl'],
    );
  }
}
