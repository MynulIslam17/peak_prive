import 'dart:convert';
import '../../../../core/utils/json_helper.dart';

GetBalance getBalanceFromJson(String str) =>
    GetBalance.fromJson(json.decode(str));

String getBalanceToJson(GetBalance data) => json.encode(data.toJson());

class GetBalance {
  int code;
  String message;
  Data data;

  GetBalance({
    required this.code,
    required this.message,
    required this.data,
  });

  factory GetBalance.fromJson(Map<String, dynamic> json) => GetBalance(
    code: JsonHelper.getInt(json["code"]),
    message: JsonHelper.getString(json["message"]),
    data: Data.fromJson(JsonHelper.getMap(json["data"])),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String id;
  String user;
  int balance;
  int profitCharge;
  List<Transaction> transactions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int v;
  List<dynamic> walletAccounts;

  Data({
    required this.id,
    required this.user,
    required this.balance,
    required this.profitCharge,
    required this.transactions,
    this.createdAt,
    this.updatedAt,
    required this.v,
    required this.walletAccounts,
  });

  factory Data.fromJson(Map<String, dynamic>? json) {
    // Helper to safely parse int from dynamic
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Data(
      id: JsonHelper.getString(json?["_id"]),
      user: JsonHelper.getString(json?["user"]),
      balance: parseInt(json?["balance"]),
      profitCharge: parseInt(json?["profitCharge"]),
      transactions: JsonHelper.getList(json?["transactions"])
          .map((x) => Transaction.fromJson(x))
          .toList(),
      createdAt: json?["createdAt"] != null
          ? DateTime.tryParse(json!["createdAt"])
          : null,
      updatedAt: json?["updatedAt"] != null
          ? DateTime.tryParse(json!["updatedAt"])
          : null,
      v: JsonHelper.getInt(json?["__v"]),
      walletAccounts: JsonHelper.getList(json?["walletAccounts"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "balance": balance,
    "profitCharge": profitCharge,
    "transactions": transactions.map((x) => x.toJson()).toList(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "walletAccounts": walletAccounts,
  };
}

class Transaction {
  String user;
  int balance;
  Type type;
  DateTime? createdAt;

  Transaction({
    required this.user,
    required this.balance,
    required this.type,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Transaction(
      user: JsonHelper.getString(json["user"]),
      balance: parseInt(json["balance"]),
      type: typeValues.map[JsonHelper.getString(json["type"])] ?? Type.EARN,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "user": user,
    "balance": balance,
    "type": typeValues.reverse[type],
    "createdAt": createdAt?.toIso8601String(),
  };

  WalletFlowType get flow {
    switch (type) {
      case Type.WITHDRAW:
      case Type.SEND:
        return WalletFlowType.OUT;
      case Type.EARN:
      case Type.DEPOSIT:
      case Type.RECEIVE:
      default:
        return WalletFlowType.IN;
    }
  }

  String get typeName {
    switch (type) {
      case Type.WITHDRAW:
        return "Withdraw";
      case Type.SEND:
        return "Send";
      case Type.EARN:
        return "Earn";
      case Type.DEPOSIT:
        return "Deposit";
      case Type.RECEIVE:
        return "Receive";
      default:
        return "Transaction";
    }
  }
}

enum Type { EARN, WITHDRAW, DEPOSIT, SEND, RECEIVE }

final typeValues = EnumValues({
  "Earn": Type.EARN,
  "Withdraw": Type.WITHDRAW,
  "Deposit": Type.DEPOSIT,
  "Send": Type.SEND,
  "Receive": Type.RECEIVE,
});

enum WalletFlowType { IN, OUT }

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}