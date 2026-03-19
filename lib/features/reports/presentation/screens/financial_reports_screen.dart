import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: const Text('Relatórios Avançados'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'DRE'),
            Tab(text: 'Balanço'),
            Tab(text: 'Fluxo'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final reportStart = DateTime(_startDate.year, _startDate.month, _startDate.day);
                final reportEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
                
                final filtered = transactions.where((t) {
                  final inRange = !t.date.isBefore(reportStart) && !t.date.isAfter(reportEnd);
                  final inContext = _isBusiness == null || t.isBusiness == _isBusiness;
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
                  onChanged: (p) {
                    if (p == 'Personalizado') {
                      _selectCustomRange();
                    } else {
                      _setPreset(p!);
                    }
                  },
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
          if (_rangePreset == 'Personalizado')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'De ${DateFormat('dd/MM/yy').format(_startDate)} até ${DateFormat('dd/MM/yy').format(_endDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDREReport(List<Transaction> transactions, NumberFormat fmt) {
    final income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportRow('Receita Bruta (Entradas)', income, fmt, isHeader: true),
        _buildReportRow('(-) Custos e Despesas', -expense, fmt),
        const Divider(height: 32),
        _buildReportRow(
          'Resultado Líquido', 
          income - expense, 
          fmt, 
          isHeader: true, 
          color: (income - expense) >= 0 ? AppColors.success : AppColors.alert
        ),
        const SizedBox(height: 24),
        const Text('Detalhamento por Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._buildCategoryBreakdown(transactions, fmt),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(List<Transaction> transactions, NumberFormat fmt) {
    final categories = <String, double>{};
    for (var t in transactions) {
      categories[t.category] = (categories[t.category] ?? 0.0) + (t.type == TransactionType.income ? t.amount : -t.amount);
    }
    
    final sorted = categories.entries.toList()..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    
    return sorted.map((e) => _buildReportRow(e.key, e.value, fmt)).toList();
  }

  Widget _buildBalanceReport(List<Transaction> transactions, NumberFormat fmt) {
    final totalBalance = transactions.fold(0.0, (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportRow('Ativo (Disponibilidades)', totalBalance, fmt),
        _buildReportRow('Patrimônio Líquido', totalBalance, fmt),
        const Divider(),
        _buildReportRow('Passivo + PL', totalBalance, fmt, isHeader: true),
      ],
    );
  }

  Widget _buildCashFlowReport(List<Transaction> transactions, NumberFormat fmt) {
    // Agrupar por dia se range < 60 dias, senão por mês
    final diffDays = _endDate.difference(_startDate).inDays;
    final groupByDay = diffDays <= 60;

    final data = <String, double>{};
    for (var t in transactions) {
      final key = groupByDay 
          ? DateFormat('dd/MM').format(t.date)
          : DateFormat('MM/yyyy').format(t.date);
      final val = t.type == TransactionType.income ? t.amount : -t.amount;
      data[key] = (data[key] ?? 0.0) + val;
    }

    final sortedKeys = data.keys.toList(); // Simplificado: assumindo ordem natural ou cronológica

    if (data.isEmpty) {
      return const Center(child: Text('Sem movimentações no período.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final bal = data[key]!;
        return Card(
          child: ListTile(
            title: Text(key),
            trailing: Text(
              fmt.format(bal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bal >= 0 ? AppColors.success : AppColors.alert,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportRow(String label, double val, NumberFormat fmt, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
          Text(
            fmt.format(val),
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: color ?? (val < 0 ? AppColors.alert : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
