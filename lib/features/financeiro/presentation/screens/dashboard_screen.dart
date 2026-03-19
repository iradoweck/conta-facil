import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import '../../../fiscal/presentation/screens/tax_simulator_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../profile/presentation/screens/professional_profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final notifier = ref.read(transactionsProvider.notifier);
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN');

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
        onRefresh: () async => {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildBalanceCard(context, notifier, currencyFormat),
              const SizedBox(height: 16),
              _buildActionGrid(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Resumo do Mês'),
              _buildSummaryChart(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Transações Recentes'),
              _buildRecentTransactions(context, transactions, currencyFormat),
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

  Widget _buildBalanceCard(BuildContext context, TransactionNotifier notifier, NumberFormat fmt) {
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
            fmt.format(notifier.balance),
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
              _buildMiniBalance('Entradas', fmt.format(notifier.totalIncome), AppColors.success),
              _buildMiniBalance('Saídas', fmt.format(notifier.totalExpense), AppColors.alert),
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
      child: Row(
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

  Widget _buildSummaryChart(BuildContext context) {
    return Card(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: const Center(child: Text('Gráfico de Fluxo de Caixa (Placeholder)')),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<TransactionModel> transactions, NumberFormat fmt) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isIncome = t.type == TransactionType.income;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: (isIncome ? AppColors.success : AppColors.alert).withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.payments_outlined : Icons.shopping_bag_outlined,
              color: isIncome ? AppColors.success : AppColors.alert,
            ),
          ),
          title: Text(t.description),
          subtitle: Text(t.category),
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
  }
}
