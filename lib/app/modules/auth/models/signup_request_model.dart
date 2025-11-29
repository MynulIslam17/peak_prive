class SignupRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final String? providerType; // Optional field
  final String? phoneNumber; // Optional field

  SignupRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.providerType, // optional, can be null
    this.phoneNumber, // optional, can be null
  });

  Map<String, dynamic> toJson() {
    final data = {
      "fullName": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "role": role,
    };

    // Add providerType only if it's not null
    if (providerType != null) {
      data["providerType"] = providerType!;
      data["phoneNumber"] = phoneNumber!;
    }

    return data;
  }
}
