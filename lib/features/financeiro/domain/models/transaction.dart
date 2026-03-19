import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? accountId;
  final bool isBusiness;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.accountId,
    this.isBusiness = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'category': category,
      'accountId': accountId,
      'isBusiness': isBusiness,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.byName(json['type']),
      category: json['category'],
      accountId: json['accountId'],
      isBusiness: json['isBusiness'] ?? true,
    );
  }

  Transaction copyWith({
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? category,
    String? accountId,
    bool? isBusiness,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      isBusiness: isBusiness ?? this.isBusiness,
    );
  }
}
