class TransportItemModel {
  int? code;
  String? message;
  TransportBookingData? data;

  TransportItemModel({this.code, this.message, this.data});

  TransportItemModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null
        ? TransportBookingData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TransportBookingData {
  String? id;
  User? user;
  bool? isHandOver;
  Product? product;
  String? productModel;
  String? category;
  String? startDateAndTime;
  String? endDateAndTime;
  String? startTime;
  String? endTime;
  String? timeLabel;
  String? bookingStatus;
  int? totalPrice;
  double? overTimeAmount;
  bool? isPermitted;
  List<dynamic>? slots;
  List<dynamic>? bookingItems;
  String? createdAt;
  String? updatedAt;
  int? version;

  TransportBookingData({
    this.id,
    this.user,
    this.product,
    this.isHandOver,

    this.productModel,
    this.category,
    this.startDateAndTime,
    this.endDateAndTime,
    this.startTime,
    this.endTime,
    this.timeLabel,
    this.bookingStatus,
    this.totalPrice,
    this.overTimeAmount,
    this.isPermitted,
    this.slots,
    this.bookingItems,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  TransportBookingData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    isHandOver = json['isHandOver'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    productModel = json['productModel'];
    category = json['category'];
    startDateAndTime = json['startDateAndTime'];
    endDateAndTime = json['endDateAndTime'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    timeLabel = json['timeLabel'];
    bookingStatus = json['bookingStatus'];
    totalPrice = json['totalPrice'];
    overTimeAmount = json['overTimeAmount'] != null
        ? (json['overTimeAmount'] as num).toDouble()
        : null;
    isPermitted = json['isPermitted'];
    slots = json['slots'] ?? [];
    bookingItems = json['bookingItems'] ?? [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    version = json['__v'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user?.toJson(),
      'isHandOver': isHandOver,
      'product': product?.toJson(),
      'productModel': productModel,
      'category': category,
      'startDateAndTime': startDateAndTime,
      'endDateAndTime': endDateAndTime,
      'startTime': startTime,
      'endTime': endTime,
      'timeLabel': timeLabel,
      'bookingStatus': bookingStatus,
      'totalPrice': totalPrice,
      'overTimeAmount': overTimeAmount,
      'isPermitted': isPermitted,
      'slots': slots,
      'bookingItems': bookingItems,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

class User {
  String? id;
  String? fullName;
  String? email;
  String? profileUrl;
  String? address;
  String? status;
  String? phoneNumber;

  User({
    this.id,
    this.fullName,
    this.email,
    this.profileUrl,
    this.address,
    this.status,
    this.phoneNumber,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    profileUrl = json['profileUrl'];
    address = json['address'];
    status = json['status'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
  String? id;
  String? thumbnail;
  String? title;
  String? personCount;
  String? milage;
  String? power;
  String? extraChargePerHours;
  int? insuranceFee;
  int? maintainCharge;
  String? serviceArea;
  int? amount;
  String? description;
  ProductCategory? category;

  Product({
    this.id,
    this.thumbnail,
    this.title,
    this.personCount,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.serviceArea,
    this.amount,
    this.description,
    this.category,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    thumbnail = json['thumbnail'];
    title = json['title'];
    personCount = json['personCount'];
    milage = json['milage'];
    power = json['power'];
    extraChargePerHours = json['extraChargePerHours'];
    insuranceFee = json['insuranceFee'];
    maintainCharge = json['maintainCharge'];
    serviceArea = json['serviceArea'];
    amount = json['amount'];
    description = json['description'];
    category = json['category'] != null
        ? ProductCategory.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'thumbnail': thumbnail,
      'title': title,
      'personCount': personCount,
      'milage': milage,
      'power': power,
      'extraChargePerHours': extraChargePerHours,
      'insuranceFee': insuranceFee,
      'maintainCharge': maintainCharge,
      'serviceArea': serviceArea,
      'amount': amount,
      'description': description,
      'category': category?.toJson(),
    };
  }
}

class ProductCategory {
  String? id;
  String? name;
  String? categoryPhoto;

  ProductCategory({this.id, this.name, this.categoryPhoto});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    categoryPhoto = json['categoryPhoto'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'categoryPhoto': categoryPhoto,
    };
  }
}
