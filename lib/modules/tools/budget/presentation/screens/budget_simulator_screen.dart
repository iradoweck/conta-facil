import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/shared/components/fintech_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BudgetSimulatorScreen extends StatefulWidget {
  const BudgetSimulatorScreen({super.key});

  @override
  State<BudgetSimulatorScreen> createState() => _BudgetSimulatorScreenState();
}

class _BudgetSimulatorScreenState extends State<BudgetSimulatorScreen> {
  final _incomeController = TextEditingController(text: '10000');
  double _income = 10000;
  final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _updateIncome() {
    final text = _incomeController.text.replaceAll(',', '.');
    setState(() {
      _income = double.tryParse(text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Simulador de Orçamento (50/30/20)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            const Text('Teu Rendimento Mensal Líquido:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'MT ',
                filled: true,
                fillColor: AppColors.primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (_) => _updateIncome(),
            ),
            const SizedBox(height: 32),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildRuleBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.pie_chart_outline, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
             child: Text(
               'A regra 50/30/20 é uma fórmula de sucesso mundial recomendada pelo Edmilson para equilibrar tua vida financeira e da tua empresa.',
               style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, height: 1.4, fontSize: 13),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (_income <= 0) {
      return const Center(child: Text('Insira um valor válido para projetar o orçamento.'));
    }

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: AppColors.primary,
                  value: 50,
                  title: '50%',
                  radius: 30,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: AppColors.accent,
                  value: 30,
                  title: '30%',
                  radius: 25,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: AppColors.success,
                  value: 20,
                  title: '20%',
                  radius: 20,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Orçamento Ideal', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(_income),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRuleBreakdown() {
    if (_income <= 0) return const SizedBox.shrink();

    final needs = _income * 0.5;
    final wants = _income * 0.3;
    final savings = _income * 0.2;

    return Column(
      children: [
        _buildBreakdownItem('Necessidades Básicas (50%)', 'Rendas, salários, energia, alimentação.', needs, AppColors.primary),
        _buildBreakdownItem('Desejos / Variáveis (30%)', 'Marketing extra, jantares, melhorias.', wants, AppColors.accent),
        _buildBreakdownItem('Poupanças & Dívidas (20%)', 'Fundo de emergência, quitação bancária.', savings, AppColors.success),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, String desc, double amount, Color color) {
    return FintechCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
