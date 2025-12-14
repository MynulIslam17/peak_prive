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
    if (data != null) map['data'] = data!.toJson();
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
  Map<String, dynamic>? extra;

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
    this.extra,
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
          (json['bookingItems'] as List).map((x) => BookingItems.fromJson(x)))
          : [],
      slots: json['slots'] != null
          ? List<Slots>.from((json['slots'] as List).map((x) => Slots.fromJson(x)))
          : [],
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      isPermitted: json['isPermitted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => [
          '_id',
          'user',
          'product',
          'productModel',
          'category',
          'date',
          'bookingItems',
          'slots',
          'bookingStatus',
          'totalPrice',
          'isPermitted',
          'createdAt',
          'updatedAt',
          '__v'
        ].contains(key)),
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
    map['bookingItems'] = bookingItems?.map((x) => x.toJson()).toList() ?? [];
    map['slots'] = slots?.map((x) => x.toJson()).toList() ?? [];
    map['bookingStatus'] = bookingStatus;
    map['totalPrice'] = totalPrice;
    map['isPermitted'] = isPermitted;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = iV;
    if (extra != null) map.addAll(extra!);
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
  Map<String, dynamic>? extra;

  User({
    this.sId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profileUrl,
    this.address,
    this.status,
    this.extra,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileUrl: json['profileUrl'],
      address: json['address'],
      status: json['status'],
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) =>
            ['_id', 'fullName', 'email', 'phoneNumber', 'profileUrl', 'address', 'status']
                .contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = sId;
    map['fullName'] = fullName;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['profileUrl'] = profileUrl;
    map['address'] = address;
    map['status'] = status;
    if (extra != null) map.addAll(extra!);
    return map;
  }
}

class Product {
  String? sId;
  String? title;
  String? thumbnail;
  Category? category;
  String? openTime;
  String? closeTime;
  String? serviceArea;
  String? foodType;
  String? status;
  String? description;
  List<Slots>? slots;
  List<AvailableSlots>? availableSlots;
  int? serviceFee;
  Map<String, dynamic>? extra;

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
    this.extra,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sId: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      serviceArea: json['serviceArea'],
      foodType: json['foodType'],
      status: json['status'],
      description: json['description'],
      slots: json['slots'] != null
          ? List<Slots>.from((json['slots'] as List).map((x) => Slots.fromJson(x)))
          : [],
      availableSlots: json['availableSlots'] != null
          ? List<AvailableSlots>.from(
          (json['availableSlots'] as List).map((x) => AvailableSlots.fromJson(x)))
          : [],
      serviceFee: json['serviceFee'],
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => [
          '_id',
          'title',
          'thumbnail',
          'category',
          'openTime',
          'closeTime',
          'serviceArea',
          'foodType',
          'status',
          'description',
          'slots',
          'availableSlots',
          'serviceFee'
        ].contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = sId;
    map['title'] = title;
    map['thumbnail'] = thumbnail;
    if (category != null) map['category'] = category!.toJson();
    map['openTime'] = openTime;
    map['closeTime'] = closeTime;
    map['serviceArea'] = serviceArea;
    map['foodType'] = foodType;
    map['status'] = status;
    map['description'] = description;
    map['slots'] = slots?.map((x) => x.toJson()).toList() ?? [];
    map['availableSlots'] = availableSlots?.map((x) => x.toJson()).toList() ?? [];
    map['serviceFee'] = serviceFee;
    if (extra != null) map.addAll(extra!);
    return map;
  }
}

class Category {
  String? sId;
  String? name;
  String? categoryPhoto;
  Map<String, dynamic>? extra;

  Category({this.sId, this.name, this.categoryPhoto, this.extra});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      sId: json['_id'],
      name: json['name'],
      categoryPhoto: json['categoryPhoto'],
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => ['_id', 'name', 'categoryPhoto'].contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = sId;
    map['name'] = name;
    map['categoryPhoto'] = categoryPhoto;
    if (extra != null) map.addAll(extra!);
    return map;
  }
}

class Slots {
  String? startTime;
  String? endTime;
  String? sId;

  Slots({this.startTime, this.endTime, this.sId});

  factory Slots.fromJson(Map<String, dynamic> json) {
    return Slots(
      startTime: json['startTime'],
      endTime: json['endTime'],
      sId: json['_id'],
    );
  }

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

  factory AvailableSlots.fromJson(Map<String, dynamic> json) {
    return AvailableSlots(
      sId: json['_id'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

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

  factory BookingItems.fromJson(Map<String, dynamic> json) {
    return BookingItems(
      itemId: json['itemId'],
      quantity: json['quantity'],
      item: json['item'], // Keep dynamic to allow any structure
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'item': item,
  };
}
