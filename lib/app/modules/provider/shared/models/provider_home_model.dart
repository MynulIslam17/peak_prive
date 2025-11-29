class ProviderHomeModel {
  final ProviderStats stats;
  final List<RecentBooking> recentBookings;
  final List<RecentService> recentServices;

  ProviderHomeModel({
    required this.stats,
    required this.recentBookings,
    required this.recentServices,
  });

  factory ProviderHomeModel.fromJson(Map<String, dynamic> json) {
    return ProviderHomeModel(
      stats: ProviderStats.fromJson(json["stats"] ?? {}),
      recentBookings: (json["recentBookings"] as List? ?? [])
          .map((e) => RecentBooking.fromJson(e))
          .toList(),
      recentServices: (json["recentServices"] as List? ?? [])
          .map((e) => RecentService.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "stats": stats.toJson(),
      "recentBookings": recentBookings.map((e) => e.toJson()).toList(),
      "recentServices": recentServices.map((e) => e.toJson()).toList(),
    };
  }
}

class ProviderStats {
  final int todayBookingCount;
  final int totalBooking;
  final num totalBalance;

  ProviderStats({
    required this.todayBookingCount,
    required this.totalBooking,
    required this.totalBalance,
  });

  factory ProviderStats.fromJson(Map<String, dynamic> json) {
    return ProviderStats(
      todayBookingCount: json["todayBookingCount"] ?? 0,
      totalBooking: json["totalBooking"] ?? 0,
      totalBalance: json["totalBalance"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "todayBookingCount": todayBookingCount,
      "totalBooking": totalBooking,
      "totalBalance": totalBalance,
    };
  }
}

class RecentBooking {
  final String id;
  final BookingUser user;
  final BookingProduct product;
  final String productModel;
  final String category;
  final String startDateAndTime;
  final String endDateAndTime;
  final List<BookingItem> bookingItems;
  final List<dynamic> slots;
  final String bookingStatus;
  final num totalPrice;
  final String phoneNumber;
  final String address;
  final bool isPermitted;
  final String createdAt;
  final String updatedAt;

  RecentBooking({
    required this.id,
    required this.user,
    required this.product,
    required this.productModel,
    required this.category,
    required this.startDateAndTime,
    required this.endDateAndTime,
    required this.bookingItems,
    required this.slots,
    required this.bookingStatus,
    required this.totalPrice,
    required this.phoneNumber,
    required this.address,
    required this.isPermitted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      id: json["_id"] ?? "",
      user: BookingUser.fromJson(json["user"] ?? {}),
      product: BookingProduct.fromJson(json["product"] ?? {}),
      productModel: json["productModel"] ?? "",
      category: json["category"] ?? "",
      startDateAndTime: json["startDateAndTime"] ?? "",
      endDateAndTime: json["endDateAndTime"] ?? "",
      bookingItems: (json["bookingItems"] as List? ?? [])
          .map((e) => BookingItem.fromJson(e))
          .toList(),
      slots: json["slots"] ?? [],
      bookingStatus: json["bookingStatus"] ?? "",
      totalPrice: json["totalPrice"] ?? 0,
      phoneNumber: json["phoneNumber"] ?? "",
      address: json["address"] ?? "",
      isPermitted: json["isPermitted"] ?? false,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user.toJson(),
      "product": product.toJson(),
      "productModel": productModel,
      "category": category,
      "startDateAndTime": startDateAndTime,
      "endDateAndTime": endDateAndTime,
      "bookingItems": bookingItems.map((e) => e.toJson()).toList(),
      "slots": slots,
      "bookingStatus": bookingStatus,
      "totalPrice": totalPrice,
      "phoneNumber": phoneNumber,
      "address": address,
      "isPermitted": isPermitted,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class BookingUser {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;

  BookingUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "N/A",
      email: json["email"] ?? "N/A",
      phoneNumber: json["phoneNumber"] ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
    };
  }
}

class BookingProduct {
  final String id;
  final String category;
  final String title;
  final String thumbnail;
  final String owner;
  final num extraChargePerHour;
  final num totalPrice;
  final String serviceArea;
  final num averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final String createdAt;
  final String updatedAt;

  BookingProduct({
    required this.id,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.owner,
    required this.extraChargePerHour,
    required this.totalPrice,
    required this.serviceArea,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingProduct.fromJson(Map<String, dynamic> json) {
    return BookingProduct(
      id: json["_id"] ?? "",
      category: json["category"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      owner: json["owner"] ?? "",
      extraChargePerHour: json["extraChargePerHour"] ?? 0,
      totalPrice: json["totalPrice"] ?? 0,
      serviceArea: json["serviceArea"] ?? "",
      averageRating: json["averageRating"] ?? 0,
      reviews: (json["reviews"] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      refunds: json["refunds"] ?? [],
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "category": category,
      "title": title,
      "thumbnail": thumbnail,
      "owner": owner,
      "extraChargePerHour": extraChargePerHour,
      "totalPrice": totalPrice,
      "serviceArea": serviceArea,
      "averageRating": averageRating,
      "reviews": reviews.map((e) => e.toJson()).toList(),
      "refunds": refunds,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final String createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json["userId"] ?? "",
      rating: (json["rating"] ?? 0).toDouble(),
      comment: json["comment"] ?? "",
      createdAt: json["createdAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "rating": rating,
      "comment": comment,
      "createdAt": createdAt,
    };
  }
}

// BookingItem remains same
class BookingItem {
  final String itemId;
  final int quantity;

  BookingItem({
    required this.itemId,
    required this.quantity,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json["itemId"] ?? "",
      quantity: json["quantity"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "quantity": quantity,
    };
  }
}

// RecentService remains same as before
class RecentService {
  final String id;
  final String category;
  final String title;
  final String thumbnail;
  final String owner;
  final num extraChargePerHour;
  final num totalPrice;
  final String serviceArea;
  final num averageRating;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String model;

  RecentService({
    required this.id,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.owner,
    required this.extraChargePerHour,
    required this.totalPrice,
    required this.serviceArea,
    required this.averageRating,
    required this.reviews,
    required this.refunds,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.model,
  });

  factory RecentService.fromJson(Map<String, dynamic> json) {
    return RecentService(
      id: json["_id"] ?? "",
      category: json["category"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      owner: json["owner"] ?? "",
      extraChargePerHour: json["extraChargePerHour"] ?? 0,
      totalPrice: json["totalPrice"] ?? 0,
      serviceArea: json["serviceArea"] ?? "",
      averageRating: json["averageRating"] ?? 0,
      reviews: (json["reviews"] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      refunds: json["refunds"] ?? [],
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
      model: json["model"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "category": category,
      "title": title,
      "thumbnail": thumbnail,
      "owner": owner,
      "extraChargePerHour": extraChargePerHour,
      "totalPrice": totalPrice,
      "serviceArea": serviceArea,
      "averageRating": averageRating,
      "reviews": reviews.map((e) => e.toJson()).toList(),
      "refunds": refunds,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "model": model,
    };
  }
}
