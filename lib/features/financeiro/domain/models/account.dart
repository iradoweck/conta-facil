import 'package:uuid/uuid.dart';

enum AccountType { personal, business }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;

  Account({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      type: AccountType.values.byName(json['type']),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
