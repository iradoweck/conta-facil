import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _exportData(context, transactionsAsync.value ?? []),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final sales = transactions.where((t) => t.type == TransactionType.income).toList();
          
          if (sales.isEmpty) {
            return const Center(child: Text('Nenhuma venda registada para este relatório.'));
          }

          final totalSales = sales.fold(0.0, (sum, t) => sum + t.amount);

          return Column(
            children: [
              _buildSummaryHeader(context, sales.length, totalSales, currencyFormat),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final s = sales[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.success,
                          child: Icon(Icons.trending_up, color: Colors.white, size: 20),
                        ),
                        title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd/MM/yyyy • HH:mm').format(s.date)),
                        trailing: Text(
                          currencyFormat.format(s.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, int count, double total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      color: AppColors.success.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            'Total em Vendas',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(total),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.success),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('$count transações registadas', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, List<Transaction> transactions) {
    // Implementação básica de geração de CSV e cópia para clipboard
    final sales = transactions.where((t) => t.type == TransactionType.income).toList();
    if (sales.isEmpty) return;

    StringBuffer csv = StringBuffer();
    csv.writeln('Data,Titulo,Categoria,Valor');
    for (var s in sales) {
      csv.writeln('${DateFormat('yyyy-MM-dd').format(s.date)},${s.title},${s.category},${s.amount}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório gerado em formato CSV e pronto para partilha! (Simulado)'),
        backgroundColor: AppColors.success,
      ),
    );
    
    // Futuro: Usar share_plus para exportar o arquivo real
  }
}
