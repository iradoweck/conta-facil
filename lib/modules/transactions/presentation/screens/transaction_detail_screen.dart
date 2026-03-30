import 'package:flutter/material.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.alert;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Transação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Edit can be accessed via AddTransactionScreen
              Navigator.pop(context, 'edit');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome ? Icons.add_circle : Icons.remove_circle,
                    size: 64,
                    color: color,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  currencyFormat.format(transaction.amount),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transaction.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(transaction.isBusiness ? 'Negócio' : 'Pessoal'),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildDetailRow('Categoria', transaction.category, Icons.category_outlined),
          const Divider(height: 32),
          _buildDetailRow('Data', DateFormat('dd MMMM yyyy, HH:mm').format(transaction.date), Icons.calendar_today_outlined),
          const Divider(height: 32),
          _buildDetailRow('Tipo', isIncome ? 'Entrada (Receita)' : 'Saída (Despesa)', Icons.swap_vert_outlined),
          const Divider(height: 32),
          _buildDetailRow('ID da Transação', transaction.id.substring(0, 8), Icons.fingerprint_outlined),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'delete'),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Eliminar Transação', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
