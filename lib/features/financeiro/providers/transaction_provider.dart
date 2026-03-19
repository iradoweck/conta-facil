import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/models/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.watch(transactionRepositoryProvider));
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.saveTransaction(transaction);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provedores computados para o Dashboard
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});
