class AllBookingModel {  /// this is model for all booking
  int? code;
  String? message;
  Data? data;

  AllBookingModel({this.code, this.message, this.data});

  factory AllBookingModel.fromJson(Map<String, dynamic> json) =>
      AllBookingModel(
        code: json['code'] as int?,
        message: json['message'] as String?,
        data: json['data'] != null
            ? Data.fromJson(json['data'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  Pagination? pagination;
  List<Result> result;

  Data({this.pagination, List<Result>? result})
      : result = result ?? [];

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null,
    result: json['result'] != null
        ? (json['result'] as List)
        .map((e) => Result.fromJson(e))
        .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
    'result': result.map((e) => e.toJson()).toList(),
  };
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int?,
    page: json['page'] as int?,
    limit: json['limit'] as int?,
    totalPages: json['totalPages'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

class Result {
  String? sId;
  User? user;
  Product? product;

  // UNIVERSAL FIELDS FOR ALL BOOKING TYPES
  String? productModel;
  String? category;

  // Ski Pass
  int? personCount;
  String? date;
  String? time;

  // Ski Hire / Transport
  String? startDateAndTime;
  String? endDateAndTime;

  // Massage
  String? duration;

  // Restaurant
  List<Slot> slots;

  // Others
  List<BookingItems> bookingItems;
  String? bookingStatus;
  int? totalPrice;

  String? phoneNumber;
  String? address;

  bool? isPermitted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Result({
    this.sId,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.date,
    this.time,
    this.startDateAndTime,
    this.endDateAndTime,
    this.duration,
    List<Slot>? slots,
    List<BookingItems>? bookingItems,
    this.bookingStatus,
    this.totalPrice,
    this.phoneNumber,
    this.address,
    this.isPermitted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  })  : slots = slots ?? [],
        bookingItems = bookingItems ?? [];

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    sId: json['_id'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
    product: json['product'] != null ? Product.fromJson(json['product']) : null,
    productModel: json['productModel'],
    category: json['category'],

    // Ski Pass fields
    personCount: json['personCount'],
    date: json['date'],
    time: json['time'],

    // Ski Hire / Transport fields
    startDateAndTime: json['startDateAndTime'],
    endDateAndTime: json['endDateAndTime'],

    // Massage
    duration: json['duration'],

    // Slots (Restaurant or others)
    slots: json['slots'] != null
        ? (json['slots'] as List)
        .map((e) => Slot.fromJson(e))
        .toList()
        : [],

    bookingItems: json['bookingItems'] != null
        ? (json['bookingItems'] as List)
        .map((e) => BookingItems.fromJson(e))
        .toList()
        : [],

    bookingStatus: json['bookingStatus'],
    totalPrice: json['totalPrice'],
    phoneNumber: json['phoneNumber'],
    address: json['address'],
    isPermitted: json['isPermitted'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    iV: json['__v'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'user': user?.toJson(),
    'product': product?.toJson(),
    'productModel': productModel,
    'category': category,
    'personCount': personCount,
    'date': date,
    'time': time,
    'startDateAndTime': startDateAndTime,
    'endDateAndTime': endDateAndTime,
    'duration': duration,
    'slots': slots.map((e) => e.toJson()).toList(),
    'bookingItems': bookingItems.map((e) => e.toJson()).toList(),
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'phoneNumber': phoneNumber,
    'address': address,
    'isPermitted': isPermitted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': iV,
  };
}

class Slot {
  String? startTime;
  String? endTime;
  String? sId;

  Slot({this.startTime, this.endTime, this.sId});

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    startTime: json['startTime'],
    endTime: json['endTime'],
    sId: json['_id'],
  );

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
    '_id': sId,
  };
}

class User {
  String? sId;
  String? fullName;
  String? email;
  String? address;
  String? phoneNumber;

  User({this.sId, this.fullName, this.email, this.address, this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) => User(
    sId: json['_id'],
    fullName: json['fullName'],
    email: json['email'],
    address: json['address'],
    phoneNumber: json['phoneNumber'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'fullName': fullName,
    'email': email,
    'address': address,
    'phoneNumber': phoneNumber,
  };
}

class Product {
  String? sId;
  String? thumbnail;
  String? title;
  String? skiPassType;
  String? serviceArea;

  Product({
    this.sId,
    this.thumbnail,
    this.title,
    this.skiPassType,
    this.serviceArea,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    sId: json['_id'],
    thumbnail: json['thumbnail'],
    title: json['title'],
    skiPassType: json['skiPassType'],
    serviceArea: json['serviceArea'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'thumbnail': thumbnail,
    'title': title,
    'skiPassType': skiPassType,
    'serviceArea': serviceArea,
  };
}

class BookingItems {
  String? itemId;
  int? quantity;
  ItemDetails? itemDetails;

  BookingItems({this.itemId, this.quantity, this.itemDetails});

  factory BookingItems.fromJson(Map<String, dynamic> json) => BookingItems(
    itemId: json['itemId'],
    quantity: json['quantity'],
    itemDetails: json['itemDetails'] != null
        ? ItemDetails.fromJson(json['itemDetails'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'itemDetails': itemDetails?.toJson(),
  };
}

class ItemDetails {
  String? sId;
  String? productName;
  String? productPhoto;
  int? price;
  int? totalQty;
  int? availableQty;

  // restaurant only
  String? seat;
  String? photo;
  String? description;

  ItemDetails({
    this.sId,
    this.productName,
    this.productPhoto,
    this.price,
    this.totalQty,
    this.availableQty,
    this.seat,
    this.photo,
    this.description,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) => ItemDetails(
    sId: json['_id'],
    productName: json['productName'],
    productPhoto: json['productPhoto'],
    price: json['price'],
    totalQty: json['totalQty'],
    availableQty: json['availableQty'],
    seat: json['seat'],
    photo: json['photo'],
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'productName': productName,
    'productPhoto': productPhoto,
    'price': price,
    'totalQty': totalQty,
    'availableQty': availableQty,
    'seat': seat,
    'photo': photo,
    'description': description,
  };
}