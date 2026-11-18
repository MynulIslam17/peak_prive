class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String profilePic;
  final String? providerType;
  String? token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.profilePic,
    this.providerType,
    this.token,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "N/A",
      email: json["email"] ?? "N/A",
      role: json["role"] ?? "N/A",
      phone: json["phoneNumber"] ?? "N/A",
      address: json["address"] ?? "N/A",
      profilePic: json["profileUrl"] ?? "",
      providerType: json["providerType"],
      token: json["token"], // optional, might be null
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "email": email,
      "role": role,
      "phoneNumber": phone,
      "address": address,
      "profileUrl": profilePic,
      if (providerType != null) "providerType": providerType,
      if (token != null) "token": token,
    };
  }
}
