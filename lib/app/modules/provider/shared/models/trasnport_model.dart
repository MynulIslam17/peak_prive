class Booking {
  final String id;
  final String productModel; // "Transport" or "SkiHire"
  final String category; // "Transport" or "Ski_Hire"
  final BookingUser user;
  final BookingProduct product;
  final List<BookingItem>? bookingItems;
  final List<dynamic> slots;
  final String bookingStatus;
  final num totalPrice;
  final bool isPermitted;
  final String? phoneNumber; // SkiHire only
  final String? address; // SkiHire only
  final DateTime startDateAndTime;
  final DateTime endDateAndTime;
  final String duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.productModel,
    required this.category,
    required this.user,
    required this.product,
    this.bookingItems,
    required this.slots,
    required this.bookingStatus,
    required this.totalPrice,
    required this.isPermitted,
    this.phoneNumber,
    this.address,
    required this.startDateAndTime,
    required this.endDateAndTime,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      productModel: json['productModel'] ?? '',
      category: json['category'] ?? '',
      user: BookingUser.fromJson(json['user'] ?? {}),
      product: BookingProduct.fromJson(json['product'] ?? {}),
      bookingItems: json['bookingItems'] != null
          ? List<BookingItem>.from(
          json['bookingItems'].map((x) => BookingItem.fromJson(x)))
          : [],
      slots: json['slots'] ?? [],
      bookingStatus: json['bookingStatus'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      isPermitted: json['isPermitted'] ?? false,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      startDateAndTime: DateTime.tryParse(json['startDateAndTime'] ?? '') ??
          DateTime.now(),
      endDateAndTime: DateTime.tryParse(json['endDateAndTime'] ?? '') ??
          DateTime.now(),
      duration: json['duration'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
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
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? 'N/A',
    );
  }
}

class BookingProduct {
  final String id;
  final String title;
  final String thumbnail;
  final String serviceArea;
  final num totalPrice;
  final num averageRating;

  // Transport fields
  final String? milage;
  final String? power;
  final String? extraChargePerHours;
  final num? insuranceFee;
  final num? maintainCharge;
  final String? description;

  // SkiHire fields
  final num? extraChargePerHour;

  // Common
  final String? owner;
  final String? category;

  BookingProduct({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.serviceArea,
    required this.totalPrice,
    required this.averageRating,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.description,
    this.extraChargePerHour,
    this.owner,
    this.category,
  });

  factory BookingProduct.fromJson(Map<String, dynamic> json) {
    return BookingProduct(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      serviceArea: json['serviceArea'] ?? '',
      totalPrice: json['totalPrice'] ?? json['amount'] ?? 0,
      averageRating: json['averageRating'] ?? 0,
      milage: json['milage'],
      power: json['power'],
      extraChargePerHours: json['extraChargePerHours'],
      insuranceFee: json['insuranceFee'],
      maintainCharge: json['maintainCharge'],
      description: json['description'],
      extraChargePerHour: json['extraChargePerHour'],
      owner: json['owner'],
      category: json['category'],
    );
  }
}

class BookingItem {
  final String itemId;
  final int quantity;

  BookingItem({required this.itemId, required this.quantity});

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json['itemId'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}
