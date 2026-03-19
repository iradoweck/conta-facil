import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/features/auth/providers/auth_provider.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'add_transaction_screen.dart';
import 'package:conta_facil/features/fiscal/presentation/screens/tax_simulator_screen.dart';
import 'package:conta_facil/features/chat/presentation/screens/chat_screen.dart';
import 'package:conta_facil/features/profile/presentation/screens/professional_profile_screen.dart';
import 'package:conta_facil/features/reports/presentation/screens/sales_report_screen.dart';
import 'package:conta_facil/features/profile/presentation/screens/budget_simulator_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta Fácil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfessionalProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(transactionsProvider.notifier).loadTransactions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildBalanceCard(context, balance, totalIncome, totalExpense, currencyFormat),
              const SizedBox(height: 16),
              _buildActionGrid(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Resumo do Mês'),
              _buildSummaryChart(context, totalIncome, totalExpense),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Transações Recentes'),
              _buildRecentTransactions(context, transactionsAsync, currencyFormat, ref),
            ],
          ),
        ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          TextButton(onPressed: () {}, child: const Text('Ver tudo')),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, double income, double expense, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Total',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniBalance('Entradas', fmt.format(income), AppColors.success),
              _buildMiniBalance('Saídas', fmt.format(expense), AppColors.alert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalance(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              label == 'Entradas' ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, Icons.add_circle_outline, 'Entrada', AppColors.success, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialType: TransactionType.income)));
              }),
              _buildActionButton(context, Icons.remove_circle_outline, 'Saída', AppColors.alert, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialType: TransactionType.expense)));
              }),
              _buildActionButton(context, Icons.calculate_outlined, 'Fiscal', AppColors.warning, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxSimulatorScreen()));
              }),
              _buildActionButton(context, Icons.chat_bubble_outline, 'Chat', AppColors.primary, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, Icons.assessment_outlined, 'Relatório', Colors.blue, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalesReportScreen()));
              }),
              _buildActionButton(context, Icons.description_outlined, 'Orçamento', Colors.deepPurple, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetSimulatorScreen()));
              }),
              _buildActionButton(context, Icons.person_outline, 'Perfil', Colors.blueGrey, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfessionalProfileScreen()));
              }),
              const SizedBox(width: 80), // Placeholder to keep grid alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSummaryChart(BuildContext context, double income, double expense) {
    final total = income + expense;
    final incomeWidth = total > 0 ? (income / total) : 0.5;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distribuição Real', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  income >= expense ? 'Lucrativo' : 'Atenção',
                  style: TextStyle(
                    color: income >= expense ? AppColors.success : AppColors.alert,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeWidth * 100).toInt(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ((1 - incomeWidth) * 100).toInt(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.alert,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Vendas', AppColors.success),
                _buildLegendItem('Custos', AppColors.alert),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AsyncValue<List<Transaction>> transactionsAsync, NumberFormat fmt, WidgetRef ref) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma transação ainda.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        final sorted = List<Transaction>.from(transactions)..sort((a, b) => b.date.compareTo(a.date));
        final recent = sorted.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final t = recent[index];
            final isIncome = t.type == TransactionType.income;
            
            return ListTile(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Transação?'),
                    content: const Text('Esta ação não pode ser desfeita.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          ref.read(transactionsProvider.notifier).deleteTransaction(t.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: (isIncome ? AppColors.success : AppColors.alert).withOpacity(0.1),
                child: Icon(
                  isIncome ? Icons.payments_outlined : Icons.shopping_bag_outlined,
                  color: isIncome ? AppColors.success : AppColors.alert,
                ),
              ),
              title: Text(t.title),
              subtitle: Text('${t.category} • ${DateFormat('dd/MM').format(t.date)}'),
              trailing: Text(
                '${isIncome ? '+' : '-'} ${fmt.format(t.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.success : AppColors.alert,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar: $e')),
    );
  }
}
