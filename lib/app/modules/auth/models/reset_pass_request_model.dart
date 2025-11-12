class ResetPassRequestModel {
  final String email;
  final String newPassword;

  ResetPassRequestModel({required this.email, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {"email": email, "newPassword": newPassword};
  }
}
