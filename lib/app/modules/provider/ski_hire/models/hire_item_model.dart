class HireItemModel {
  int? code;
  String? message;
  Data? data;

  HireItemModel({this.code, this.message, this.data});

  factory HireItemModel.fromJson(Map<String, dynamic> json) {
    return HireItemModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['code'] = code;
    json['message'] = message;
    if (data != null) json['data'] = data!.toJson();
    return json;
  }
}

class Data {
  String? sId;
  User? user;
  Product? product;
  String? productModel;
  String? category;
  String? startDateAndTime;
  String? endDateAndTime;
  List<BookingItems>? bookingItems;
  List<dynamic>? slots;
  String? bookingStatus;
  int? totalPrice;
  String? phoneNumber;
  String? address;
  bool? isPermitted;
  bool? isHandOver;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? timeLabel;
  double? overTimeAmount;

  Data({
    this.sId,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.startDateAndTime,
    this.endDateAndTime,
    this.bookingItems,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.phoneNumber,
    this.address,
    this.isPermitted,
    this.isHandOver,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.timeLabel,
    this.overTimeAmount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sId: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      startDateAndTime: json['startDateAndTime'],
      endDateAndTime: json['endDateAndTime'],
      bookingItems: json['bookingItems'] != null
          ? List<BookingItems>.from(
          json['bookingItems'].map((x) => BookingItems.fromJson(x)))
          : [],
      slots: json['slots'] != null ? List.from(json['slots']) : [],
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      isPermitted: json['isPermitted'],
      isHandOver: json['isHandOver'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
      timeLabel: json['timeLabel'],
      overTimeAmount: json['overTimeAmount'] is num
          ? (json['overTimeAmount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['_id'] = sId;
    if (user != null) json['user'] = user!.toJson();
    if (product != null) json['product'] = product!.toJson();
    json['productModel'] = productModel;
    json['category'] = category;
    json['startDateAndTime'] = startDateAndTime;
    json['endDateAndTime'] = endDateAndTime;
    json['bookingItems'] = bookingItems?.map((x) => x.toJson()).toList();
    json['slots'] = slots;
    json['bookingStatus'] = bookingStatus;
    json['totalPrice'] = totalPrice;
    json['phoneNumber'] = phoneNumber;
    json['address'] = address;
    json['isPermitted'] = isPermitted;
    json['isHandOver'] = isHandOver;
    json['createdAt'] = createdAt;
    json['updatedAt'] = updatedAt;
    json['__v'] = iV;
    json['timeLabel'] = timeLabel;
    json['overTimeAmount'] = overTimeAmount;
    return json;
  }
}

class User {
  String? sId;
  String? fullName;
  String? email;
  String? profileUrl;
  String? address;
  String? status;
  String? phoneNumber;

  User({
    this.sId,
    this.fullName,
    this.email,
    this.profileUrl,
    this.address,
    this.status,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      profileUrl: json['profileUrl']?.toString().trim(),
      address: json['address'],
      status: json['status'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'fullName': fullName,
      'email': email,
      'profileUrl': profileUrl,
      'address': address,
      'status': status,
      'phoneNumber': phoneNumber,
    };
  }
}

class Product {
  String? sId;
  String? category;
  String? title;
  String? thumbnail;
  int? extraChargePerHour;
  String? serviceArea;

  Product({
    this.sId,
    this.category,
    this.title,
    this.thumbnail,
    this.extraChargePerHour,
    this.serviceArea,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? catValue;
    final catRaw = json['category'];
    if (catRaw is String) {
      catValue = catRaw;
    } else if (catRaw is Map<String, dynamic>) {
      catValue = catRaw['name'];
    }

    return Product(
      sId: json['_id'],
      category: catValue,
      title: json['title'],
      thumbnail: json['thumbnail']?.toString().trim(),
      extraChargePerHour: json['extraChargePerHour'],
      serviceArea: json['serviceArea'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'category': category,
      'title': title,
      'thumbnail': thumbnail,
      'extraChargePerHour': extraChargePerHour,
      'serviceArea': serviceArea,
    };
  }
}

class BookingItems {
  String? itemId;
  int? quantity;
  Item? item;

  BookingItems({this.itemId, this.quantity, this.item});

  factory BookingItems.fromJson(Map<String, dynamic> json) {
    return BookingItems(
      itemId: json['itemId'],
      quantity: json['quantity'],
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['itemId'] = itemId;
    json['quantity'] = quantity;
    if (item != null) json['item'] = item!.toJson();
    return json;
  }
}

class Item {
  String? productName;
  String? productPhoto;
  int? price;
  int? totalQty;
  int? availableQty;
  String? sId;

  Item({
    this.productName,
    this.productPhoto,
    this.price,
    this.totalQty,
    this.availableQty,
    this.sId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      productName: json['productName'],
      productPhoto: json['productPhoto']?.toString().trim(),
      price: json['price'],
      totalQty: json['totalQty'],
      availableQty: json['availableQty'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productPhoto': productPhoto,
      'price': price,
      'totalQty': totalQty,
      'availableQty': availableQty,
      '_id': sId,
    };
  }
}