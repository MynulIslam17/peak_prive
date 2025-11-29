class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String profilePic;
  final String ? providerType;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.profilePic,
     this.providerType
  });

  /// Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "N/A",
      email: json["email"] ?? "N/A",
      role: json["role"] ?? "N/A",
      phone: json["phoneNumber"] ?? "N/A",
      address: json["address"] ?? "N/A",
    //  profilePic: json["profileUrl"] ??"assets/images/profile_img.jpg"
      profilePic: json["profileUrl"] ?? "",
      providerType: json["providerType"]
    );
  }

  /// Convert the UserModel back to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "email": email,
      "role": role,
      "phoneNumber": phone,
      "address": address,
      "profileUrl" : profilePic,
      // Only include providerType if not null
      if (providerType != null)...{
        "providerType": providerType
      },
      // Only send providerType if it exists
    };
  }
}
