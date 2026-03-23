import '../services/report_service.dart';

class FinancialInsight {
  final String title;
  final String message;
  final bool isWarning;

  FinancialInsight({
    required this.title,
    required this.message,
    this.isWarning = false,
  });
}

class InsightEngine {
  static List<FinancialInsight> generateInsights(ReportData data, Map<String, String> categoryNames) {
    List<FinancialInsight> insights = [];

    // 1. Profit/Loss Insight
    if (data.netProfit < 0) {
      insights.add(FinancialInsight(
        title: 'Atenção ao Saldo',
        message: 'Suas despesas superaram suas receitas neste período. Tente identificar gastos não essenciais.',
        isWarning: true,
      ));
    } else if (data.netProfit > 0 && data.totalInflow > 0) {
      final margin = (data.netProfit / data.totalInflow) * 100;
      if (margin > 30) {
        insights.add(FinancialInsight(
          title: 'Excelente Margem!',
          message: 'Você reteve ${margin.toStringAsFixed(1)}% do que ganhou. Continue assim!',
        ));
      }
    }

    // 2. Category Concentration
    if (data.totalOutflow > 0) {
      data.expensesByCategory.forEach((catId, amount) {
        final percentage = (amount / data.totalOutflow) * 100;
        if (percentage > 40) {
          final name = categoryNames[catId] ?? 'Desconhecida';
          insights.add(FinancialInsight(
            title: 'Alta Concentração',
            message: 'A categoria "$name" representa ${percentage.toStringAsFixed(1)}% das suas despesas totais.',
            isWarning: true,
          ));
        }
      });
    }

    // 3. General Positivity
    if (insights.isEmpty && data.totalInflow > 0) {
      insights.add(FinancialInsight(
        title: 'Tudo Sob Controlo',
        message: 'Suas finanças parecem equilibradas neste período. Mantenha os seus registos atualizados.',
      ));
    }

    return insights;
  }
}
