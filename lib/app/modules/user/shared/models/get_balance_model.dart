// To parse this JSON data, do
//
//     final getBalance = getBalanceFromJson(jsonString);

import 'dart:convert';

GetBalance getBalanceFromJson(String str) =>
    GetBalance.fromJson(json.decode(str));

String getBalanceToJson(GetBalance data) => json.encode(data.toJson());

class GetBalance {
  int? code;
  String? message;
  Data? data;

  GetBalance({
    this.code,
    this.message,
    this.data,
  });

  factory GetBalance.fromJson(Map<String, dynamic> json) => GetBalance(
    code: json["code"],
    message: json["message"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? user;
  int? balance;
  int? profitCharge;
  List<Transaction>? transactions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  List<dynamic>? walletAccounts;

  Data({
    this.id,
    this.user,
    this.balance,
    this.profitCharge,
    this.transactions,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.walletAccounts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    user: json["user"],
    balance: json["balance"],
    profitCharge: json["profitCharge"],
    transactions: json["transactions"] != null
        ? List<Transaction>.from(
        json["transactions"].map((x) => Transaction.fromJson(x)))
        : [],
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
    v: json["__v"],
    walletAccounts: json["walletAccounts"] ?? [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "balance": balance,
    "profitCharge": profitCharge,
    "transactions": transactions?.map((x) => x.toJson()).toList(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "walletAccounts": walletAccounts,
  };
}

class Transaction {
  String? user;
  int? balance;
  Type? type;
  DateTime? createdAt;

  Transaction({
    this.user,
    this.balance,
    this.type,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    user: json["user"],
    balance: json["balance"],
    type: json["type"] != null ? typeValues.map[json["type"]] : null,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "user": user,
    "balance": balance,
    "type": type != null ? typeValues.reverse[type] : null,
    "createdAt": createdAt?.toIso8601String(),
  };

  /// Determine if transaction is money coming in or going out
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

  /// Human-readable type name for UI
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
