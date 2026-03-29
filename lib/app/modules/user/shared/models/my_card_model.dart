import '../../../../core/utils/json_helper.dart';

class MyCardsModel {
  final int code;
  final String message;
  final Data data;

  MyCardsModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MyCardsModel.fromJson(Map<String, dynamic> json) {
    return MyCardsModel(
      code: JsonHelper.getInt(json['code']),
      message: JsonHelper.getString(json['message']),
      data: Data.fromJson(JsonHelper.getMap(json['data']) ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data.toJson(),
  };
}

class Data {
  final String id;
  final String user;
  final double balance;
  final double profitCharge;
  final List<WalletAccount> walletAccounts;
  final List<WalletAccount> sortedAccounts;
  final String createdAt;
  final String updatedAt;

  Data({
    required this.id,
    required this.user,
    required this.balance,
    required this.profitCharge,
    required this.walletAccounts,
    required this.sortedAccounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var walletAccountsList = JsonHelper.getList(json['walletAccounts'])
        .map((e) => WalletAccount.fromJson(JsonHelper.getMap(e) ?? {}))
        .toList();

    var sortedAccountsList = JsonHelper.getList(json['sortedAccounts'])
        .map((e) => WalletAccount.fromJson(JsonHelper.getMap(e) ?? {}))
        .toList();

    return Data(
      id: JsonHelper.getString(json['_id']),
      user: JsonHelper.getString(json['user']),
      balance: JsonHelper.getDouble(json['balance']),
      profitCharge: JsonHelper.getDouble(json['profitCharge']),
      walletAccounts: walletAccountsList,
      sortedAccounts: sortedAccountsList,
      createdAt: JsonHelper.getString(json['createdAt']),
      updatedAt: JsonHelper.getString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user,
    'balance': balance,
    'profitCharge': profitCharge,
    'walletAccounts': walletAccounts.map((e) => e.toJson()).toList(),
    'sortedAccounts': sortedAccounts.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class WalletAccount {
  final String accountType;
  final String cardHolderName;
  final String id;
  final String createdAt;
  final String cardNumber;

  WalletAccount({
    required this.accountType,
    required this.cardHolderName,
    required this.id,
    required this.createdAt,
    required this.cardNumber,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      accountType: JsonHelper.getString(json['accountType']),
      cardHolderName: JsonHelper.getString(json['cardHolderName']),
      id: JsonHelper.getString(json['_id']),
      createdAt: JsonHelper.getString(json['createdAt']),
      cardNumber: JsonHelper.getString(json['cardNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
    'accountType': accountType,
    'cardHolderName': cardHolderName,
    '_id': id,
    'createdAt': createdAt,
    'cardNumber': cardNumber,
  };
}