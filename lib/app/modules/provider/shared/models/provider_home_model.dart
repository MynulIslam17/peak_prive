import 'package:harry_service_app/app/modules/provider/shared/models/provider_home_model.dart' as home;
import 'package:harry_service_app/app/modules/provider/shared/models/provider_pass_service_model.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_pass_service_model.dart' as pass;

class ProviderHomeModel {
  final ProviderStats stats;
  final List<Booking> recentBookings;
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
  final List<Slot> slots;
  final String? duration;
  final String? bookingStatus;
  final double? totalPrice;
  final bool? isPermitted;
  final List<BookingItem> bookingItems;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

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
    this.slots = const [],
    this.duration,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    required this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'] ?? '',
      category: json['category'] ?? '',
      startDateAndTime: json['startDateAndTime'] != null
          ? DateTime.tryParse(json['startDateAndTime'])
          : null,
      endDateAndTime: json['endDateAndTime'] != null
          ? DateTime.tryParse(json['endDateAndTime'])
          : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: json['time'] ?? '',
      slots: (json['slots'] as List? ?? [])
          .map((e) => Slot.fromJson(e))
          .toList(),
      duration: json['duration'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      totalPrice: (json['totalPrice'] != null)
          ? (json['totalPrice'] as num).toDouble()
          : 0,
      isPermitted: json['isPermitted'] ?? false,
      bookingItems: (json['bookingItems'] != null)
          ? List<BookingItem>.from(
          json['bookingItems'].map((x) => BookingItem.fromJson(x)))
          : [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
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
      "slots": slots.map((e) => e.toJson()).toList(),
      "duration": duration,
      "bookingStatus": bookingStatus,
      "totalPrice": totalPrice,
      "isPermitted": isPermitted,
      "bookingItems": bookingItems.map((e) => e.toJson()).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
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

/// Product model
class Product {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? serviceArea;
  final num? totalPrice;
  final num? extraChargePerHours;
  final String? skiPassType;
  final List<ProductService>? services;

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
  final ItemDetails? itemDetails;

  BookingItem({
    required this.itemId,
    required this.quantity,
    this.itemDetails,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json['itemId'] ?? '',
      quantity: json['quantity'] ?? 1,
      itemDetails: json['itemDetails'] != null
          ? ItemDetails.fromJson(json['itemDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "quantity": quantity,
      "itemDetails": itemDetails?.toJson(),
    };
  }
}

/// Item details model
class ItemDetails {
  final String? seat;
  final String? photo;
  final int? totalQty;
  final int? availableQty;
  final num? price;
  final String? description;
  final String? id;

  ItemDetails({
    this.seat,
    this.photo,
    this.totalQty,
    this.availableQty,
    this.price,
    this.description,
    this.id,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    return ItemDetails(
      seat: json['seat'],
      photo: json['photo'],
      totalQty: json['totalQty'],
      availableQty: json['availableQty'],
      price: json['price'],
      description: json['description'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "seat": seat,
      "photo": photo,
      "totalQty": totalQty,
      "availableQty": availableQty,
      "price": price,
      "description": description,
      "_id": id,
    };
  }
}

/// Slot model
class Slot {
  final String? id;
  final String? startTime;
  final String? endTime;

  Slot({
    this.id,
    this.startTime,
    this.endTime,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['_id'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "startTime": startTime,
    "endTime": endTime,
  };
}

/// Category model (NEW - for recentServices)
class ServiceCategory {
  final String id;
  final String name;
  final String categoryPhoto;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      categoryPhoto: json['categoryPhoto'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "categoryPhoto": categoryPhoto,
    };
  }
}

/// Updated ServiceItem for recentServices items
class ServiceItem {
  final String? id;
  final String? seat;
  final String? photo;
  final int? totalQty;
  final int? availableQty;
  final num? price;
  final String? description;

  // Fields from your JSON
  final String? productName;
  final String? productPhoto;

  ServiceItem({
    this.id,
    this.seat,
    this.photo,
    this.totalQty,
    this.availableQty,
    this.price,
    this.description,
    this.productName,
    this.productPhoto,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json["_id"] ?? '',
      seat: json["seat"],
      photo: json["photo"],
      totalQty: json["totalQty"],
      availableQty: json["availableQty"],
      price: json["price"],
      description: json["description"],
      productName: json["productName"] ?? '',
      productPhoto: json["productPhoto"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "seat": seat,
      "photo": photo,
      "totalQty": totalQty,
      "availableQty": availableQty,
      "price": price,
      "description": description,
      "productName": productName,
      "productPhoto": productPhoto,
    };
  }
}

/// Service Item model (NEW - for recentServices items)
// class ServiceItem {
//   final String? id;
//   final String? seat;
//   final String? photo;
//   final int? totalQty;
//   final int? availableQty;
//   final num? price;
//   final String? description;
//
//   ServiceItem({
//     this.id,
//     this.seat,
//     this.photo,
//     this.totalQty,
//     this.availableQty,
//     this.price,
//     this.description,
//   });
//
//   factory ServiceItem.fromJson(Map<String, dynamic> json) {
//     return ServiceItem(
//       id: json['_id'] ?? '',
//       seat: json['seat'],
//       photo: json['photo'],
//       totalQty: json['totalQty'],
//       availableQty: json['availableQty'],
//       price: json['price'],
//       description: json['description'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "seat": seat,
//       "photo": photo,
//       "totalQty": totalQty,
//       "availableQty": availableQty,
//       "price": price,
//       "description": description,
//     };
//   }
// }

/// Recent Service model - UPDATED with all missing fields
// class RecentService {
//   final String id;
//   final String title;
//   final String thumbnail;
//   final ServiceCategory? category;
//   final String owner;
//   final String openTime;
//   final String closeTime;
//   final String serviceArea;
//   final num serviceFee;
//   final String foodType;
//   final String status;
//   final List<ServiceItem> items;
//   final List<Slot> slots;
//   final num averageRating;
//   final List<Slot> availableSlots;
//   final List<Review> reviews;
//   final List<dynamic> refunds;
//   final String createdAt;
//   final String updatedAt;
//   final String model;
//   final int reviewCount;
//   final String? skiPassType;
//   final List<ProductService>? services;
//   final int? v;
//
//   RecentService({
//     required this.id,
//     required this.title,
//     required this.thumbnail,
//     this.category,
//     required this.owner,
//     required this.openTime,
//     required this.closeTime,
//     required this.serviceArea,
//     this.serviceFee = 0,
//     required this.foodType,
//     required this.status,
//     this.items = const [],
//     this.slots = const [],
//     this.averageRating = 0,
//     this.availableSlots = const [],
//     this.reviews = const [],
//     this.refunds = const [],
//     required this.createdAt,
//     required this.updatedAt,
//     required this.model,
//     this.reviewCount = 0,
//     this.skiPassType,
//     this.services,
//     this.v,
//   });
//
//   factory RecentService.fromJson(Map<String, dynamic> json) {
//     return RecentService(
//       id: json["_id"] ?? '',
//       title: json["title"] ?? '',
//       thumbnail: json["thumbnail"] ?? '',
//       category: json["category"] != null
//           ? ServiceCategory.fromJson(json["category"])
//           : null,
//       owner: json["owner"] ?? '',
//       openTime: json["openTime"] ?? '',
//       closeTime: json["closeTime"] ?? '',
//       serviceArea: json["serviceArea"] ?? '',
//       serviceFee: json["serviceFee"] ?? 0,
//       foodType: json["foodType"] ?? '',
//       status: json["status"] ?? '',
//       items: (json["items"] as List? ?? [])
//           .map((e) => ServiceItem.fromJson(e))
//           .toList(),
//       slots: (json["slots"] as List? ?? [])
//           .map((e) => Slot.fromJson(e))
//           .toList(),
//       averageRating: json["averageRating"] ?? 0,
//       availableSlots: (json["availableSlots"] as List? ?? [])
//           .map((e) => Slot.fromJson(e))
//           .toList(),
//       reviews: (json["reviews"] as List? ?? [])
//           .map((e) => Review.fromJson(e))
//           .toList(),
//       refunds: json["refunds"] ?? [],
//       createdAt: json["createdAt"] ?? '',
//       updatedAt: json["updatedAt"] ?? '',
//       model: json["model"] ?? '',
//       reviewCount: json["reviewCount"] ?? 0,
//       skiPassType: json['skiPassType'],
//       services: json['services'] != null
//           ? List<ProductService>.from(
//           json['services'].map((x) => ProductService.fromJson(x)))
//           : [],
//       v: json["__v"],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "title": title,
//       "thumbnail": thumbnail,
//       "category": category?.toJson(),
//       "owner": owner,
//       "openTime": openTime,
//       "closeTime": closeTime,
//       "serviceArea": serviceArea,
//       "serviceFee": serviceFee,
//       "foodType": foodType,
//       "status": status,
//       "items": items.map((e) => e.toJson()).toList(),
//       "slots": slots.map((e) => e.toJson()).toList(),
//       "averageRating": averageRating,
//       "availableSlots": availableSlots.map((e) => e.toJson()).toList(),
//       "reviews": reviews.map((e) => e.toJson()).toList(),
//       "refunds": refunds,
//       "createdAt": createdAt,
//       "updatedAt": updatedAt,
//       "model": model,
//       "reviewCount": reviewCount,
//       "skiPassType": skiPassType,
//       "services": services?.map((e) => e.toJson()).toList(),
//       "__v": v,
//     };
//   }
// }  working one


// class RecentService {
//   final String id;
//   final String title;
//   final String thumbnail;
//   final ServiceCategory? category;
//   final String owner;
//   final String openTime;
//   final String closeTime;
//   final String serviceArea;
//   final num serviceFee;
//   final String foodType;
//   final String status;
//   final List<ServiceItem> items;
//   final List<Slot> slots;
//   final num averageRating;
//   final List<Slot> availableSlots;
//   final List<Review> reviews;
//   final List<dynamic> refunds;
//   final String createdAt;
//   final String updatedAt;
//   final String model;
//   final int reviewCount;
//   final String? skiPassType;
//   final List<ProductService>? services;
//   final int? v;
//
//   // ⭐ New fields from response
//   final List<PriceByDuration> priceByDuration;
//   final num amount;
//   final String benefits;
//   final String ourRecommendations;
//
//   RecentService({
//     required this.id,
//     required this.title,
//     required this.thumbnail,
//     this.category,
//     required this.owner,
//     required this.openTime,
//     required this.closeTime,
//     required this.serviceArea,
//     this.serviceFee = 0,
//     required this.foodType,
//     required this.status,
//     this.items = const [],
//     this.slots = const [],
//     this.averageRating = 0,
//     this.availableSlots = const [],
//     this.reviews = const [],
//     this.refunds = const [],
//     required this.createdAt,
//     required this.updatedAt,
//     required this.model,
//     this.reviewCount = 0,
//     this.skiPassType,
//     this.services,
//     this.v,
//
//     // ⭐ Newly added
//     this.priceByDuration = const [],
//     this.amount = 0,
//     this.benefits = '',
//     this.ourRecommendations = '',
//   });
//
//   factory RecentService.fromJson(Map<String, dynamic> json) {
//     return RecentService(
//       id: json["_id"] ?? '',
//       title: json["title"] ?? '',
//       thumbnail: json["thumbnail"] ?? '',
//       category: json["category"] != null
//           ? ServiceCategory.fromJson(json["category"])
//           : null,
//       owner: json["owner"] ?? '',
//       openTime: json["openTime"] ?? '',
//       closeTime: json["closeTime"] ?? '',
//       serviceArea: json["serviceArea"] ?? '',
//       serviceFee: json["serviceFee"] ?? 0,
//       foodType: json["foodType"] ?? '',
//       status: json["status"] ?? '',
//       items: (json["items"] as List? ?? [])
//           .map((e) => ServiceItem.fromJson(e))
//           .toList(),
//       slots: (json["slots"] as List? ?? [])
//           .map((e) => Slot.fromJson(e))
//           .toList(),
//       averageRating: json["averageRating"] ?? 0,
//       availableSlots: (json["availableSlots"] as List? ?? [])
//           .map((e) => Slot.fromJson(e))
//           .toList(),
//       reviews: (json["reviews"] as List? ?? [])
//           .map((e) => Review.fromJson(e))
//           .toList(),
//       refunds: json["refunds"] ?? [],
//       createdAt: json["createdAt"] ?? '',
//       updatedAt: json["updatedAt"] ?? '',
//       model: json["model"] ?? '',
//       reviewCount: json["reviewCount"] ?? 0,
//       skiPassType: json['skiPassType'],
//       services: json['services'] != null
//           ? List<ProductService>.from(
//           json['services'].map((x) => ProductService.fromJson(x)))
//           : [],
//       v: json["__v"],
//
//       // ⭐ Newly added field parsing
//       priceByDuration: (json["priceByDuration"] as List? ?? [])
//           .map((e) => PriceByDuration.fromJson(e))
//           .toList(),
//       amount: json["amount"] ?? 0,
//       benefits: json["benefits"] ?? '',
//       ourRecommendations: json["ourRecommendations"] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "title": title,
//       "thumbnail": thumbnail,
//       "category": category?.toJson(),
//       "owner": owner,
//       "openTime": openTime,
//       "closeTime": closeTime,
//       "serviceArea": serviceArea,
//       "serviceFee": serviceFee,
//       "foodType": foodType,
//       "status": status,
//       "items": items.map((e) => e.toJson()).toList(),
//       "slots": slots.map((e) => e.toJson()).toList(),
//       "averageRating": averageRating,
//       "availableSlots": availableSlots.map((e) => e.toJson()).toList(),
//       "reviews": reviews.map((e) => e.toJson()).toList(),
//       "refunds": refunds,
//       "createdAt": createdAt,
//       "updatedAt": updatedAt,
//       "model": model,
//       "reviewCount": reviewCount,
//       "skiPassType": skiPassType,
//       "services": services?.map((e) => e.toJson()).toList(),
//       "__v": v,
//
//       // ⭐ Newly added fields
//       "priceByDuration": priceByDuration.map((e) => e.toJson()).toList(),
//       "amount": amount,
//       "benefits": benefits,
//       "ourRecommendations": ourRecommendations,
//     };
//   }
// } // work 2


/// Review model (for completeness, ensuring it's not removed)
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

// =========================================================================
// ⭐ UPDATED RecentService MODEL
// =========================================================================

/// Recent Service model - fully aligned with your ProviderHomeModel
class RecentService {
  final String id;
  final String title;
  final String thumbnail;
  final ServiceCategory? category;
  final String owner;
  final String openTime;
  final String closeTime;
  final String serviceArea;
  final num serviceFee;
  final String foodType;
  final String status;
  final List<ServiceItem> items;
  final List<Slot> slots;
  final num averageRating;
  final List<Slot> availableSlots;
  final List<Review> reviews;
  final List<dynamic> refunds;
  final String createdAt;
  final String updatedAt;
  final String model;
  final int reviewCount;
  final String? skiPassType;
  final List<ProductService>? services;
  final int? v;

  // Existing fields from previous model structure
  final List<PriceByDuration> priceByDuration;
  final num amount;
  final String benefits;
  final String ourRecommendations;
  final String description;

  // Transport / service-specific fields
  final String? personCount;
  final String milage;
  final String power;
  final String extraChargePerHours;
  final num insuranceFee;
  final num maintainCharge;

  // New fields from your JSON
  final num extraChargePerHour;
  final num totalPrice;

  RecentService({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.category,
    required this.owner,
    this.openTime = '',
    this.closeTime = '',
    required this.serviceArea,
    this.serviceFee = 0,
    this.foodType = '',
    this.status = '',
    this.items = const [],
    this.slots = const [],
    this.averageRating = 0,
    this.availableSlots = const [],
    this.reviews = const [],
    this.refunds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.model,
    this.reviewCount = 0,
    this.skiPassType,
    this.services,
    this.v,
    this.priceByDuration = const [],
    this.amount = 0,
    this.benefits = '',
    this.ourRecommendations = '',
    this.description = '',
    this.personCount = '',
    this.milage = '',
    this.power = '',
    this.extraChargePerHours = '',
    this.insuranceFee = 0,
    this.maintainCharge = 0,
    this.extraChargePerHour = 0,
    this.totalPrice = 0,
  });

  factory RecentService.fromJson(Map<String, dynamic> json) {
    return RecentService(
      id: json["_id"] ?? '',
      title: json["title"] ?? '',
      thumbnail: json["thumbnail"] ?? '',
      category: json["category"] != null
          ? ServiceCategory.fromJson(json["category"])
          : null,
      owner: json["owner"] ?? '',
      openTime: json["openTime"] ?? '',
      closeTime: json["closeTime"] ?? '',
      serviceArea: json["serviceArea"] ?? '',
      serviceFee: json["serviceFee"] ?? 0,
      foodType: json["foodType"] ?? '',
      status: json["status"] ?? '',
      items: (json["items"] as List? ?? [])
          .map((e) => ServiceItem.fromJson(e))
          .toList(),
      slots: (json["slots"] as List? ?? [])
          .map((e) => Slot.fromJson(e))
          .toList(),
      averageRating: json["averageRating"] ?? 0,
      availableSlots: (json["availableSlots"] as List? ?? [])
          .map((e) => Slot.fromJson(e))
          .toList(),
      reviews: (json["reviews"] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      refunds: json["refunds"] ?? [],
      createdAt: json["createdAt"] ?? '',
      updatedAt: json["updatedAt"] ?? '',
      model: json["model"] ?? '',
      reviewCount: json["reviewCount"] ?? 0,
      skiPassType: json['skiPassType'],
      services: json['services'] != null
          ? List<ProductService>.from(
          json['services'].map((x) => ProductService.fromJson(x)))
          : [],
      v: json["__v"],
      priceByDuration: (json["priceByDuration"] as List? ?? [])
          .map((e) => PriceByDuration.fromJson(e))
          .toList(),
      amount: json["amount"] ?? 0,
      benefits: json["benefits"] ?? '',
      ourRecommendations: json["ourRecommendations"] ?? '',
      description: json["description"] ?? '',
      personCount: json["personCount"]?.toString() ?? '',
      milage: json["milage"]?.toString() ?? '',
      power: json["power"]?.toString() ?? '',
      extraChargePerHours: json["extraChargePerHours"]?.toString() ?? '',
      insuranceFee: json["insuranceFee"] ?? 0,
      maintainCharge: json["maintainCharge"] ?? 0,
      extraChargePerHour: json["extraChargePerHour"] ?? 0,
      totalPrice: json["totalPrice"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "thumbnail": thumbnail,
      "category": category?.toJson(),
      "owner": owner,
      "openTime": openTime,
      "closeTime": closeTime,
      "serviceArea": serviceArea,
      "serviceFee": serviceFee,
      "foodType": foodType,
      "status": status,
      "items": items.map((e) => e.toJson()).toList(),
      "slots": slots.map((e) => e.toJson()).toList(),
      "averageRating": averageRating,
      "availableSlots": availableSlots.map((e) => e.toJson()).toList(),
      "reviews": reviews.map((e) => e.toJson()).toList(),
      "refunds": refunds,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "model": model,
      "reviewCount": reviewCount,
      "skiPassType": skiPassType,
      "services": services?.map((e) => e.toJson()).toList(),
      "__v": v,
      "priceByDuration": priceByDuration.map((e) => e.toJson()).toList(),
      "amount": amount,
      "benefits": benefits,
      "ourRecommendations": ourRecommendations,
      "description": description,
      "personCount": personCount,
      "milage": milage,
      "power": power,
      "extraChargePerHours": extraChargePerHours,
      "insuranceFee": insuranceFee,
      "maintainCharge": maintainCharge,
      "extraChargePerHour": extraChargePerHour,
      "totalPrice": totalPrice,
    };
  }
}



class PriceByDuration {
  final String duration;
  final num amount;
  final String id;

  PriceByDuration({
    required this.duration,
    required this.amount,
    required this.id,
  });

  factory PriceByDuration.fromJson(Map<String, dynamic> json) {
    return PriceByDuration(
      duration: json["duration"] ?? '',
      amount: json["amount"] ?? 0,
      id: json["_id"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "duration": duration,
      "amount": amount,
      "_id": id,
    };
  }
}



extension RecentServiceToSkiPass on home.RecentService {
  pass.SkiPass toSkiPass() {
    return pass.SkiPass(
      id: id,
      title: title,
      thumbnail: thumbnail,
      owner: owner,
      skiPassType: skiPassType ?? '',
      serviceArea: serviceArea,

      amount: amount != 0
          ? amount
          : totalPrice != 0
          ? totalPrice
          : serviceFee,

      description: description.isNotEmpty
          ? description
          : benefits,

      averageRating: averageRating,
      refunds: refunds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      v: v ?? 0,

      // ✅ EXPLICIT CONVERSIONS
      services: (services ?? [])
          .map((e) => pass.ProductService(
        title: e.title,
        description: e.description,
      ))
          .toList(),

      reviews: reviews
          .map((e) => pass.Review(
        userId: e.userId,
        rating: e.rating,
        comment: e.comment,
        createdAt: e.createdAt,
      ))
          .toList(),
    );
  }
}





