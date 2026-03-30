import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/core/utils/responsive_helper.dart';
import 'package:conta_facil/modules/auth/providers/auth_provider.dart';
import 'package:conta_facil/modules/dashboard/presentation/widgets/hero_balance_card.dart';
import 'package:conta_facil/modules/dashboard/presentation/widgets/quick_action_grid.dart';
import 'package:conta_facil/modules/dashboard/presentation/widgets/progress_ring_chart.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:conta_facil/modules/tools/fiscal/presentation/screens/tax_simulator_screen.dart';
import 'package:conta_facil/modules/intelligence/chat/presentation/screens/chat_screen.dart';
import 'package:conta_facil/modules/intelligence/portal/presentation/screens/edmilson_portal_screen.dart';
import 'package:conta_facil/modules/settings/presentation/screens/user_account_screen.dart';
import 'package:conta_facil/modules/tools/budget/presentation/screens/budget_simulator_screen.dart';
import 'package:conta_facil/modules/tools/fiscal/presentation/screens/fiscal_guide_screen.dart';
import 'package:conta_facil/modules/reports/presentation/screens/financial_reports_screen.dart';
import 'package:conta_facil/modules/reports/presentation/screens/analytics_screen.dart';
import 'package:conta_facil/modules/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:conta_facil/modules/settings/presentation/screens/settings_screen.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';
import 'package:conta_facil/modules/settings/presentation/screens/general_settings_screen.dart';
import 'package:conta_facil/modules/intelligence/education/presentation/screens/education_hub_screen.dart';
import 'package:conta_facil/modules/intelligence/education/domain/models/education_item.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);
    final isPro = ref.watch(subscriptionProvider) == SubscriptionPlan.pro;
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

    return Scaffold(
      appBar: null,
      body: RefreshIndicator(
        onRefresh: () async => ref.read(transactionsProvider.notifier).loadTransactions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildContextSwitcher(context, ref),
              const SizedBox(height: 16),
              _buildUpcomingAlerts(context, ref),
              const SizedBox(height: 16),
              
              // Adaptive Section: Balance & Summary Chart
              if (ResponsiveHelper.isTablet(context) || ResponsiveHelper.isLandscape(context))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: HeroBalanceCard(balance: balance, income: totalIncome, expense: totalExpense, currencyFormat: currencyFormat),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ProgressRingChart(income: totalIncome, expense: totalExpense),
                      ),
                    ],
                  ),
                )
              else ...[
                HeroBalanceCard(balance: balance, income: totalIncome, expense: totalExpense, currencyFormat: currencyFormat),
                const SizedBox(height: 16),
                ProgressRingChart(income: totalIncome, expense: totalExpense),
              ],
              
              const SizedBox(height: 16),
              _buildGoalProgressCard(context, ref, totalIncome, currencyFormat),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Ações Rápidas'),
              const SizedBox(height: 8),
              const QuickActionGrid(),
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onVerTudo}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title, 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
        ),
      ),
    );
  }

  Widget _buildUpcomingAlerts(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(fixedExpensesProvider);
    final filter = ref.watch(dashFilterProvider);
    final today = DateTime.now().day;

    final alerts = expenses.where((e) {
      if (filter != null && e.isBusiness != filter) return false;
      // Alert if due within 3 days or today
      final diff = e.dueDay - today;
      return diff >= 0 && diff <= 3;
    }).toList();

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notification_important_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Atenção às Contas!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.alert),
              ),
              const Spacer(),
              Text(
                '${alerts.length} Próximas',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.alert),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    e.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Vence dia ${e.dueDay}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )).toList(),
        ],
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
                    icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
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
              onTap: () {
                // Future Detail view
              },
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
