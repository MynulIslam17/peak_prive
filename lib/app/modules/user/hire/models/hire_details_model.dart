class HireDetailsModel {
  final String id;
  final Category category;
  final String title;
  final String thumbnail;
  final Owner owner;
  final int extraChargePerHour;
  final int totalPrice;
  final String serviceArea;
  final List<HireItem> items;
  final double averageRating;
  final List<dynamic> reviews;
  final List<dynamic> refunds;
  final DateTime createdAt;
  final DateTime updatedAt;

  HireDetailsModel({
    required this.id,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.owner,
    required this.extraChargePerHour,
    required this.totalPrice,
    required this.serviceArea,
    required this.items,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HireDetailsModel.fromJson(Map<String, dynamic> json) {
    return HireDetailsModel(
      id: json['_id'],
      category: Category.fromJson(json['category']),
      title: json['title'],
      thumbnail: json['thumbnail'],
      owner: Owner.fromJson(json['owner']),
      extraChargePerHour: json['extraChargePerHour'],
      totalPrice: json['totalPrice'],
      serviceArea: json['serviceArea'],
      items: (json['items'] as List).map((e) => HireItem.fromJson(e)).toList(),
      averageRating: (json['averageRating']?.toDouble() ?? 0.0),
      reviews: json['reviews'] ?? [],
      refunds: json['refunds'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String categoryPhoto;

  Category({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      categoryPhoto: json['categoryPhoto'],
    );
  }
}

class Owner {
  final String id;
  final String email;
  final String profileUrl;
  final String providerType;
  final String status;
  final String role;

  Owner({
    required this.id,
    required this.email,
    required this.profileUrl,
    required this.providerType,
    required this.status,
    required this.role,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'],
      email: json['email'],
      profileUrl: json['profileUrl'],
      providerType: json['providerType'],
      status: json['status'],
      role: json['role'],
    );
  }
}

class HireItem {
  final String id;
  final String productName;
  final String productPhoto;
  final int price;
  final int totalQty;
  final int availableQty;

  HireItem({
    required this.id,
    required this.productName,
    required this.productPhoto,
    required this.price,
    required this.totalQty,
    required this.availableQty,
  });

  factory HireItem.fromJson(Map<String, dynamic> json) {
    return HireItem(
      id: json['_id'],
      productName: json['productName'],
      productPhoto: json['productPhoto'],
      price: json['price'],
      totalQty: json['totalQty'],
      availableQty: json['availableQty'],
    );
  }
}
