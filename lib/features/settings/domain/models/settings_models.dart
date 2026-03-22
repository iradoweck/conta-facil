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
  final String nickname;
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
    this.nickname = '',
    this.email = '',
    this.password = '',
    this.city = '',
    this.country = 'Moçambique',
    this.province = 'Maputo Cidade',
    this.phone = '',
    this.bio = 'O meu parceiro de crescimento',
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
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
    return UserProfile(
      name: json['name'] ?? 'Utilizador',
      nickname: json['nickname'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? 'Moçambique',
      province: json['province'] ?? 'Maputo Cidade',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? 'O meu parceiro de crescimento',
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

  UserSettings({
    this.minMonthlyBalanceBusiness = 0.0,
    this.minMonthlyBalancePersonal = 0.0,
    this.defaultIsBusiness = true,
    UserProfile? profile,
    this.goals = const [],
  }) : profile = profile ?? UserProfile();

  Map<String, dynamic> toJson() => {
    'minMonthlyBalanceBusiness': minMonthlyBalanceBusiness,
    'minMonthlyBalancePersonal': minMonthlyBalancePersonal,
    'defaultIsBusiness': defaultIsBusiness,
    'profile': profile.toJson(),
    'goals': goals.map((g) => g.toJson()).toList(),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      minMonthlyBalanceBusiness: (json['minMonthlyBalanceBusiness'] ?? json['minMonthlyBalance'] ?? 0.0).toDouble(),
      minMonthlyBalancePersonal: (json['minMonthlyBalancePersonal'] ?? 0.0).toDouble(),
      defaultIsBusiness: json['defaultIsBusiness'] ?? true,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      goals: json['goals'] != null 
        ? (json['goals'] as List).map((g) => FinancialGoal.fromJson(g)).toList()
        : [],
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
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      isBusiness: json['isBusiness'] ?? true,
    );
  }
}
