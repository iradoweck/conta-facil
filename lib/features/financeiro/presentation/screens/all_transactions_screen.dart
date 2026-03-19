import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

import 'package:conta_facil/features/financeiro/presentation/screens/add_transaction_screen.dart';

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  String _searchQuery = '';
  bool? _filterBusiness; // null = Ambos

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

    return Scaffold(
      appBar: AppBar(title: const Text('Todas as Transações')),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions.where((t) {
                  final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                       t.category.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesFilter = _filterBusiness == null || t.isBusiness == _filterBusiness;
                  return matchesSearch && matchesFilter;
                }).toList()..sort((a, b) => b.date.compareTo(a.date));

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhuma transação encontrada.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildTransactionTile(filtered[index], currencyFormat),
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

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Pesquisar por título ou categoria...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _filterChip('Ambos', null),
              const SizedBox(width: 8),
              _filterChip('Negócio', true),
              const SizedBox(width: 8),
              _filterChip('Pessoal', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterBusiness == value,
      onSelected: (selected) => setState(() => _filterBusiness = value),
    );
  }

  Widget _buildTransactionTile(Transaction t, NumberFormat fmt) {
    final isIncome = t.type == TransactionType.income;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isIncome ? AppColors.success : AppColors.alert).withOpacity(0.1),
          child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? AppColors.success : AppColors.alert),
        ),
        title: Text(t.title),
        subtitle: Text('${t.category} • ${DateFormat('dd/MM/yyyy').format(t.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              fmt.format(t.amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.success : AppColors.alert),
            ),
            PopupMenuButton(
              onSelected: (val) {
                if (val == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: t)));
                } else if (val == 'delete') {
                  _showDeleteConfirm(context, ref, t.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Transação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(transactionsProvider.notifier).deleteTransaction(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
