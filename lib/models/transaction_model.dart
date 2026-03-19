import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String? accountId;

  TransactionModel({
    String? id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.accountId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type.name,
      'accountId': accountId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: TransactionType.values.byName(map['type']),
      accountId: map['accountId'],
    );
  }
}
