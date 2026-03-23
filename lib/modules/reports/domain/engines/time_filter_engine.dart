import 'package:flutter/material.dart';

enum TimeFilter {
  last7Days,
  weekly,
  monthly,
  quarterly,
  yearly,
  allTime,
  custom
}

class TimeFilterEngine {
  static DateTimeRange getRange(TimeFilter filter, {DateTimeRange? customRange}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case TimeFilter.last7Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: now,
        );
      case TimeFilter.weekly:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
          start: startOfWeek,
          end: now,
        );
      case TimeFilter.monthly:
        final startOfMonth = DateTime(today.year, today.month, 1);
        return DateTimeRange(
          start: startOfMonth,
          end: now,
        );
      case TimeFilter.quarterly:
        final quarter = ((today.month - 1) / 3).floor();
        final startOfQuarter = DateTime(today.year, (quarter * 3) + 1, 1);
        return DateTimeRange(
          start: startOfQuarter,
          end: now,
        );
      case TimeFilter.yearly:
        final startOfYear = DateTime(today.year, 1, 1);
        return DateTimeRange(
          start: startOfYear,
          end: now,
        );
      case TimeFilter.allTime:
        return DateTimeRange(
          start: DateTime(2000), // Far past
          end: now,
        );
      case TimeFilter.custom:
        return customRange ?? DateTimeRange(start: today, end: now);
    }
  }

  static String getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.last7Days: return 'Últimos 7 dias';
      case TimeFilter.weekly: return 'Esta Semana';
      case TimeFilter.monthly: return 'Este Mês';
      case TimeFilter.quarterly: return 'Este Trimestre';
      case TimeFilter.yearly: return 'Este Ano';
      case TimeFilter.allTime: return 'Todo o Tempo';
      case TimeFilter.custom: return 'Personalizado';
    }
  }
}
