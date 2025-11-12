class SignupRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;

  SignupRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "role": role,
    };
  }
}
