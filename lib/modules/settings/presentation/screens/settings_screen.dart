import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/settings/domain/models/settings_models.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:conta_facil/modules/intelligence/portal/presentation/screens/edmilson_portal_screen.dart';
import 'package:conta_facil/modules/settings/presentation/screens/personal_details_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';
import 'package:conta_facil/modules/intelligence/chat/presentation/screens/chat_screen.dart';
import 'package:conta_facil/shared/utils/pro_gate_helper.dart';
import 'package:conta_facil/shared/utils/icon_picker_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _goalTitleController = TextEditingController();
  final _goalAmountController = TextEditingController();

  @override
  void dispose() {
    _goalTitleController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);
    final fixedExpenses = ref.watch(fixedExpensesProvider);
    final isPro = ref.watch(subscriptionProvider) == SubscriptionPlan.pro;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(settings.profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('👤 Informações Gerais'),
                  _buildQuickInfoCard(context, settings.profile),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('💰 Gestão Financeira'),
                  _buildFinanceModule(settings, accounts, categories, fixedExpenses, isPro),
                  const SizedBox(height: 32),

                  _buildSectionTitle('🎯 Metas e Reservas'),
                  _buildGoalsModule(settings.goals),
                  const SizedBox(height: 32),

                  _buildSectionTitle('⚙️ Preferências do App'),
                  _buildPreferencesModule(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(UserProfile profile) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Meu Perfil',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF001F3F)],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'profile-avatar',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${profile.name} ${profile.surname}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      profile.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.blueGrey[800],
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Dados Pessoais',
            subtitle: 'Nome, Email, Telefone, Localização...',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
            ),
          ),
          Divider(height: 1, indent: 64, color: Colors.grey[100]),
          _buildSettingsTile(
            icon: Icons.auto_awesome_outlined,
            title: 'Portal do Edmilson',
            subtitle: 'Seu parceiro financeiro digital',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceModule(
    UserSettings settings,
    List<FinanceAccount> accounts,
    List<CategoryItem> categories,
    List<FixedExpense> fixedExpenses,
    bool isPro,
  ) {
    return Column(
      children: [
        _buildModuleExpansion(
          title: 'Gestão de Contas',
          subtitle: '${accounts.length} contas configuradas',
          icon: Icons.account_balance_outlined,
          child: _buildAccountList(accounts, isPro),
        ),
        const SizedBox(height: 12),
        _buildModuleExpansion(
          title: 'Categorias de Transações',
          subtitle: 'Organize suas entradas e saídas',
          icon: Icons.category_outlined,
          child: Column(
            children: [
              _buildCategorySublist('Entradas', categories.where((c) => c.isIncome).toList(), true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              _buildCategorySublist('Saídas', categories.where((c) => !c.isIncome).toList(), false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildModuleExpansion(
          title: 'Despesas Fixas',
          subtitle: 'Compromissos mensais recorrentes',
          icon: Icons.event_repeat_outlined,
          child: _buildFixedExpensesList(fixedExpenses),
        ),
      ],
    );
  }

  Widget _buildGoalsModule(List<FinancialGoal> goals) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.track_changes, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma meta definida ainda',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 64, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (goal.isBusiness ? AppColors.primary : AppColors.accent).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      goal.isBusiness ? Icons.business_center_outlined : Icons.person_outline,
                      color: goal.isBusiness ? AppColors.primary : AppColors.accent,
                      size: 20,
                    ),
                  ),
                  title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Meta: ${NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT').format(goal.targetAmount)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => ref.read(userSettingsProvider.notifier).deleteGoal(goal.id),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showGoalDialog(),
              icon: const Icon(Icons.add_task),
              label: const Text('Nova Meta Financeira'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleExpansion({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [child],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildAccountList(List<FinanceAccount> accounts, bool isPro) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final acc = accounts[index];
            return ListTile(
              dense: true,
              leading: Icon(acc.icon, color: AppColors.accent, size: 20),
              title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(acc.isBusiness ? 'Conta Negócio' : 'Conta Pessoal'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => ref.read(accountsProvider.notifier).deleteAccount(acc.id),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (accounts.length < 2 || isPro) 
          TextButton.icon(
            onPressed: () => _showAccountDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Conta'),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                _showUpgradeProDialog();
              },
              icon: const Icon(Icons.workspace_premium, color: Colors.amber),
              label: const Text('Adicionar Ilímitadas (PRO)', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySublist(String title, List<CategoryItem> items, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items.map((cat) => Chip(
              label: Text(cat.name, style: const TextStyle(fontSize: 12)),
              avatar: Icon(cat.icon, size: 14, color: AppColors.primary),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              onDeleted: () => ref.read(categoriesProvider.notifier).deleteCategory(cat.id),
              deleteIconColor: Colors.red[300],
            )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: AppColors.primary,
              onPressed: () => _showCategoryDialog(isIncome: isIncome),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesModule() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Modo Noturno (Dark/Light)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            subtitle: const Text('Muda o design do app', style: TextStyle(fontSize: 11)),
            secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
            value: false, // Dummy
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          Divider(height: 1, indent: 56, color: Colors.grey[100]),
          SwitchListTile(
            title: const Text('Moeda Padrão', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            subtitle: const Text('Exibir MZN em todos os relatórios', style: TextStyle(fontSize: 11)),
            secondary: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
            value: true, // Dummy
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          Divider(height: 1, indent: 56, color: Colors.grey[100]),
          _buildSettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notificações',
            subtitle: 'Alertas de tributos e vencimentos',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFixedExpensesList(List<FixedExpense> expenses) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final e = expenses[index];
            return ListTile(
              dense: true,
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('Dia ${e.dueDay} • ${NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT').format(e.amount)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => ref.read(fixedExpensesProvider.notifier).deleteExpense(e.id),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showFixedExpenseDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Despesa Fixa'),
        ),
      ],
    );
  }

  // --- Dialogs ---

  void _showGoalDialog() {
    final isPro = ref.read(subscriptionProvider) == SubscriptionPlan.pro;
    final goalsCount = ref.read(userSettingsProvider).goals.length;
    
    if (!isPro && goalsCount >= 3) {
      ProGateHelper.showUpgradeDialog(context, 'Mais de 3 Metas Financeiras');
      return;
    }

    bool isBusiness = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎯 Nova Meta Financeira'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalTitleController,
                decoration: const InputDecoration(labelText: 'Descrição da Meta (ex: Fundo Emergência)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor Alvo (MT)', border: OutlineInputBorder(), prefixText: 'MT '),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Meta de Negócio?'),
                subtitle: Text(isBusiness ? 'Empresarial' : 'Pessoal'),
                value: isBusiness,
                activeColor: AppColors.primary,
                onChanged: (val) => setDialogState(() => isBusiness = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (_goalTitleController.text.isNotEmpty && _goalAmountController.text.isNotEmpty) {
                  final goal = FinancialGoal(
                    id: const Uuid().v4(),
                    title: _goalTitleController.text,
                    targetAmount: double.tryParse(_goalAmountController.text) ?? 0.0,
                    isBusiness: isBusiness,
                    deadline: DateTime.now().add(const Duration(days: 30)), // Default 1 month
                  );
                  ref.read(userSettingsProvider.notifier).addGoal(goal);
                  _goalTitleController.clear();
                  _goalAmountController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Definir Meta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog({required bool isIncome}) {
    final isPro = ref.read(subscriptionProvider) == SubscriptionPlan.pro;
    final currentCategoriesCount = ref.read(categoriesProvider).where((c) => c.isIncome == isIncome).length;
    
    if (!isPro && currentCategoriesCount >= 5) {
      ProGateHelper.showUpgradeDialog(context, 'Mais de 5 Categorias (Personalizadas)');
      return;
    }

    final nameController = TextEditingController();
    IconData selectedIcon = isIncome ? Icons.add_circle : Icons.remove_circle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isIncome ? 'Nova Categoria de Entrada' : 'Nova Categoria de Saída'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome da Categoria')),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Ícone: '),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      if (!isPro) {
                        ProGateHelper.showUpgradeDialog(context, 'Ícones Personalizados');
                        return;
                      }
                      final IconData? pickedIcon = await showDialog<IconData>(
                        context: context,
                        builder: (_) => const IconPickerDialog(),
                      );
                      if (pickedIcon != null) {
                        setDialogState(() => selectedIcon = pickedIcon);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(selectedIcon, color: AppColors.primary),
                          if (!isPro) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.workspace_premium, size: 14, color: Colors.amber),
                          ]
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final cat = CategoryItem(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    isIncome: isIncome,
                    icon: selectedIcon,
                  );
                  ref.read(categoriesProvider.notifier).addCategory(cat);
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDialog() {
    final nameController = TextEditingController();
    bool isBusiness = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🏦 Nova Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome da Conta')),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Negócio?'),
                value: isBusiness,
                onChanged: (val) => setDialogState(() => isBusiness = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final acc = FinanceAccount(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    isBusiness: isBusiness,
                    icon: Icons.account_balance,
                  );
                  ref.read(accountsProvider.notifier).addAccount(acc);
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar Conta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeProDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 50),
            SizedBox(height: 16),
            Text('Conta Fácil PRO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Desbloqueie todo o poder da sua gestão financeira!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 24),
            _ProFeatureItem(icon: Icons.account_balance, text: 'Contas & Bancos Ilimitados'),
            _ProFeatureItem(icon: Icons.analytics, text: 'Relatórios DRE Profissionais'),
            _ProFeatureItem(icon: Icons.auto_awesome, text: 'Insights da IA Ilimitados'),
            _ProFeatureItem(icon: Icons.cloud_upload, text: 'Backup em Nuvem e Sync'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mais Tarde', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).upgradeToPro();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Parabéns! Você agora é PRO!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Upgrade Agora (Simulado)'),
          ),
        ],
      ),
    );
  }

  void _showFixedExpenseDialog() {
    final isPro = ref.read(subscriptionProvider) == SubscriptionPlan.pro;
    final expensesCount = ref.read(fixedExpensesProvider).length;
    
    if (!isPro && expensesCount >= 5) {
      ProGateHelper.showUpgradeDialog(context, 'Mais de 5 Despesas Fixas');
      return;
    }

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📝 Nova Despesa Fixa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Valor (MT)'), keyboardType: TextInputType.number),
            TextField(controller: dayController, decoration: const InputDecoration(labelText: 'Dia do Mês (1-31)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final exp = FixedExpense(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  dueDay: int.tryParse(dayController.text) ?? 1,
                  isBusiness: true,
                );
                ref.read(fixedExpensesProvider.notifier).addExpense(exp);
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProFeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
