class ProviderHomeModel {
  final ProviderStats stats;
  final List<Booking> recentBookings; // unified Booking model
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
          .map((e) => Booking.fromJson(e))
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

/// Unified Booking model
class Booking {
  final String? id;
  final User? user;
  final Product? product;
  final String? productModel;
  final String? category;
  final DateTime? startDateAndTime;
  final DateTime? endDateAndTime;
  final DateTime? date;
  final String? time;
  final List<String>? slots;
  final String? duration;
  final String? bookingStatus;
  final double? totalPrice;
  final bool? isPermitted;
  final List<BookingItem> bookingItems;

  Booking({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.startDateAndTime,
    this.endDateAndTime,
    this.date,
    this.time,
    this.slots,
    this.duration,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    required this.bookingItems,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product:
      json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      startDateAndTime: json['startDateAndTime'] != null
          ? DateTime.parse(json['startDateAndTime'])
          : null,
      endDateAndTime: json['endDateAndTime'] != null
          ? DateTime.parse(json['endDateAndTime'])
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'],
      slots: json['slots'] != null ? List<String>.from(json['slots']) : null,
      duration: json['duration'],
      bookingStatus: json['bookingStatus'],
      totalPrice: (json['totalPrice'] != null)
          ? (json['totalPrice'] as num).toDouble()
          : null,
      isPermitted: json['isPermitted'],
      bookingItems: json['bookingItems'] != null
          ? List<BookingItem>.from(
          json['bookingItems'].map((x) => BookingItem.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user?.toJson(),
      "product": product?.toJson(),
      "productModel": productModel,
      "category": category,
      "startDateAndTime": startDateAndTime?.toIso8601String(),
      "endDateAndTime": endDateAndTime?.toIso8601String(),
      "date": date?.toIso8601String(),
      "time": time,
      "slots": slots,
      "duration": duration,
      "bookingStatus": bookingStatus,
      "totalPrice": totalPrice,
      "isPermitted": isPermitted,
      "bookingItems": bookingItems.map((e) => e.toJson()).toList(),
    };
  }
}

/// User model
class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  User({this.id, this.fullName, this.email, this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
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

/// Product model (updated with skiPassType and services)
class Product {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? serviceArea;
  final num? totalPrice;
  final num? extraChargePerHours;
  final String? skiPassType; // new field
  final List<ProductService>? services; // new field

  Product({
    this.id,
    this.title,
    this.thumbnail,
    this.serviceArea,
    this.totalPrice,
    this.extraChargePerHours,
    this.skiPassType,
    this.services,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      serviceArea: json['serviceArea'],
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice'] as num)
          : json['amount'] != null
          ? (json['amount'] as num)
          : 0,
      extraChargePerHours: json['extraChargePerHours'] != null
          ? num.tryParse(json['extraChargePerHours'].toString())
          : 0,
      skiPassType: json['skiPassType'], // parse new field
      services: json['services'] != null
          ? List<ProductService>.from(
          json['services'].map((x) => ProductService.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "thumbnail": thumbnail,
      "serviceArea": serviceArea,
      "totalPrice": totalPrice,
      "extraChargePerHours": extraChargePerHours,
      "skiPassType": skiPassType,
      "services": services?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Product service model
class ProductService {
  final String title;
  final String description;

  ProductService({required this.title, required this.description});

  factory ProductService.fromJson(Map<String, dynamic> json) {
    return ProductService(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
    };
  }
}

/// Booking item model
class BookingItem {
  final String itemId;
  final int quantity;

  BookingItem({required this.itemId, required this.quantity});

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json['itemId'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "quantity": quantity,
    };
  }
}

/// Recent Service model (updated with skiPassType and services)
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
  final String? skiPassType; // new field
  final List<ProductService>? services; // new field

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
    this.skiPassType,
    this.services,
  });

  factory RecentService.fromJson(Map<String, dynamic> json) {
    return RecentService(
      id: json["_id"] ?? "",
      category: json["category"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      owner: json["owner"] ?? "",
      extraChargePerHour: json["extraChargePerHour"] ?? 0,
      totalPrice: json["amount"] ?? json["totalPrice"] ?? 0,
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
      skiPassType: json['skiPassType'],
      services: json['services'] != null
          ? List<ProductService>.from(
          json['services'].map((x) => ProductService.fromJson(x)))
          : [],
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
      "skiPassType": skiPassType,
      "services": services?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Review model
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
