import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final bool isIncome;
  final IconData icon;

  CategoryItem({
    required this.id,
    required this.name,
    required this.isIncome,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isIncome': isIncome,
    'icon': icon.codePoint,
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      name: json['name'],
      isIncome: json['isIncome'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

class FixedExpense {
  final String id;
  final String title;
  final double amount;
  final int dueDay;

  FixedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDay': dueDay,
  };

  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['dueDay'],
    );
  }
}

class UserSettings {
  final double minMonthlyBalance;
  final bool defaultIsBusiness;

  UserSettings({
    this.minMonthlyBalance = 0.0,
    this.defaultIsBusiness = true,
  });

  Map<String, dynamic> toJson() => {
    'minMonthlyBalance': minMonthlyBalance,
    'defaultIsBusiness': defaultIsBusiness,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      minMonthlyBalance: (json['minMonthlyBalance'] as num).toDouble(),
      defaultIsBusiness: json['defaultIsBusiness'] ?? true,
    );
  }
}
