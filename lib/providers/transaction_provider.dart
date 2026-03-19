import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction_model.dart';

// Provedor para a lista de transações
final transactionsProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  double get totalIncome => state
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => state
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;
}
