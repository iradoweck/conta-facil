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
      icon: getSafeIcon(json['icon']),
    );
  }
}

class FixedExpense {
  final String id;
  final String title;
  final double amount;
  final int dueDay;
  final bool isBusiness;

  FixedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.isBusiness = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDay': dueDay,
    'isBusiness': isBusiness,
  };

  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['dueDay'],
      isBusiness: json['isBusiness'] ?? true,
    );
  }
}

class UserProfile {
  final String name;
  final String surname;
  final String email;
  final String password;
  final String city;
  final String country;
  final String province;
  final String phone;
  final String bio;
  final String? photoPath;

  UserProfile({
    this.name = 'Utilizador',
    this.surname = '',
    this.email = '',
    this.password = '',
    this.city = '',
    this.country = 'Moçambique',
    this.province = 'Maputo Cidade',
    this.phone = '',
    String bio = 'O meu parceiro de crescimento',
    this.photoPath,
  }) : bio = bio.length > 120 ? bio.substring(0, 120) : bio;

  Map<String, dynamic> toJson() => {
    'name': name,
    'surname': surname,
    'email': email,
    'password': password,
    'city': city,
    'country': country,
    'province': province,
    'phone': phone,
    'bio': bio,
    'photoPath': photoPath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawBio = json['bio'] ?? 'O meu parceiro de crescimento';
    return UserProfile(
      name: json['name'] ?? 'Utilizador',
      surname: json['surname'] ?? json['nickname'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? 'Moçambique',
      province: json['province'] ?? 'Maputo Cidade',
      phone: json['phone'] ?? '',
      bio: rawBio.length > 120 ? rawBio.substring(0, 120) : rawBio,
      photoPath: json['photoPath'],
    );
  }
}

class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  final DateTime? deadline;
  final bool isBusiness;
  final String? category; // Optional: associated category for tracking

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.deadline,
    this.isBusiness = true,
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'deadline': deadline?.toIso8601String(),
    'isBusiness': isBusiness,
    'category': category,
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isBusiness: json['isBusiness'] ?? true,
      category: json['category'],
    );
  }
}

class UserSettings {
  final double minMonthlyBalanceBusiness;
  final double minMonthlyBalancePersonal;
  final bool defaultIsBusiness;
  final UserProfile profile;
  final List<FinancialGoal> goals;
  final ThemeMode themeMode;
  final String currency;

  UserSettings({
    this.minMonthlyBalanceBusiness = 0.0,
    this.minMonthlyBalancePersonal = 0.0,
    this.defaultIsBusiness = true,
    UserProfile? profile,
    this.goals = const [],
    this.themeMode = ThemeMode.system,
    this.currency = 'MZN',
  }) : profile = profile ?? UserProfile();

  Map<String, dynamic> toJson() => {
    'minMonthlyBalanceBusiness': minMonthlyBalanceBusiness,
    'minMonthlyBalancePersonal': minMonthlyBalancePersonal,
    'defaultIsBusiness': defaultIsBusiness,
    'profile': profile.toJson(),
    'goals': goals.map((g) => g.toJson()).toList(),
    'themeMode': themeMode.index,
    'currency': currency,
  };

  UserSettings copyWith({
    double? minMonthlyBalanceBusiness,
    double? minMonthlyBalancePersonal,
    bool? defaultIsBusiness,
    UserProfile? profile,
    List<FinancialGoal>? goals,
    ThemeMode? themeMode,
    String? currency,
  }) {
    return UserSettings(
      minMonthlyBalanceBusiness: minMonthlyBalanceBusiness ?? this.minMonthlyBalanceBusiness,
      minMonthlyBalancePersonal: minMonthlyBalancePersonal ?? this.minMonthlyBalancePersonal,
      defaultIsBusiness: defaultIsBusiness ?? this.defaultIsBusiness,
      profile: profile ?? this.profile,
      goals: goals ?? this.goals,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      minMonthlyBalanceBusiness: (json['minMonthlyBalanceBusiness'] ?? json['minMonthlyBalance'] ?? 0.0).toDouble(),
      minMonthlyBalancePersonal: (json['minMonthlyBalancePersonal'] ?? 0.0).toDouble(),
      defaultIsBusiness: json['defaultIsBusiness'] ?? true,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      goals: json['goals'] != null 
        ? (json['goals'] as List).map((g) => FinancialGoal.fromJson(g)).toList()
        : [],
      themeMode: json['themeMode'] != null ? ThemeMode.values[json['themeMode']] : ThemeMode.system,
      currency: json['currency'] ?? 'MZN',
    );
  }
}
class FinanceAccount {
  final String id;
  final String name;
  final IconData icon;
  final bool isBusiness;

  FinanceAccount({
    required this.id,
    required this.name,
    required this.icon,
    this.isBusiness = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'isBusiness': isBusiness,
  };

  factory FinanceAccount.fromJson(Map<String, dynamic> json) {
    return FinanceAccount(
      id: json['id'],
      name: json['name'],
      icon: getSafeIcon(json['icon']),
      isBusiness: json['isBusiness'] ?? true,
    );
  }
}

IconData getSafeIcon(dynamic codePoint) {
  if (codePoint == null) return Icons.account_balance_wallet_outlined;
  
  // Safe mapping of commonly used icons to strictly constant IconData
  // Prevents Dart2JS 'Avoid non-constant invocations of IconData' Web Compiler crashes
  if (codePoint == Icons.money.codePoint) return Icons.money;
  if (codePoint == Icons.account_balance.codePoint) return Icons.account_balance;
  if (codePoint == Icons.phone_android.codePoint) return Icons.phone_android;
  if (codePoint == Icons.shopping_bag_outlined.codePoint) return Icons.shopping_bag_outlined;
  if (codePoint == Icons.receipt_long_outlined.codePoint) return Icons.receipt_long_outlined;
  if (codePoint == Icons.home_outlined.codePoint) return Icons.home_outlined;
  if (codePoint == Icons.restaurant_outlined.codePoint) return Icons.restaurant_outlined;
  if (codePoint == Icons.directions_car_outlined.codePoint) return Icons.directions_car_outlined;
  if (codePoint == Icons.medical_services_outlined.codePoint) return Icons.medical_services_outlined;
  if (codePoint == Icons.school_outlined.codePoint) return Icons.school_outlined;
  if (codePoint == Icons.category_outlined.codePoint) return Icons.category_outlined;
  if (codePoint == Icons.business_center.codePoint) return Icons.business_center;
  
  return Icons.account_balance_wallet_outlined; // Strict Safe Fallback
}
