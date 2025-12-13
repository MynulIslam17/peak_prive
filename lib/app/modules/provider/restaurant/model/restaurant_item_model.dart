class RestaurantItemModel {
  int? code;
  String? message;
  Data? data;

  RestaurantItemModel({this.code, this.message, this.data});

  factory RestaurantItemModel.fromJson(Map<String, dynamic> json) {
    return RestaurantItemModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class Data {
  String? sId;
  User? user;
  Product? product;
  String? productModel;
  String? category;
  String? date;
  List<BookingItems>? bookingItems;
  List<Slots>? slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.date,
    this.bookingItems,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sId: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      date: json['date'],
      bookingItems: json['bookingItems'] != null
          ? List<BookingItems>.from(
          json['bookingItems'].map((x) => BookingItems.fromJson(x)))
          : null,
      slots: json['slots'] != null
          ? List<Slots>.from(json['slots'].map((x) => Slots.fromJson(x)))
          : null,
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      isPermitted: json['isPermitted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = sId;
    if (user != null) map['user'] = user!.toJson();
    if (product != null) map['product'] = product!.toJson();
    map['productModel'] = productModel;
    map['category'] = category;
    map['date'] = date;
    if (bookingItems != null) {
      map['bookingItems'] = bookingItems!.map((x) => x.toJson()).toList();
    }
    if (slots != null) {
      map['slots'] = slots!.map((x) => x.toJson()).toList();
    }
    map['bookingStatus'] = bookingStatus;
    map['totalPrice'] = totalPrice;
    map['isPermitted'] = isPermitted;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = iV;
    return map;
  }
}

class User {
  String? sId;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? profileUrl;
  String? address;
  String? status;

  User({
    this.sId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profileUrl,
    this.address,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    sId: json['_id'],
    fullName: json['fullName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    profileUrl: json['profileUrl'],
    address: json['address'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'profileUrl': profileUrl,
    'address': address,
    'status': status,
  };
}

class Product {
  String? sId;
  String? title;
  String? thumbnail;
  String? category;
  String? openTime;
  String? closeTime;
  String? serviceArea;
  String? foodType;
  String? status;
  String? description;
  List<Slots>? slots;
  List<AvailableSlots>? availableSlots;
  int? serviceFee;

  Product({
    this.sId,
    this.title,
    this.thumbnail,
    this.category,
    this.openTime,
    this.closeTime,
    this.serviceArea,
    this.foodType,
    this.status,
    this.description,
    this.slots,
    this.availableSlots,
    this.serviceFee,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    sId: json['_id'],
    title: json['title'],
    thumbnail: json['thumbnail'],
    category: json['category'],
    openTime: json['openTime'],
    closeTime: json['closeTime'],
    serviceArea: json['serviceArea'],
    foodType: json['foodType'],
    status: json['status'],
    description: json['description'],
    slots: json['slots'] != null
        ? List<Slots>.from(json['slots'].map((x) => Slots.fromJson(x)))
        : null,
    availableSlots: json['availableSlots'] != null
        ? List<AvailableSlots>.from(
        json['availableSlots'].map((x) => AvailableSlots.fromJson(x)))
        : null,
    serviceFee: json['serviceFee'],
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = sId;
    map['title'] = title;
    map['thumbnail'] = thumbnail;
    map['category'] = category;
    map['openTime'] = openTime;
    map['closeTime'] = closeTime;
    map['serviceArea'] = serviceArea;
    map['foodType'] = foodType;
    map['status'] = status;
    map['description'] = description;
    if (slots != null) map['slots'] = slots!.map((x) => x.toJson()).toList();
    if (availableSlots != null) {
      map['availableSlots'] = availableSlots!.map((x) => x.toJson()).toList();
    }
    map['serviceFee'] = serviceFee;
    return map;
  }
}

class Slots {
  String? startTime;
  String? endTime;
  String? sId;

  Slots({this.startTime, this.endTime, this.sId});

  factory Slots.fromJson(Map<String, dynamic> json) => Slots(
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

class AvailableSlots {
  String? sId;
  String? startTime;
  String? endTime;

  AvailableSlots({this.sId, this.startTime, this.endTime});

  factory AvailableSlots.fromJson(Map<String, dynamic> json) => AvailableSlots(
    sId: json['_id'],
    startTime: json['startTime'],
    endTime: json['endTime'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'startTime': startTime,
    'endTime': endTime,
  };
}

class BookingItems {
  String? itemId;
  int? quantity;
  dynamic item;

  BookingItems({this.itemId, this.quantity, this.item});

  factory BookingItems.fromJson(Map<String, dynamic> json) => BookingItems(
    itemId: json['itemId'],
    quantity: json['quantity'],
    item: json['item'],
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'item': item,
  };
}
