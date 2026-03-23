import 'package:flutter/material.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/settings/domain/models/settings_models.dart';
import 'package:conta_facil/shared/models/finance_account.dart';

class ReportData {
  final double totalInflow;
  final double totalOutflow;
  final double netProfit;
  final Map<String, double> expensesByCategory;
  final List<Transaction> filteredTransactions;

  ReportData({
    required this.totalInflow,
    required this.totalOutflow,
    required this.netProfit,
    required this.expensesByCategory,
    required this.filteredTransactions,
  });
}

class ReportService {
  static ReportData calculateReport({
    required List<Transaction> allTransactions,
    required DateTimeRange range,
    String? categoryId,
    AccountType? accountType,
  }) {
    // 1. Filter transactions by date range and optional category/account
    final filtered = allTransactions.where((t) {
      final inRange = (t.date.isAfter(range.start) || t.date.isAtSameMomentAs(range.start)) && 
                      (t.date.isBefore(range.end) || t.date.isAtSameMomentAs(range.end));
      
      bool matchesCategory = true;
      if (categoryId != null && categoryId != 'all') {
        matchesCategory = t.category == categoryId;
      }

      bool matchesAccount = true;
      if (accountType != null) {
        final isBusinessTarget = accountType == AccountType.business;
        matchesAccount = t.isBusiness == isBusinessTarget;
      }

      return inRange && matchesCategory && matchesAccount;
    }).toList();

    // 2. Initial calculations
    double inflow = 0;
    double outflow = 0;
    final Map<String, double> byCategory = {};

    for (var t in filtered) {
      if (t.type == TransactionType.income) {
        inflow += t.amount;
      } else {
        outflow += t.amount;
        // Group expenses by category
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }

    return ReportData(
      totalInflow: inflow,
      totalOutflow: outflow,
      netProfit: inflow - outflow,
      expensesByCategory: byCategory,
      filteredTransactions: filtered,
    );
  }

  // Cash Flow Data Generation
  static Map<DateTime, double> getCashFlowData(List<Transaction> transactions) {
    final Map<DateTime, double> dailyData = {};
    for (var t in transactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      final val = t.type == TransactionType.income ? t.amount : -t.amount;
      dailyData[date] = (dailyData[date] ?? 0) + val;
    }
    return dailyData;
  }
}
