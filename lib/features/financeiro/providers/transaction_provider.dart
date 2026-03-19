import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/features/financeiro/data/repositories/transaction_repository.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/domain/models/account.dart';
import 'package:conta_facil/features/settings/domain/models/settings_models.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Filtro global para a Dashboard (Pessoal vs Negócio)
final dashFilterProvider = StateProvider<bool?>((ref) => true); // true: Negócio, false: Pessoal, null: Ambos

final transactionsProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.watch(transactionRepositoryProvider));
});

final accountsProvider = StateNotifierProvider<AccountNotifier, AsyncValue<List<Account>>>((ref) {
  return AccountNotifier(ref.watch(transactionRepositoryProvider));
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

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _repository.saveTransaction(transaction); // saveTransaction handles both exists/new in my repo logic
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

class AccountNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  final TransactionRepository _repository;

  AccountNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final accounts = await _repository.getAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAccount(Account account) async {
    final current = state.value ?? [];
    final updated = [...current, account];
    await _repository.saveAccounts(updated);
    state = AsyncValue.data(updated);
  }
}

// Provedores computados respeitando o filtro da Dashboard
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final filter = ref.watch(dashFilterProvider);
  
  return transactions
      .where((t) => (filter == null || t.isBusiness == filter))
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final filter = ref.watch(dashFilterProvider);
  
  return transactions
      .where((t) => (filter == null || t.isBusiness == filter))
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<CategoryItem>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return CategoriesNotifier(repository);
});

class CategoriesNotifier extends StateNotifier<List<CategoryItem>> {
  final TransactionRepository _repository;
  CategoriesNotifier(this._repository) : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await _repository.getCategories();
    if (categories.isEmpty) {
      final defaults = [
        CategoryItem(id: '1', name: 'Venda', isIncome: true, icon: Icons.sell_outlined),
        CategoryItem(id: '2', name: 'Serviço', isIncome: true, icon: Icons.work_outline),
        CategoryItem(id: '3', name: 'Aluguel', isIncome: false, icon: Icons.home_outlined),
        CategoryItem(id: '4', name: 'Salário', isIncome: false, icon: Icons.people_outline),
      ];
      state = defaults;
      await _repository.saveCategories(defaults);
    } else {
      state = categories;
    }
  }

  Future<void> addCategory(CategoryItem category) async {
    state = [...state, category];
    await _repository.saveCategories(state);
  }

  Future<void> updateCategory(CategoryItem category) async {
    state = [for (final c in state) if (c.id == category.id) category else c];
    await _repository.saveCategories(state);
  }

  Future<void> deleteCategory(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _repository.saveCategories(state);
  }
}

final fixedExpensesProvider = StateNotifierProvider<FixedExpensesNotifier, List<FixedExpense>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return FixedExpensesNotifier(repository);
});

class FixedExpensesNotifier extends StateNotifier<List<FixedExpense>> {
  final TransactionRepository _repository;
  FixedExpensesNotifier(this._repository) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = await _repository.getFixedExpenses();
  }

  Future<void> addExpense(FixedExpense expense) async {
    state = [...state, expense];
    await _repository.saveFixedExpenses(state);
  }

  Future<void> updateExpense(FixedExpense expense) async {
    state = [for (final e in state) if (e.id == expense.id) expense else e];
    await _repository.saveFixedExpenses(state);
  }

  Future<void> deleteExpense(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _repository.saveFixedExpenses(state);
  }
}
