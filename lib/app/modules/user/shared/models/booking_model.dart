// -------------------- BOOKING MODEL --------------------
class BookingModel {
  final Pagination pagination;
  final List<Booking> result;

  BookingModel({
    required this.pagination,
    required this.result,
  });

  factory BookingModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    // ⭐ handle API data wrapper
    final data = json['data'] ?? json;

    return BookingModel(
      pagination: Pagination.fromJson(data['pagination'] ?? {}),
      result: (data['result'] as List? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
    );
  }
}

// -------------------- BOOKING --------------------
class Booking {
  final String id;
  final User user;
  final Product product;
  final String productModel;
  final String category;
  final DateTime startDateAndTime;
  final DateTime endDateAndTime;
  final List<BookingItem> bookingItems;
  final List<dynamic> slots;
  final String bookingStatus;
  final double totalPrice;
  final String phoneNumber;
  final String address;
  final bool isPermitted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String timeLabel;

  // ⭐ NEW FIELDS
  final String dateString;
  final String timeString;
  final DateTime bookingDateTime;

  Booking({
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
    required this.timeLabel,
    required this.dateString,
    required this.timeString,
    required this.bookingDateTime,
  });

  factory Booking.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    // ⭐ Parse date & time as string
    String dateString = json['date'] ?? '';
    String timeString = json['time'] ?? '';

    // ⭐ Combine into bookingDateTime - FIXED VERSION
    DateTime bookingDateTime = (() {
      try {
        if (dateString.isNotEmpty && timeString.isNotEmpty) {
          // Extract date part - handle both formats
          String datePart;
          if (dateString.contains('T')) {
            // Format: "2024-01-15T00:00:00.000Z"
            datePart = dateString.split('T')[0];
          } else {
            // Format: "2024-01-15"
            datePart = dateString;
          }

          // Combine date and time
          return DateTime.parse("${datePart}T$timeString:00.000Z");
        }
        return DateTime.now();
      } catch (_) {
        return DateTime.now();
      }
    })();

    return Booking(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      product: Product.fromJson(json['product'] ?? {}),
      productModel: json['productModel'] ?? '',
      category: json['category'] ?? '',
      startDateAndTime: parseDate(json['startDateAndTime']),
      endDateAndTime: parseDate(json['endDateAndTime']),
      bookingItems: (json['bookingItems'] as List? ?? [])
          .map((e) => BookingItem.fromJson(e))
          .toList(),
      slots: json['slots'] ?? [],
      bookingStatus: json['bookingStatus'] ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      isPermitted: json['isPermitted'] ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      timeLabel: json['timeLabel'] ?? '',

      // ⭐ NEW
      dateString: dateString,
      timeString: timeString,
      bookingDateTime: bookingDateTime,
    );
  }
}

// -------------------- BOOKING ITEM --------------------
class BookingItem {
  final String itemId;
  final int quantity;

  BookingItem({
    required this.itemId,
    required this.quantity,
  });

  factory BookingItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return BookingItem(
      itemId: json['itemId'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

// -------------------- USER --------------------
class User {
  final String id;
  final String fullName;
  final String email;
  final String profileUrl;
  final String address;
  final String status;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profileUrl,
    required this.address,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
    );
  }

  static User empty() => User(
    id: '',
    fullName: '',
    email: '',
    profileUrl: '',
    address: '',
    status: '',
  );
}

// -------------------- PRODUCT --------------------
class Product {
  final String id;
  final String category;
  final String title;
  final String thumbnail;
  final double extraChargePerHour;
  final String serviceArea;
  final List<ProductItem> items;

  Product({
    required this.id,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.extraChargePerHour,
    required this.serviceArea,
    required this.items,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Product(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      extraChargePerHour:
      (json['extraChargePerHour'] as num?)?.toDouble() ?? 0.0,
      serviceArea: json['serviceArea'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
    );
  }

  static Product empty() => Product(
    id: '',
    category: '',
    title: '',
    thumbnail: '',
    extraChargePerHour: 0.0,
    serviceArea: '',
    items: [],
  );
}

// -------------------- PRODUCT ITEM --------------------
class ProductItem {
  final String id;
  final String productName;
  final String productPhoto;
  final double price;
  final int totalQty;
  final int availableQty;

  ProductItem({
    required this.id,
    required this.productName,
    required this.productPhoto,
    required this.price,
    required this.totalQty,
    required this.availableQty,
  });

  factory ProductItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return ProductItem(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      productPhoto: json['productPhoto'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalQty: json['totalQty'] ?? 0,
      availableQty: json['availableQty'] ?? 0,
    );
  }
}

// -------------------- PAGINATION --------------------
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}