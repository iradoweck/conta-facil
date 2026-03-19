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
import 'package:conta_facil/features/profile/presentation/screens/budget_simulator_screen.dart';
import 'package:conta_facil/features/fiscal/presentation/screens/fiscal_guide_screen.dart';
import 'package:conta_facil/features/reports/presentation/screens/financial_reports_screen.dart';
import 'package:conta_facil/features/reports/presentation/screens/analytics_screen.dart';
import 'package:conta_facil/features/financeiro/presentation/screens/all_transactions_screen.dart';
import 'package:conta_facil/features/settings/presentation/screens/settings_screen.dart';
import 'package:conta_facil/features/education/presentation/screens/education_hub_screen.dart';
import 'package:conta_facil/features/education/domain/models/education_item.dart';

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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
              const SizedBox(height: 16),
              _buildContextSwitcher(context, ref),
              const SizedBox(height: 16),
              _buildBalanceCard(context, balance, totalIncome, totalExpense, currencyFormat),
              const SizedBox(height: 16),
              _buildGoalProgressCard(context, ref, totalIncome, currencyFormat),
              const SizedBox(height: 16),
              _buildActionGrid(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Resumo do Mês', onVerTudo: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
              }),
              _buildSummaryChart(context, totalIncome, totalExpense),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Transações Recentes', onVerTudo: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllTransactionsScreen()));
              }),
              _buildRecentTransactions(context, transactionsAsync, currencyFormat, ref),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Sabedoria do Edmilson & IA'),
              _buildEducationPreview(context),
              const SizedBox(height: 40),
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

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onVerTudo}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          if (onVerTudo != null)
            TextButton(
              onPressed: onVerTudo,
              child: const Text('Ver Tudo'),
            ),
        ],
      ),
    );
  }

  Widget _buildContextSwitcher(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashFilterProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<bool?>(
        segments: const [
          ButtonSegment(value: true, label: Text('Negócio'), icon: Icon(Icons.business_center)),
          ButtonSegment(value: false, label: Text('Pessoal'), icon: Icon(Icons.person)),
          ButtonSegment(value: null, label: Text('Ambos'), icon: Icon(Icons.all_inclusive)),
        ],
        selected: {filter},
        onSelectionChanged: (newSelection) {
          ref.read(dashFilterProvider.notifier).state = newSelection.first;
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white,
          selectedBackgroundColor: AppColors.primary.withOpacity(0.1),
          selectedForegroundColor: AppColors.primary,
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, double income, double expense, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              _buildActionButton(context, Icons.chat_bubble_outline, 'Parceiro AI', AppColors.primary, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, Icons.assessment_outlined, 'Relatório', Colors.blue, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinancialReportsScreen()));
              }),
              _buildActionButton(context, Icons.description_outlined, 'Orçamento', Colors.deepPurple, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetSimulatorScreen()));
              }),
              _buildActionButton(context, Icons.person_outline, 'Perfil', Colors.blueGrey, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfessionalProfileScreen()));
              }),
              _buildActionButton(context, Icons.menu_book_outlined, 'Guia', Colors.orange, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FiscalGuideScreen()));
              }),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeWidth * 100).toInt(),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                        ),
                      ),
                      child: const Center(child: Icon(Icons.trending_up, color: Colors.white, size: 14)),
                    ),
                  ),
                  Expanded(
                    flex: ((1 - incomeWidth) * 100).toInt(),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.alert, AppColors.alert.withOpacity(0.8)],
                        ),
                      ),
                      child: const Center(child: Icon(Icons.trending_down, color: Colors.white, size: 14)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Entradas', AppColors.success),
                _buildLegendItem('Saídas', AppColors.alert),
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
    final filter = ref.watch(dashFilterProvider);
    return transactionsAsync.when(
      data: (transactions) {
        final filtered = transactions.where((t) => (filter == null || t.isBusiness == filter)).toList();
        
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Ainda não começamos? Vamos registar o primeiro\nganho ou gasto juntos!', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final sorted = List<Transaction>.from(filtered)..sort((a, b) => b.date.compareTo(a.date));
        final recent = sorted.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final t = recent[index];
            final isIncome = t.type == TransactionType.income;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (isIncome ? AppColors.success : AppColors.alert).withOpacity(0.1),
                child: Icon(
                  isIncome ? Icons.payments_outlined : Icons.shopping_bag_outlined,
                  color: isIncome ? AppColors.success : AppColors.alert,
                ),
              ),
              title: Text(t.title),
              subtitle: Text('${t.category} • ${DateFormat('dd/MM').format(t.date)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${fmt.format(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppColors.success : AppColors.alert,
                    ),
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar: $e')),
    );
  }

  Widget _buildEducationPreview(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: mockEducationData.map((item) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildEducationItem(context, item),
        )).toList(),
      ),
    );
  }

  Widget _buildEducationItem(BuildContext context, EducationItem item) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EducationHubScreen())),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: item.color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: item.color, size: 24),
            const SizedBox(height: 12),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(BuildContext context, WidgetRef ref, double income, NumberFormat fmt) {
    final settings = ref.watch(userSettingsProvider);
    final filter = ref.watch(dashFilterProvider);
    
    double target = 0;
    String contextLabel = "";

    if (filter == true) {
      target = settings.minMonthlyBalanceBusiness;
      contextLabel = "Negócio";
    } else if (filter == false) {
      target = settings.minMonthlyBalancePersonal;
      contextLabel = "Pessoal";
    } else {
      target = settings.minMonthlyBalanceBusiness + settings.minMonthlyBalancePersonal;
      contextLabel = "Total";
    }
    
    if (target <= 0) return const SizedBox.shrink();

    final progress = (income / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    
    String message = "Vamos começar a faturar?";
    Color progressColor = Colors.grey;

    if (progress >= 1.0) {
      message = "Meta $contextLabel Batida! 🏆 Orgulho!";
      progressColor = AppColors.success;
    } else if (progress >= 0.7) {
      message = "Quase lá! Falta pouco para a meta $contextLabel! 🚀";
      progressColor = Colors.orange;
    } else if (progress >= 0.3) {
      message = "Bom ritmo no $contextLabel! Força parceiro!";
      progressColor = AppColors.primary;
    } else if (progress > 0) {
      message = "Primeiros passos rumo à meta $contextLabel!";
      progressColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta $contextLabel: ${fmt.format(target)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
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
