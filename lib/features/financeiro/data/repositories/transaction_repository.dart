import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';

class TransactionRepository {
  static const String _storageKey = 'transactions_list';

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);
    
    if (encodedData == null) return [];
    
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Transaction.fromJson(item)).toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveAll(transactions);
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await _saveAll(transactions);
  }

  Future<void> _saveAll(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }
}
