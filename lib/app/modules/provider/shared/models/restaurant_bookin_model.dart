class RestaurantBookingModel {
  int? code;
  String? message;
  Data? data;

  RestaurantBookingModel({this.code, this.message, this.data});

  factory RestaurantBookingModel.fromJson(Map<String, dynamic> json) => RestaurantBookingModel(
    code: json['code'],
    message: json['message'],
    data: json['data'] != null ? Data.fromJson(json['data']) : null,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  Pagination? pagination;
  List<RestaurantResult> result;

  Data({this.pagination, List<RestaurantResult>? result}) : result = result ?? [];

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    result: json['result'] != null
        ? List<RestaurantResult>.from(json['result'].map((x) => RestaurantResult.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
    'result': result.map((x) => x.toJson()).toList(),
  };
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'],
    page: json['page'],
    limit: json['limit'],
    totalPages: json['totalPages'],
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

// Renamed Result to RestaurantResult
class RestaurantResult {
  String? sId;
  User? user;
  Product? product;
  String? productModel;
  String? category;
  String? date;
  List<BookingItems> bookingItems;
  List<String> slots;
  String? bookingStatus;
  int? totalPrice;
  bool? isPermitted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  RestaurantResult({
    this.sId,
    this.user,
    this.product,
    this.productModel,
    this.category,
    this.date,
    List<BookingItems>? bookingItems,
    List<String>? slots,
    this.bookingStatus,
    this.totalPrice,
    this.isPermitted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  })  : bookingItems = bookingItems ?? [],
        slots = slots ?? [];

  factory RestaurantResult.fromJson(Map<String, dynamic> json) => RestaurantResult(
    sId: json['_id'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
    product: json['product'] != null ? Product.fromJson(json['product']) : null,
    productModel: json['productModel'],
    category: json['category'],
    date: json['date'],
    bookingItems: json['bookingItems'] != null
        ? List<BookingItems>.from(json['bookingItems'].map((x) => BookingItems.fromJson(x)))
        : [],
    slots: json['slots'] != null ? List<String>.from(json['slots']) : [],
    bookingStatus: json['bookingStatus'],
    totalPrice: json['totalPrice'],
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
    'date': date,
    'bookingItems': bookingItems.map((x) => x.toJson()).toList(),
    'slots': slots,
    'bookingStatus': bookingStatus,
    'totalPrice': totalPrice,
    'isPermitted': isPermitted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': iV,
  };
}

class User {
  String? sId;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? address;

  User({this.sId, this.fullName, this.email, this.phoneNumber, this.address});

  factory User.fromJson(Map<String, dynamic> json) => User(
    sId: json['_id'],
    fullName: json['fullName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    address: json['address'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
  };
}

class Product {
  String? sId;
  String? title;
  String? thumbnail;
  String? category;
  String? owner;
  String? openTime;
  String? closeTime;
  String? foodType;
  String? status;
  List<Items> items;
  String? description;
  List<Slots> slots;
  List<AvailableSlots> availableSlots;
  int? serviceFee;

  Product({
    this.sId,
    this.title,
    this.thumbnail,
    this.category,
    this.owner,
    this.openTime,
    this.closeTime,
    this.foodType,
    this.status,
    List<Items>? items,
    this.description,
    List<Slots>? slots,
    List<AvailableSlots>? availableSlots,
    this.serviceFee,
  })  : items = items ?? [],
        slots = slots ?? [],
        availableSlots = availableSlots ?? [];

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    sId: json['_id'],
    title: json['title'],
    thumbnail: json['thumbnail'],
    category: json['category'],
    owner: json['owner'],
    openTime: json['openTime'],
    closeTime: json['closeTime'],
    foodType: json['foodType'],
    status: json['status'],
    items: json['items'] != null ? List<Items>.from(json['items'].map((x) => Items.fromJson(x))) : [],
    description: json['description'],
    slots: json['slots'] != null ? List<Slots>.from(json['slots'].map((x) => Slots.fromJson(x))) : [],
    availableSlots: json['availableSlots'] != null
        ? List<AvailableSlots>.from(json['availableSlots'].map((x) => AvailableSlots.fromJson(x)))
        : [],
    serviceFee: json['serviceFee'],
  );

  Map<String, dynamic> toJson() => {
    '_id': sId,
    'title': title,
    'thumbnail': thumbnail,
    'category': category,
    'owner': owner,
    'openTime': openTime,
    'closeTime': closeTime,
    'foodType': foodType,
    'status': status,
    'items': items.map((x) => x.toJson()).toList(),
    'description': description,
    'slots': slots.map((x) => x.toJson()).toList(),
    'availableSlots': availableSlots.map((x) => x.toJson()).toList(),
    'serviceFee': serviceFee,
  };
}

class Items {
  String? seat;
  String? photo;
  int? totalQty;
  int? availableQty;
  int? price;
  String? description;
  String? sId;

  Items({this.seat, this.photo, this.totalQty, this.availableQty, this.price, this.description, this.sId});

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    seat: json['seat'],
    photo: json['photo'],
    totalQty: json['totalQty'],
    availableQty: json['availableQty'],
    price: json['price'],
    description: json['description'],
    sId: json['_id'],
  );

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'photo': photo,
    'totalQty': totalQty,
    'availableQty': availableQty,
    'price': price,
    'description': description,
    '_id': sId,
  };
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

class BookingItems {
  String? itemId;
  int? quantity;

  BookingItems({this.itemId, this.quantity});

  factory BookingItems.fromJson(Map<String, dynamic> json) => BookingItems(
    itemId: json['itemId'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
  };
}

class AvailableSlots {
  String? startTime;
  String? endTime;

  AvailableSlots({this.startTime, this.endTime});

  factory AvailableSlots.fromJson(Map<String, dynamic> json) => AvailableSlots(
    startTime: json['startTime'],
    endTime: json['endTime'],
  );

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
  };
}
