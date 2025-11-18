class PassBookingRequestModel {
  final String userId;
  final String productId;
  final int personCount;
  final String date;
  final String time;

  PassBookingRequestModel({
    required this.userId,
    required this.productId,
    required this.personCount,
    required this.date,
    required this.time,
  });

  /// Convert a JSON map to a PassBookingRequestModel object
  factory PassBookingRequestModel.fromJson(Map<String, dynamic> json) {
    return PassBookingRequestModel(
      userId: json['userId'],
      productId: json['productId'],
      personCount: json['personCount'],
      date: json['date'],
      time: json['time'],
    );
  }

  /// Convert a PassBookingRequestModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'personCount': personCount,
      'date': date,
      'time': time,
    };
  }
}
