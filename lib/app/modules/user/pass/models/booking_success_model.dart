import 'dart:convert';
import '../../../../core/utils/json_helper.dart'; // path adjust করো

class TicketModel {
  final String ticketNumber;
  final String productId;
  final String productModel;
  final int personCount;
  final DateTime? date;
  final String time;
  final double totalPrice;

  TicketModel({
    required this.ticketNumber,
    required this.productId,
    required this.productModel,
    required this.personCount,
    required this.date,
    required this.time,
    required this.totalPrice,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final data = JsonHelper.getMap(json['data']) ?? {};

    // Date handling
    DateTime? parsedDate;
    if (data.containsKey('date') && data['date'] != null) {
      parsedDate = DateTime.tryParse(JsonHelper.getString(data['date']));
    } else if (data.containsKey('startDateAndTime') && data['startDateAndTime'] != null) {
      parsedDate = DateTime.tryParse(JsonHelper.getString(data['startDateAndTime']));
    }

    // Time handling (may be like TimeOfDay(06:31))
    String parsedTime = "";
    if (data.containsKey('time') && data['time'] != null) {
      parsedTime = JsonHelper.getString(data['time']).replaceAll("TimeOfDay(", "").replaceAll(")", "");
    }

    return TicketModel(
      ticketNumber: JsonHelper.getString(data['ticketNumber']),
      productId: JsonHelper.getString(data['product']),
      productModel: JsonHelper.getString(data['productModel']),
      personCount: JsonHelper.getInt(data['personCount']),
      date: parsedDate,
      time: parsedTime,
      totalPrice: JsonHelper.getDouble(data['totalPrice']),
    );
  }
}