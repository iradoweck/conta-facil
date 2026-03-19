import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/domain/models/account.dart';
import 'package:conta_facil/features/settings/domain/models/settings_models.dart';

class TransactionRepository {
  static const String _storageKey = 'transactions_list';
  static const String _accountsKey = 'accounts_list';
  static const String _settingsKey = 'user_settings';
  static const String _categoriesKey = 'categories_list';
  static const String _fixedExpensesKey = 'fixed_expenses';

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

  // --- Account Management ---

  Future<List<Account>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_accountsKey);
    
    if (encodedData == null) {
      // Inicializar com contas padrão se vazio
      final defaults = [
        Account(name: 'Principal Negócio', type: AccountType.business),
        Account(name: 'Pessoal Dinheiro', type: AccountType.personal),
      ];
      await saveAccounts(defaults);
      return defaults;
    }
    
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Account.fromJson(item)).toList();
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      accounts.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_accountsKey, encodedData);
  }

  // --- Settings & Fixed Expenses ---

  // --- Settings & Fixed Expenses ---

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_settingsKey);
    if (encodedData == null) return UserSettings();
    final Map<String, dynamic> decodedData = json.decode(encodedData);
    return UserSettings.fromJson(decodedData);
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }

  // --- Categories ---

  Future<List<CategoryItem>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_categoriesKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => CategoryItem.fromJson(item)).toList();
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, json.encode(categories.map((c) => c.toJson()).toList()));
  }

  // --- Fixed Expenses ---

  Future<List<FixedExpense>> getFixedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_fixedExpensesKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => FixedExpense.fromJson(item)).toList();
  }

  Future<void> saveFixedExpenses(List<FixedExpense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fixedExpensesKey, json.encode(expenses.map((e) => e.toJson()).toList()));
  }
}
