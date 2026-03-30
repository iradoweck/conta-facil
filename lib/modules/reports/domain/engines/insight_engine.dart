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
        title: '⚠️ Atenção ao Saldo',
        message: 'Parceiro, as despesas venceram as receitas. Vamos analisar onde o dinheiro está a "fugir"? Reduzir pequenos custos agora garante o fôlego de amanhã.',
        isWarning: true,
      ));
    } else if (data.netProfit > 0 && data.totalInflow > 0) {
      final margin = (data.netProfit / data.totalInflow) * 100;
      if (margin > 30) {
        insights.add(FinancialInsight(
          title: '🚀 Excelente Margem!',
          message: 'Estás a reter ${margin.toStringAsFixed(1)}% de lucro! Isso é gestão de elite. Que tal reinvestir uma parte em TI ou marketing?',
        ));
      } else {
        insights.add(FinancialInsight(
          title: '✅ Operação Positiva',
          message: 'O negócio está a respirar! Com uma margem de ${margin.toStringAsFixed(1)}%, o foco agora é escala ou otimização de processos.',
        ));
      }
    }

    // 2. Category Concentration
    if (data.totalOutflow > 0) {
      data.expensesByCategory.forEach((catId, amount) {
        final percentage = (amount / data.totalOutflow) * 100;
        if (percentage > 40) {
          final name = categoryNames[catId] ?? 'Outros';
          insights.add(FinancialInsight(
            title: '🔍 Alerta de Concentração',
            message: 'A categoria "$name" está a engolir ${percentage.toStringAsFixed(1)}% do teu orçamento. Vale a pena renegociar com fornecedores?',
            isWarning: true,
          ));
        }
      });
    }

    // 3. Specific Tips (e.g. Savings or Tax)
    if (data.totalInflow > 50000) {
      insights.add(FinancialInsight(
        title: '🇲🇿 Dica Fiscal',
        message: 'Com este volume, garante que o teu ISPC está em dia. A conformidade é o primeiro passo para contratos maiores.',
      ));
    }

    // 4. General Positivity
    if (insights.isEmpty && data.totalInflow > 0) {
      insights.add(FinancialInsight(
        title: '💪 Tudo Sob Controlo',
        message: 'As tuas finanças estão equilibradas. Continua a registar tudo para mantermos esta clareza!',
      ));
    }

    return insights;
  }
}
