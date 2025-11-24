class TransportDetailsModel {
  final String id;
  final Owner owner;
  final String thumbnail;
  final String title;
  final String personCount;
  final String milage;
  final String power;
  final String extraChargePerHours;
  final int insuranceFee;
  final int maintainCharge;
  final String serviceArea;
  final int amount;
  final String description;
  final double averageRating;
  final List<dynamic> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;

  TransportDetailsModel({
    required this.id,
    required this.owner,
    required this.thumbnail,
    required this.title,
    required this.personCount,
    required this.milage,
    required this.power,
    required this.extraChargePerHours,
    required this.insuranceFee,
    required this.maintainCharge,
    required this.serviceArea,
    required this.amount,
    required this.description,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory TransportDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransportDetailsModel(
      id: json["_id"]?.toString() ?? "",
      owner: json["owner"] != null
          ? Owner.fromJson(json["owner"])
          : Owner.empty(),
      thumbnail: json["thumbnail"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      personCount: json["personCount"]?.toString() ?? "0",
      milage: json["milage"]?.toString() ?? "0",
      power: json["power"]?.toString() ?? "0",
      extraChargePerHours: json["extraChargePerHours"]?.toString() ?? "0",
      insuranceFee: _asInt(json["insuranceFee"]),
      maintainCharge: _asInt(json["maintainCharge"]),
      serviceArea: json["serviceArea"]?.toString() ?? "",
      amount: _asInt(json["amount"]),
      description: json["description"]?.toString() ?? "",
      averageRating: _asDouble(json["averageRating"]),
      reviews: json["reviews"] is List ? json["reviews"] : [],
      refunds: json["refunds"] is List ? json["refunds"] : [],
      createdAt: _parseDate(json["createdAt"]),
      updatedAt: _parseDate(json["updatedAt"]),
      category: json["category"] != null
          ? Category.fromJson(json["category"])
          : Category.empty(),
    );
  }

  /// SAFETY HELPERS
  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(2000); // fallback
    return DateTime.tryParse(value.toString()) ?? DateTime(2000);
  }
}

class Owner {
  final String fullName;
  final String profileUrl;
  final String address;
  final String id;
  final String email;
  final String providerType;
  final String status;
  final String role;
  final bool isAgreedTermsCondition;
  final bool isAgreedTermsConditions;
  final bool isResetPassword;

  Owner({
    required this.fullName,
    required this.profileUrl,
    required this.address,
    required this.id,
    required this.email,
    required this.providerType,
    required this.status,
    required this.role,
    required this.isAgreedTermsCondition,
    required this.isAgreedTermsConditions,
    required this.isResetPassword,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      fullName: json["fullName"]?.toString() ?? "",
      profileUrl: json["profileUrl"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      id: json["_id"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      providerType: json["providerType"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      role: json["role"]?.toString() ?? "",
      isAgreedTermsCondition: json["isAgreedTermsCondition"] == true,
      isAgreedTermsConditions: json["isAgreedTermsConditions"] == true,
      isResetPassword: json["isResetPassword"] == true,
    );
  }

  factory Owner.empty() {
    return Owner(
      fullName: "",
      profileUrl: "",
      address: "",
      id: "",
      email: "",
      providerType: "",
      status: "",
      role: "",
      isAgreedTermsCondition: false,
      isAgreedTermsConditions: false,
      isResetPassword: false,
    );
  }
}

class Category {
  final String name;
  final String categoryPhoto;
  final String id;

  Category({
    required this.name,
    required this.categoryPhoto,
    required this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"]?.toString() ?? "",
      categoryPhoto: json["categoryPhoto"]?.toString() ?? "",
      id: json["_id"]?.toString() ?? "",
    );
  }

  factory Category.empty() {
    return Category(
      name: "",
      categoryPhoto: "",
      id: "",
    );
  }
}
