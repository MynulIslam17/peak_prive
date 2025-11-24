class TransportDetailsModel {
  final String? id;
  final Owner? owner;
  final String? thumbnail;
  final String? title;
  final String? personCount;
  final String? milage;
  final String? power;
  final String? extraChargePerHours;
  final int? insuranceFee;
  final int? maintainCharge;
  final String? serviceArea;
  final int? amount;
  final String? description;
  final double? averageRating;
  final List<dynamic>? reviews;
  final List<dynamic>? refunds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;

  TransportDetailsModel({
    this.id,
    this.owner,
    this.thumbnail,
    this.title,
    this.personCount,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.serviceArea,
    this.amount,
    this.description,
    this.averageRating,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory TransportDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransportDetailsModel(
      id: json["_id"],
      owner: json["owner"] != null ? Owner.fromJson(json["owner"]) : null,
      thumbnail: json["thumbnail"],
      title: json["title"],
      personCount: json["personCount"],
      milage: json["milage"],
      power: json["power"],
      extraChargePerHours: json["extraChargePerHours"],
      insuranceFee: json["insuranceFee"],
      maintainCharge: json["maintainCharge"],
      serviceArea: json["serviceArea"],
      amount: json["amount"],
      description: json["description"],
      averageRating: (json["averageRating"] as num?)?.toDouble(),
      reviews: json["reviews"] ?? [],
      refunds: json["refunds"] ?? [],
      createdAt:
      json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
      json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      category:
      json["category"] != null ? Category.fromJson(json["category"]) : null,
    );
  }
}

class Owner {
  final String? fullName;
  final String? profileUrl;
  final String? address;
  final String? id;
  final String? email;
  final String? providerType;
  final String? status;
  final String? role;
  final bool? isAgreedTermsCondition;
  final bool? isAgreedTermsConditions;
  final bool? isResetPassword;

  Owner({
    this.fullName,
    this.profileUrl,
    this.address,
    this.id,
    this.email,
    this.providerType,
    this.status,
    this.role,
    this.isAgreedTermsCondition,
    this.isAgreedTermsConditions,
    this.isResetPassword,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      fullName: json["fullName"],
      profileUrl: json["profileUrl"],
      address: json["address"],
      id: json["_id"],
      email: json["email"],
      providerType: json["providerType"],
      status: json["status"],
      role: json["role"],
      isAgreedTermsCondition: json["isAgreedTermsCondition"],
      isAgreedTermsConditions: json["isAgreedTermsConditions"],
      isResetPassword: json["isResetPassword"],
    );
  }
}

class Category {
  final String? name;
  final String? categoryPhoto;
  final String? id;

  Category({
    this.name,
    this.categoryPhoto,
    this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"],
      categoryPhoto: json["categoryPhoto"],
      id: json["_id"],
    );
  }
}
