import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/core/utils/responsive_helper.dart';
import 'package:conta_facil/modules/reports/domain/engines/time_filter_engine.dart';
import 'package:conta_facil/modules/reports/domain/services/report_service.dart';
import 'package:conta_facil/modules/reports/domain/engines/insight_engine.dart';
import 'package:conta_facil/shared/models/finance_account.dart';
import 'package:conta_facil/modules/settings/domain/models/settings_models.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';
import 'package:conta_facil/shared/utils/pro_gate_helper.dart';
import 'package:conta_facil/modules/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:conta_facil/modules/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:conta_facil/modules/reports/presentation/screens/financial_reports_screen.dart';
import 'package:conta_facil/modules/intelligence/portal/presentation/screens/edmilson_portal_screen.dart';
import 'package:conta_facil/modules/settings/presentation/screens/settings_screen.dart';
import 'package:conta_facil/core/presentation/screens/main_screen.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  TimeFilter _timeFilter = TimeFilter.monthly;
  DateTimeRange? _customRange;
  AccountType? _accountTypeFilter = AccountType.business;

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: TimeFilterEngine.getRange(_timeFilter),
    );
    if (picked != null) {
      setState(() {
        _timeFilter = TimeFilter.custom;
        _customRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settings = ref.watch(userSettingsProvider); // From transaction_provider.dart
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');
    final isPro = ref.watch(subscriptionProvider) == SubscriptionPlan.pro;

    return Scaffold(
      appBar: AppBar(title: const Text('Estudo das minhas Finanças')),
      body: Column(
        children: [
          _buildFilters(isPro),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final range = TimeFilterEngine.getRange(_timeFilter, customRange: _customRange);
                final reportData = ReportService.calculateReport(
                  allTransactions: transactions,
                  range: range,
                  accountType: _accountTypeFilter,
                );

                if (reportData.filteredTransactions.isEmpty) {
                  return const Center(child: Text('Nenhuma transação no período.'));
                }

                final categories = categoriesAsync; 
                final categoryNames = {for (var c in categories) c.id: c.name};
                final insights = InsightEngine.generateInsights(reportData, categoryNames);

                final isLargeScreen = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isLandscape(context);
                
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildQuickSummary(reportData, currencyFormat),
                    const SizedBox(height: 24),
                    if (insights.isNotEmpty) ...[
                      _buildInsightsSection(insights),
                      const SizedBox(height: 24),
                    ],
                    if (isLargeScreen) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCategoryDistribution(reportData, categoryNames, currencyFormat)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPerformanceAudit(reportData, currencyFormat)),
                        ],
                      ),
                    ] else ...[
                      _buildCategoryDistribution(reportData, categoryNames, currencyFormat),
                      const SizedBox(height: 24),
                      _buildPerformanceAudit(reportData, currencyFormat),
                    ],
                    const SizedBox(height: 24),
                    _buildFixedExpensesImpact(reportData, settings, currencyFormat),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // Relatórios
          onTap: (index) {
            if (index != 2) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_outlined), label: 'Transações'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'IA / Portal'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isPro) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<TimeFilter>(
              isExpanded: true,
              value: _timeFilter,
              decoration: const InputDecoration(labelText: 'Período', border: OutlineInputBorder()),
              items: TimeFilter.values.map((f) => DropdownMenuItem(
                value: f, 
                child: Row(
                  children: [
                    Text(TimeFilterEngine.getFilterLabel(f)),
                    if (f == TimeFilter.custom && !isPro) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                    ],
                  ],
                )
              )).toList(),
              onChanged: (f) {
                if (f == TimeFilter.custom && !isPro) {
                  ProGateHelper.showUpgradeDialog(context, 'Período Personalizado');
                  return;
                }
                f == TimeFilter.custom ? _selectCustomRange() : setState(() => _timeFilter = f!);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<AccountType?>(
              isExpanded: true,
              value: _accountTypeFilter,
              decoration: const InputDecoration(labelText: 'Contexto', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: AccountType.business, child: Text('Negócio')),
                const DropdownMenuItem(value: AccountType.personal, child: Text('Pessoal')),
                DropdownMenuItem(value: null, child: Row(
                  children: [
                    const Text('Ambos'),
                    if (!isPro) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                    ],
                  ],
                )),
              ],
              onChanged: (val) {
                if (val == null && !isPro) {
                  ProGateHelper.showUpgradeDialog(context, 'Filtro Combinado (Ambos)');
                  return;
                }
                setState(() => _accountTypeFilter = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(ReportData data, NumberFormat fmt) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Entradas', data.totalInflow, AppColors.success, fmt)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Saídas', data.totalOutflow, AppColors.alert, fmt)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Saldo', data.netProfit, data.netProfit >= 0 ? AppColors.primary : AppColors.alert, fmt)),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color, NumberFormat fmt) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            FittedBox(child: Text(fmt.format(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(List<FinancialInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Insights do seu Parceiro AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: insight.isWarning ? Colors.orange.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: insight.isWarning ? Colors.orange.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(insight.isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline, color: insight.isWarning ? Colors.orange : AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(insight.message, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildCategoryDistribution(ReportData data, Map<String, String> categoryNames, NumberFormat fmt) {
    if (data.expensesByCategory.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribuição de Gastos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...data.expensesByCategory.entries.map((e) {
              final pct = (data.totalOutflow > 0) ? (e.value / data.totalOutflow) * 100 : 0.0;
              final name = categoryNames[e.key] ?? 'Outros';
              return Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('$name (${pct.toStringAsFixed(0)}%)'),
                       Text(fmt.format(e.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   LinearProgressIndicator(
                     value: (data.totalOutflow > 0) ? e.value / data.totalOutflow : 0.0, 
                     color: AppColors.alert, 
                     backgroundColor: Colors.grey[200]
                   ),
                   const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceAudit(ReportData data, NumberFormat fmt) {
    final profit = data.netProfit;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Análise de Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Icon(
              profit >= 0 ? Icons.trending_up : Icons.trending_down, 
              size: 48, 
              color: profit >= 0 ? AppColors.success : AppColors.alert
            ),
            const SizedBox(height: 12),
            Text(
              profit >= 0 ? 'Operação Lucrativa' : 'Atenção: Operação com Déficit',
              style: TextStyle(fontWeight: FontWeight.bold, color: profit >= 0 ? AppColors.success : AppColors.alert),
            ),
            const SizedBox(height: 8),
            Text(
              'No período selecionado, obteve um saldo de ${fmt.format(profit.abs())}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedExpensesImpact(ReportData data, UserSettings settings, NumberFormat fmt) {
    double minBalance = 0;
    String contextLabel = "";

    if (_accountTypeFilter == AccountType.business) {
      minBalance = settings.minMonthlyBalanceBusiness;
      contextLabel = "Negócio";
    } else if (_accountTypeFilter == AccountType.personal) {
      minBalance = settings.minMonthlyBalancePersonal;
      contextLabel = "Pessoal";
    } else {
      minBalance = settings.minMonthlyBalanceBusiness + settings.minMonthlyBalancePersonal;
      contextLabel = "Total";
    }
    
    if (minBalance <= 0) return const SizedBox.shrink();

    final progress = (data.totalInflow / minBalance).clamp(0.0, 1.0);

    return Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
       color: AppColors.primary,
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Progresso vs Meta de Reserva ($contextLabel)', style: const TextStyle(color: Colors.white70, fontSize: 13)),
             const SizedBox(height: 8),
             Text(fmt.format(minBalance), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.white),
             const SizedBox(height: 16),
             Text(
               progress >= 1.0 
                  ? 'Parabéns! Atingiu a reserva mínima $contextLabel com as entradas do período.'
                  : 'Faltam ${fmt.format(minBalance - data.totalInflow)} para atingir o saldo mínimo seguro em $contextLabel.', 
               style: const TextStyle(color: Colors.white70, fontSize: 11)
             ),
           ],
         ),
       ),
    );
  }
}
