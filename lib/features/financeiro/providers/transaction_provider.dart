import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/features/financeiro/data/repositories/transaction_repository.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/settings/domain/models/settings_models.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Filtro global para a Dashboard (Pessoal vs Negócio)
final dashFilterProvider = StateProvider<bool?>((ref) => true); // true: Negócio, false: Pessoal, null: Ambos

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

  Future<void> updateTransaction(Transaction transaction) async {
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

final accountsProvider = StateNotifierProvider<AccountsNotifier, List<FinanceAccount>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AccountsNotifier(repository);
});

class AccountsNotifier extends StateNotifier<List<FinanceAccount>> {
  final TransactionRepository _repository;
  AccountsNotifier(this._repository) : super([]) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final accounts = await _repository.getAccounts();
    if (accounts.isEmpty) {
      final defaults = [
        FinanceAccount(id: 'cash-b', name: 'Dinheiro (Negócio)', icon: Icons.money, isBusiness: true),
        FinanceAccount(id: 'bank-b', name: 'Banco (Negócio)', icon: Icons.account_balance, isBusiness: true),
        FinanceAccount(id: 'cash-p', name: 'Dinheiro (Pessoal)', icon: Icons.money, isBusiness: false),
        FinanceAccount(id: 'mpesa-p', name: 'M-Pesa (Pessoal)', icon: Icons.phone_android, isBusiness: false),
      ];
      state = defaults;
      await _repository.saveAccounts(defaults);
    } else {
      state = accounts;
    }
  }

  Future<void> addAccount(FinanceAccount account) async {
    state = [...state, account];
    await _repository.saveAccounts(state);
  }

  Future<void> updateAccount(FinanceAccount account) async {
    state = [for (final a in state) if (a.id == account.id) account else a];
    await _repository.saveAccounts(state);
  }

  Future<void> deleteAccount(String id) async {
    state = state.where((a) => a.id != id).toList();
    await _repository.saveAccounts(state);
  }
}

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

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return UserSettingsNotifier(repository);
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final TransactionRepository _repository;
  UserSettingsNotifier(this._repository) : super(UserSettings(profile: UserProfile())) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = await _repository.getSettings();
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = settings;
    await _repository.saveSettings(settings);
  }

  Future<void> addGoal(FinancialGoal goal) async {
    final newSettings = UserSettings(
      minMonthlyBalanceBusiness: state.minMonthlyBalanceBusiness,
      minMonthlyBalancePersonal: state.minMonthlyBalancePersonal,
      defaultIsBusiness: state.defaultIsBusiness,
      profile: state.profile,
      goals: [...state.goals, goal],
    );
    await updateSettings(newSettings);
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    final newSettings = UserSettings(
      minMonthlyBalanceBusiness: state.minMonthlyBalanceBusiness,
      minMonthlyBalancePersonal: state.minMonthlyBalancePersonal,
      defaultIsBusiness: state.defaultIsBusiness,
      profile: state.profile,
      goals: [for (final g in state.goals) if (g.id == goal.id) goal else g],
    );
    await updateSettings(newSettings);
  }

  Future<void> deleteGoal(String id) async {
    final newSettings = UserSettings(
      minMonthlyBalanceBusiness: state.minMonthlyBalanceBusiness,
      minMonthlyBalancePersonal: state.minMonthlyBalancePersonal,
      defaultIsBusiness: state.defaultIsBusiness,
      profile: state.profile,
      goals: state.goals.where((g) => g.id != id).toList(),
    );
    await updateSettings(newSettings);
  }
}

// Computed providers
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).asData?.value ?? [];
  final filter = ref.watch(dashFilterProvider);
  return transactions
      .where((t) => (filter == null || t.isBusiness == filter))
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).asData?.value ?? [];
  final filter = ref.watch(dashFilterProvider);
  return transactions
      .where((t) => (filter == null || t.isBusiness == filter))
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});
