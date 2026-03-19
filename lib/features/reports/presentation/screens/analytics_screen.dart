import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String _rangePreset = 'Este Mês';
  bool? _isBusiness = true;

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
      appBar: AppBar(title: const Text('Estudo das minhas Finanças')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions.where((t) {
                  final inRange = t.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) && 
                                 t.date.isBefore(_endDate.add(const Duration(days: 1)));
                  final inContext = _isBusiness == null || t.isBusiness == _isBusiness;
                  return inRange && inContext;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhuma transação no período.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCategoryDistribution(filtered, currencyFormat),
                    const SizedBox(height: 24),
                    _buildMonthlyTrends(filtered, currencyFormat),
                    const SizedBox(height: 24),
                    _buildFixedExpensesImpact(filtered, currencyFormat),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _rangePreset,
                  decoration: const InputDecoration(labelText: 'Período', border: OutlineInputBorder()),
                  items: ['7 Dias', 'Este Mês', '3 Meses', '1 Ano', '3 Anos', 'Personalizado']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (p) => p == 'Personalizado' ? _selectCustomRange() : _setPreset(p!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<bool?>(
                  value: _isBusiness,
                  decoration: const InputDecoration(labelText: 'Contexto', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Negócio')),
                    DropdownMenuItem(value: false, child: Text('Pessoal')),
                    DropdownMenuItem(value: null, child: Text('Ambos')),
                  ],
                  onChanged: (val) => setState(() => _isBusiness = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(List<Transaction> transactions, NumberFormat fmt) {
    final expenseMap = <String, double>{};
    for (var t in transactions.where((t) => t.type == TransactionType.expense)) {
      expenseMap[t.category] = (expenseMap[t.category] ?? 0.0) + t.amount;
    }

    if (expenseMap.isEmpty) return const SizedBox.shrink();

    final total = expenseMap.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribuição de Gastos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...expenseMap.entries.map((e) {
              final pct = (e.value / total) * 100;
              return Column(
                children: [
                   _buildIndicator(e.key, e.value, fmt, pct),
                   const SizedBox(height: 8),
                   LinearProgressIndicator(value: e.value / total, color: AppColors.alert, backgroundColor: Colors.grey[200]),
                   const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label,double value, NumberFormat fmt, double pct) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label (${pct.toStringAsFixed(0)}%)'),
        Text(fmt.format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMonthlyTrends(List<Transaction> transactions, NumberFormat fmt) {
    final income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    final profit = income - expense;

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

  Widget _buildFixedExpensesImpact(List<Transaction> transactions, NumberFormat fmt) {
    // Aqui usaríamos o minBalance que está nas configurações (mockado por enquanto)
    const minBalance = 5000.0;
    final totalIncome = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final progress = (totalIncome / minBalance).clamp(0.0, 1.0);

    return Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
       color: AppColors.primary,
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text('Progresso vs Meta de Reserva', style: TextStyle(color: Colors.white70, fontSize: 13)),
             const SizedBox(height: 8),
             Text(fmt.format(minBalance), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.white),
             const SizedBox(height: 8),
             Text(
               progress >= 1.0 
                  ? 'Parabéns! Atingiu a reserva mínima com as entradas do período.'
                  : 'Faltam ${fmt.format(minBalance - totalIncome)} para atingir o saldo mínimo seguro.', 
               style: const TextStyle(color: Colors.white70, fontSize: 11)
             ),
           ],
         ),
       ),
    );
  }
}
