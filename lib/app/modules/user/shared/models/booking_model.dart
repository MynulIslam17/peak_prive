import 'dart:convert';

class BookingModel {
  final List<Booking> result;

  BookingModel({required this.result});

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => Booking.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'result': result.map((e) => e.toJson()).toList(),
  };
}

class Booking {
  final String? id;
  final User? user;
  final Product? product;
  final String? productModel;
  final String? category;

  // common booking fields
  final int? personCount;
  final DateTime? date;
  final String? time;
  final DateTime? startDateAndTime;
  final DateTime? endDateAndTime;
  final List<String>? slots;
  final String? bookingStatus;
  final double? totalPrice;
  final bool? isPermitted;
  final List<BookingItem>? bookingItems;
  final String? timeLabel;
  final Map<String, dynamic>? extra; // catch unknown fields

  Booking({
    this.id,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.personCount,
    this.date,
    this.time,
    this.startDateAndTime,
    this.endDateAndTime,
    this.slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.bookingItems,
    this.timeLabel,
    this.extra,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productModel: json['productModel'],
      category: json['category'],
      personCount: json['personCount'] != null
          ? int.tryParse(json['personCount'].toString()) ?? json['personCount']
          : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: json['time'],
      startDateAndTime: json['startDateAndTime'] != null
          ? DateTime.tryParse(json['startDateAndTime'])
          : null,
      endDateAndTime:
      json['endDateAndTime'] != null ? DateTime.tryParse(json['endDateAndTime']) : null,
      slots: json['slots'] != null
          ? (json['slots'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      bookingStatus: json['bookingStatus'],
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      isPermitted: json['isPermitted'],
      bookingItems: json['bookingItems'] != null
          ? (json['bookingItems'] as List<dynamic>)
          .map((e) => BookingItem.fromJson(e))
          .toList()
          : [],
      timeLabel: json['timeLabel'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user?.toJson(),
    'product': product?.toJson(),
    'productModel': productModel,
    'category': category,
    'personCount': personCount,
    'date': date?.toIso8601String(),
    'time': time,
    'startDateAndTime': startDateAndTime?.toIso8601String(),
    'endDateAndTime': endDateAndTime?.toIso8601String(),
    'slots': slots,
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'isPermitted': isPermitted,
    'bookingItems': bookingItems?.map((e) => e.toJson()).toList(),
    'timeLabel': timeLabel,
  };
}

class User {
  final String? id;
  final String? email;
  final String? status;
  final String? fullName;
  final String? address;
  final String? phoneNumber;
  final String? profileUrl;

  User({
    this.id,
    this.email,
    this.status,
    this.fullName,
    this.address,
    this.phoneNumber,
    this.profileUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      status: json['status'],
      fullName: json['fullName'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      profileUrl: json['profileUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'status': status,
    'fullName': fullName,
    'address': address,
    'phoneNumber': phoneNumber,
    'profileUrl': profileUrl,
  };
}

class Product {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? skiPassType;
  final List<Service>? services;
  final String? serviceArea;
  final double? amount;
  final String? description;
  final int? extraChargePerHour;
  final String? foodType;
  final String? status;
  final String? openTime;
  final String? closeTime;
  final List<Slot>? slots;
  final List<Slot>? availableSlots;
  final int? personCount;
  final String? milage;
  final String? power;
  final String? extraChargePerHours;
  final double? insuranceFee;
  final double? maintainCharge;
  final Map<String, dynamic>? extra;

  Product({
    this.id,
    this.title,
    this.thumbnail,
    this.skiPassType,
    this.services,
    this.serviceArea,
    this.amount,
    this.description,
    this.extraChargePerHour,
    this.foodType,
    this.status,
    this.openTime,
    this.closeTime,
    this.slots,
    this.availableSlots,
    this.personCount,
    this.milage,
    this.power,
    this.extraChargePerHours,
    this.insuranceFee,
    this.maintainCharge,
    this.extra,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      skiPassType: json['skiPassType'],
      services: json['services'] != null
          ? (json['services'] as List<dynamic>).map((e) => Service.fromJson(e)).toList()
          : [],
      serviceArea: json['serviceArea'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      description: json['description'],
      extraChargePerHour: json['extraChargePerHour'],
      foodType: json['foodType'],
      status: json['status'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      slots: json['slots'] != null
          ? (json['slots'] as List<dynamic>).map((e) => Slot.fromJson(e)).toList()
          : [],
      availableSlots: json['availableSlots'] != null
          ? (json['availableSlots'] as List<dynamic>).map((e) => Slot.fromJson(e)).toList()
          : [],
      personCount: json['personCount'] != null
          ? int.tryParse(json['personCount'].toString()) ?? json['personCount']
          : null,
      milage: json['milage'],
      power: json['power'],
      extraChargePerHours: json['extraChargePerHours'],
      insuranceFee:
      json['insuranceFee'] != null ? (json['insuranceFee'] as num).toDouble() : null,
      maintainCharge:
      json['maintainCharge'] != null ? (json['maintainCharge'] as num).toDouble() : null,
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'thumbnail': thumbnail,
    'skiPassType': skiPassType,
    'services': services?.map((e) => e.toJson()).toList(),
    'serviceArea': serviceArea,
    'amount': amount,
    'description': description,
    'extraChargePerHour': extraChargePerHour,
    'foodType': foodType,
    'status': status,
    'openTime': openTime,
    'closeTime': closeTime,
    'slots': slots?.map((e) => e.toJson()).toList(),
    'availableSlots': availableSlots?.map((e) => e.toJson()).toList(),
    'personCount': personCount,
    'milage': milage,
    'power': power,
    'extraChargePerHours': extraChargePerHours,
    'insuranceFee': insuranceFee,
    'maintainCharge': maintainCharge,
  };
}

class Service {
  final String? title;
  final String? description;

  Service({this.title, this.description});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}

class Slot {
  final String? startTime;
  final String? endTime;
  final String? id;

  Slot({this.startTime, this.endTime, this.id});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: json['startTime'],
      endTime: json['endTime'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
    '_id': id,
  };
}

class BookingItem {
  final String? itemId;
  final int? quantity;
  final dynamic item;

  BookingItem({this.itemId, this.quantity, this.item});

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      itemId: json['itemId'],
      quantity: json['quantity'],
      item: json['item'],
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'item': item,
  };
}
