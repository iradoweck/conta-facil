import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

import 'package:conta_facil/modules/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';
import 'package:conta_facil/modules/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:conta_facil/shared/utils/pro_gate_helper.dart';

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

    final isPro = ref.watch(subscriptionProvider) == SubscriptionPlan.pro;

    return Scaffold(
      appBar: AppBar(title: const Text('Todas as Transações')),
      body: Column(
        children: [
          _buildSearchAndFilters(isPro),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions.where((t) {
                  final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                       t.category.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesFilter = _filterBusiness == null 
                                       ? (isPro ? true : t.isBusiness == true) // Default to Business for Free
                                       : t.isBusiness == _filterBusiness;
                  return matchesSearch && matchesFilter;
                }).toList()..sort((a, b) => b.date.compareTo(a.date));

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhuma transação encontrada.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildTransactionTile(filtered[index], currencyFormat, isPro),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isPro) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Ambos', null, isPro),
                const SizedBox(width: 8),
                _filterChip('Negócio', true, isPro),
                const SizedBox(width: 8),
                _filterChip('Pessoal', false, isPro),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool? value, bool isPro) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterBusiness == value,
      onSelected: (selected) {
        if (value == null && !isPro) {
          ProGateHelper.showUpgradeDialog(context, 'Filtro Combinado (Ambos)');
          return;
        }
        setState(() => _filterBusiness = value);
      },
      avatar: (value == null && !isPro) ? const Icon(Icons.lock_outline, size: 14) : null,
    );
  }

  Widget _buildTransactionTile(Transaction t, NumberFormat fmt, bool isPro) {
    final isIncome = t.type == TransactionType.income;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () {
          if (isPro) {
            _navToDetail(t);
          } else {
             ProGateHelper.showUpgradeDialog(context, 'Detalhes da Transação');
          }
        },
        leading: CircleAvatar(
          backgroundColor: (isIncome ? AppColors.success : AppColors.alert).withOpacity(0.1),
          child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? AppColors.success : AppColors.alert),
        ),
        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${t.category} • ${DateFormat('dd/MM/yyyy').format(t.date)}', style: const TextStyle(fontSize: 12)),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                fmt.format(t.amount),
                style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.success : AppColors.alert),
              ),
              const SizedBox(width: 4),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'details') {
                    if (isPro) {
                      _navToDetail(t);
                    } else {
                       ProGateHelper.showUpgradeDialog(context, 'Detalhes da Transação');
                    }
                  } else if (val == 'edit') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: t)));
                  } else if (val == 'delete') {
                    _showDeleteConfirm(context, ref, t.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'details', 
                    child: Row(
                      children: [
                        const Text('Ver Detalhes'),
                        if (!isPro) ...[const SizedBox(width: 8), const Icon(Icons.lock_outline, size: 14, color: Colors.grey)],
                      ],
                    )
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navToDetail(Transaction t) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: t)),
    );
    if (result == 'edit') {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: t)));
    } else if (result == 'delete') {
      if (!mounted) return;
      _showDeleteConfirm(context, ref, t.id);
    }
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
