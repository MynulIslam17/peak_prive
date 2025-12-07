class TransportServiceModel {
  int? code;
  String? message;
  Data? data;

  TransportServiceModel({this.code, this.message, this.data});

  factory TransportServiceModel.fromJson(Map<String, dynamic> json) {
    return TransportServiceModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  Pagination? pagination;
  List<TransportResult>? result;

  Data({this.pagination, this.result});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      result: json['result'] != null
          ? List<TransportResult>.from(json['result'].map((x) => TransportResult.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (pagination != null) data['pagination'] = pagination!.toJson();
    data['result'] = result?.map((x) => x.toJson()).toList();
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
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

class TransportResult {
  String? sId;
  String? owner;
  Category? category;
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
  int? averageRating;
  List<dynamic>? reviews;
  List<dynamic>? refunds;
  String? createdAt;
  String? updatedAt;
  int? iV;

  TransportResult({
    this.sId,
    this.owner,
    this.category,
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
    this.averageRating,
    this.reviews,
    this.refunds,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory TransportResult.fromJson(Map<String, dynamic> json) {
    return TransportResult(
      sId: json['_id'],
      owner: json['owner'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      thumbnail: json['thumbnail'],
      title: json['title'],
      personCount: json['personCount'],
      milage: json['milage'],
      power: json['power'],
      extraChargePerHours: json['extraChargePerHours'],
      insuranceFee: json['insuranceFee'],
      maintainCharge: json['maintainCharge'],
      serviceArea: json['serviceArea'],
      amount: json['amount'],
      description: json['description'],
      averageRating: json['averageRating'],
      reviews: json['reviews'] ?? [],
      refunds: json['refunds'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['owner'] = owner;
    if (category != null) data['category'] = category!.toJson();
    data['thumbnail'] = thumbnail;
    data['title'] = title;
    data['personCount'] = personCount;
    data['milage'] = milage;
    data['power'] = power;
    data['extraChargePerHours'] = extraChargePerHours;
    data['insuranceFee'] = insuranceFee;
    data['maintainCharge'] = maintainCharge;
    data['serviceArea'] = serviceArea;
    data['amount'] = amount;
    data['description'] = description;
    data['averageRating'] = averageRating;
    data['reviews'] = reviews ?? [];
    data['refunds'] = refunds ?? [];
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Category {
  String? name;
  String? categoryPhoto;
  String? sId;

  Category({this.name, this.categoryPhoto, this.sId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      categoryPhoto: json['categoryPhoto'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryPhoto': categoryPhoto,
      '_id': sId,
    };
  }
}
