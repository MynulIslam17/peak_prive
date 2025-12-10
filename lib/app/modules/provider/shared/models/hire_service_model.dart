class HireServiceModel {
  int? code;
  String? message;
  List<HireResult>? result;
  Pagination? pagination;

  HireServiceModel({
    this.code,
    this.message,
    this.result,
    this.pagination,
  });

  HireServiceModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      pagination = json['data']['pagination'] != null
          ? Pagination.fromJson(json['data']['pagination'])
          : null;

      result = json['data']['result'] != null
          ? (json['data']['result'] as List)
          .map((e) => HireResult.fromJson(e))
          .toList()
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': {
        'pagination': pagination?.toJson(),
        'result': result?.map((e) => e.toJson()).toList(),
      },
    };
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class HireResult {
  String? id;
  String? title;
  String? thumbnail;
  String? serviceArea;
  num? extraChargePerHour;
  num? totalPrice;
  num? averageRating;
  List<Item>? items;
  List<dynamic>? reviews;
  List<dynamic>? refunds;
  String? createdAt;
  String? updatedAt;
  Owner? owner;
  Category? category;

  HireResult({
    this.id,
    this.title,
    this.thumbnail,
    this.serviceArea,
    this.extraChargePerHour,
    this.totalPrice,
    this.averageRating,
    this.items,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.owner,
    this.category,
  });

  HireResult.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    serviceArea = json['serviceArea'];
    extraChargePerHour = json['extraChargePerHour'];
    totalPrice = json['totalPrice'];
    averageRating = json['averageRating'];

    items = json['items'] != null
        ? (json['items'] as List).map((e) => Item.fromJson(e)).toList()
        : null;

    reviews = json['reviews'] != null ? List<dynamic>.from(json['reviews']) : null;
    refunds = json['refunds'] != null ? List<dynamic>.from(json['refunds']) : null;

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'thumbnail': thumbnail,
      'serviceArea': serviceArea,
      'extraChargePerHour': extraChargePerHour,
      'totalPrice': totalPrice,
      'averageRating': averageRating,
      'items': items?.map((e) => e.toJson()).toList(),
      'reviews': reviews,
      'refunds': refunds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'owner': owner?.toJson(),
      'category': category?.toJson(),
    };
  }
}

class Item {
  String? id;
  String? name;
  String? productPhoto;
  num? price;
  num? quantity;
  num? availableQty;

  Item({this.id, this.name, this.productPhoto, this.price, this.quantity, this.availableQty});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['productName'];
    productPhoto = json['productPhoto'];
    price = json['price'];
    quantity = json['totalQty'];
    availableQty = json['availableQty'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': name,
      'productPhoto': productPhoto,
      'price': price,
      'totalQty': quantity,
      'availableQty': availableQty,
    };
  }
}

class Owner {
  String? id;
  String? fullName;
  String? email;
  String? profileUrl;
  String? providerType;
  String? status;
  String? role;
  String? phoneNumber;

  Owner({this.id, this.fullName, this.email, this.profileUrl, this.providerType, this.status, this.role, this.phoneNumber});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    profileUrl = json['profileUrl'];
    providerType = json['providerType'];
    status = json['status'];
    role = json['role'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profileUrl': profileUrl,
      'providerType': providerType,
      'status': status,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }
}

class Category {
  String? id;
  String? name;
  String? categoryPhoto;

  Category({this.id, this.name, this.categoryPhoto});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    categoryPhoto = json['categoryPhoto'] ?? json['icon'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'categoryPhoto': categoryPhoto,
    };
  }
}
