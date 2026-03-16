import '../../../../core/utils/json_helper.dart';

/// Root model for My Itinerary API response
class MyItinerary {
  final int code;
  final String message;
  final ItineraryData data;

  MyItinerary({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MyItinerary.fromJson(Map<String, dynamic> json) {
    return MyItinerary(
      code: JsonHelper.getInt(json['code']),
      message: JsonHelper.getString(json['message']),
      data: ItineraryData.fromJson(
        JsonHelper.getMap(json['data']) ?? {},
      ),
    );
  }
}
/// Contains pagination and list of itinerary items
class ItineraryData {
  final Pagination pagination;
  final List<ItineraryItem> result;

  ItineraryData({
    required this.pagination,
    required this.result,
  });

  factory ItineraryData.fromJson(Map<String, dynamic> json) {
    return ItineraryData(
      pagination: Pagination.fromJson(
        JsonHelper.getMap(json['pagination']) ?? {},
      ),
      result: JsonHelper.getList(json['result'])
          .map((e) => ItineraryItem.fromJson(e))
          .toList(),
    );
  }
}

/// Pagination information for the API response
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

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: JsonHelper.getInt(json['total']),
      page: JsonHelper.getInt(json['page']),
      limit: JsonHelper.getInt(json['limit']),
      totalPages: JsonHelper.getInt(json['totalPages']),
    );
  }
}

/// Represents a single booking item in the itinerary
class ItineraryItem {
  final String id;
  final Product? product;
  final String productModel;
  final String category;

  final String? date;
  final String? time;
  final String? startTime;
  final String? endTime;
  final String? duration;

  final int? personCount;
  final int? bookingSeatCount;

  final String bookingStatus;
  final double totalPrice;

  final String? timeLabel;

  ItineraryItem({
    required this.id,
    this.product,
    required this.productModel,
    required this.category,
    this.date,
    this.time,
    this.startTime,
    this.endTime,
    this.duration,
    this.personCount,
    required this.bookingStatus,
    required this.totalPrice,
    this.timeLabel,
    this.bookingSeatCount,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: JsonHelper.getString(json['_id']),
      product: JsonHelper.getMap(json['product']) != null
          ? Product.fromJson(json['product'])
          : null,
      productModel: JsonHelper.getString(json['productModel']),
      category: JsonHelper.getString(json['category']),
      date: json['date'],
      time: json['time'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      personCount: json['personCount'],
      bookingStatus: JsonHelper.getString(json['bookingStatus']),
      totalPrice: JsonHelper.getDouble(json['totalPrice']),
      timeLabel: json['timeLabel'],
      bookingSeatCount: JsonHelper.getInt(json["bookingSeatCount"])
    );
  }
}

/// Product or service that was booked
class Product {
  final String id;
  final String title;
  final String thumbnail;
  final String? serviceArea;
  final String? description;
  final Category? category;

  Product({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.serviceArea,
    this.description,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: JsonHelper.getString(json['_id']),
      title: JsonHelper.getString(json['title']),
      thumbnail: JsonHelper.getString(json['thumbnail']),
      serviceArea: json['serviceArea'],
      description: json['description'],
      category: JsonHelper.getMap(json['category']) != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}

/// Product category model
class Category {
  final String id;
  final String name;
  final String categoryPhoto;

  Category({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: JsonHelper.getString(json['_id']),
      name: JsonHelper.getString(json['name']),
      categoryPhoto: JsonHelper.getString(json['categoryPhoto']),
    );
  }
}