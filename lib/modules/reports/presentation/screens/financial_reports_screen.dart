import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:conta_facil/shared/components/fintech_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';

class FinancialReportsScreen extends ConsumerStatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  ConsumerState<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends ConsumerState<FinancialReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String _rangePreset = 'Este Mês';
  bool? _isBusiness = true; // true: Negócio, false: Pessoal, null: Ambos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _setPreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _rangePreset = preset;
      switch (preset) {
        case '7 Dias':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 'Este Mês':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case '3 Meses':
          _startDate = now.subtract(const Duration(days: 90));
          _endDate = now;
          break;
        case '1 Ano':
          _startDate = now.subtract(const Duration(days: 365));
          _endDate = now;
          break;
        case '3 Anos':
          _startDate = now.subtract(const Duration(days: 365 * 3));
          _endDate = now;
          break;
      }
    });
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _rangePreset = 'Personalizado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inteligência Contábil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'DRE'),
            Tab(text: 'Balanço'),
            Tab(text: 'Fluxo (Trends)'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildContextSegment(),
          _buildTimeCarousel(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final reportStart = DateTime(_startDate.year, _startDate.month, _startDate.day);
                final reportEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
                
                final filtered = transactions.where((t) {
                  final inRange = !t.date.isBefore(reportStart) && !t.date.isAfter(reportEnd);
                  final inContext = _isBusiness == null ? true : (t.isBusiness == _isBusiness);
                  return inRange && inContext;
                }).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDREReport(filtered, currencyFormat),
                    _buildBalanceReport(filtered, currencyFormat),
                    _buildCashFlowReport(filtered, currencyFormat),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextSegment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<bool?>(
        segments: const [
          ButtonSegment(value: true, label: Text('Negócio')),
          ButtonSegment(value: false, label: Text('Pessoal')),
          ButtonSegment(value: null, label: Text('Ambos')),
        ],
        selected: {_isBusiness},
        onSelectionChanged: (Set<bool?> selection) {
          setState(() {
            _isBusiness = selection.first;
          });
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white,
          selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
          selectedForegroundColor: AppColors.primary,
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _buildTimeCarousel() {
    final presets = ['7 Dias', 'Este Mês', '3 Meses', '1 Ano', 'Personalizado'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final preset = presets[index];
          final isSelected = _rangePreset == preset;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(preset, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black87),
              onSelected: (selected) {
                if (preset == 'Personalizado') {
                  _selectCustomRange();
                } else {
                  _setPreset(preset);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDREReport(List<Transaction> transactions, NumberFormat fmt) {
    if (transactions.isEmpty) return _buildEmptyState();

    final income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    final net = income - expense;
    final margin = income > 0 ? (net / income) * 100 : 0.0;
    final isPro = ref.watch(subscriptionProvider) == SubscriptionPlan.pro;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FintechCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Demonstração de Resultados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildDREItem('Receita Operacional Bruta', income, fmt, isHeader: true, prefixColor: AppColors.success),
              const Divider(height: 24),
              _buildDREItem('(-) Custos e Despesas', -expense, fmt, isHeader: false, prefixColor: AppColors.alert),
              const Divider(height: 24),
              _buildDREItem(
                'Lucro Líquido (Bottom Line)', 
                net, 
                fmt, 
                isHeader: true, 
                valueColor: net >= 0 ? AppColors.success : AppColors.alert
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Margem de Lucro: ${margin.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('  Análise de Custos por Categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        if (isPro)
          ..._buildCategoryBreakdown(transactions, fmt)
        else
          _buildProRestrictionCard('Análise de Categorias detalhada'),
      ],
    );
  }

  Widget _buildDREItem(String label, double value, NumberFormat fmt, {bool isHeader = false, Color? valueColor, Color? prefixColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (prefixColor != null) ...[
                 Container(width: 4, height: 16, decoration: BoxDecoration(color: prefixColor, borderRadius: BorderRadius.circular(2))),
                 const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label, 
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.w500, 
                    color: isHeader ? Colors.black87 : Colors.black54
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          fmt.format(value),
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (value < 0 ? AppColors.alert : Colors.black87),
            fontSize: isHeader ? 16 : 14,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(List<Transaction> transactions, NumberFormat fmt) {
    final categories = <String, double>{};
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
         categories[t.category] = (categories[t.category] ?? 0.0) + t.amount;
      }
    }
    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((e) => FintechCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(fmt.format(e.value), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.alert)),
        ],
      )
    )).toList();
  }

  Widget _buildBalanceReport(List<Transaction> transactions, NumberFormat fmt) {
    if (transactions.isEmpty) return _buildEmptyState();

    final totalBalance = transactions.fold(0.0, (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FintechCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Balanço Patrimonial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildDREItem('Ativo (Disponibilidades)', totalBalance, fmt),
              const Divider(height: 24),
              _buildDREItem('Passivos', 0.0, fmt), // Future: hook up with fixed obligations
              const Divider(height: 24),
              _buildDREItem('Patrimônio Líquido', totalBalance, fmt, isHeader: true, valueColor: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashFlowReport(List<Transaction> transactions, NumberFormat fmt) {
    if (transactions.isEmpty) return _buildEmptyState();

    // Group by day for the chart
    final diffDays = _endDate.difference(_startDate).inDays;
    if (diffDays == 0) return const Center(child: Text('Selecione um período maior para ver tendências.'));

    final Map<int, double> dailyNet = {};
    for (var t in transactions) {
      final dayDiff = t.date.difference(_startDate).inDays;
      if (dayDiff >= 0 && dayDiff <= diffDays) {
        final val = t.type == TransactionType.income ? t.amount : -t.amount;
        dailyNet[dayDiff] = (dailyNet[dayDiff] ?? 0.0) + val;
      }
    }

    final List<FlSpot> spots = [];
    double cumulative = 0.0;
    
    for (int i = 0; i <= diffDays; i++) {
      cumulative += dailyNet[i] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), cumulative));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FintechCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trend de Fluxo de Caixa (Acumulado)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(fmt.format(cumulative), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cumulative >= 0 ? AppColors.success : AppColors.alert)),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: diffDays.toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: cumulative >= 0 ? AppColors.success : AppColors.alert,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (cumulative >= 0 ? AppColors.success : AppColors.alert).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('  O gráfico reflete a evolução do saldo ao longo do período filtrado.', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Nenhuma transação no período selecionado.', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildProRestrictionCard(String featureName) {
    return FintechCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: Colors.grey, size: 40),
          const SizedBox(height: 16),
          Text(
            featureName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta funcionalidade está disponível apenas para membros PRO.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vá para Perfil > Configurações para fazer o Upgrade!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Saiba Mais'),
          ),
        ],
      ),
    );
  }
}
