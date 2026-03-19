import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/features/settings/domain/models/settings_models.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';

import 'package:uuid/uuid.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _minBalanceBusinessController = TextEditingController();
  final _minBalancePersonalController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _minBalanceBusinessController.dispose();
    _minBalancePersonalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryItem> categories = ref.watch(categoriesProvider);
    final List<FixedExpense> fixedExpenses = ref.watch(fixedExpensesProvider);
    final settings = ref.watch(userSettingsProvider);

    // Populate controllers if empty
    if (_minBalanceBusinessController.text.isEmpty && settings.minMonthlyBalanceBusiness > 0) {
      _minBalanceBusinessController.text = settings.minMonthlyBalanceBusiness.toStringAsFixed(2);
    }
    if (_minBalancePersonalController.text.isEmpty && settings.minMonthlyBalancePersonal > 0) {
      _minBalancePersonalController.text = settings.minMonthlyBalancePersonal.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Metas Financeiras'),
          _buildMetaCard(
            'Meta Negócio',
            'Reserva estratégica para a empresa.',
            _minBalanceBusinessController,
            (val) => ref.read(userSettingsProvider.notifier).updateSettings(
              UserSettings(
                minMonthlyBalanceBusiness: val,
                minMonthlyBalancePersonal: settings.minMonthlyBalancePersonal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildMetaCard(
            'Meta Pessoal',
            'Reserva para despesas pessoais.',
            _minBalancePersonalController,
            (val) => ref.read(userSettingsProvider.notifier).updateSettings(
              UserSettings(
                minMonthlyBalanceBusiness: settings.minMonthlyBalanceBusiness,
                minMonthlyBalancePersonal: val,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Gestão de Categorias'),
          _buildCategoryList('Entradas', categories.where((CategoryItem c) => c.isIncome).toList(), true),
          _buildCategoryList('Saídas', categories.where((CategoryItem c) => !c.isIncome).toList(), false),
          const SizedBox(height: 24),
          _buildSectionTitle('Despesas Fixas'),
          _buildFixedExpensesList(fixedExpenses),
        ],
      ),
    );
  }

  Widget _buildMetaCard(String title, String subtitle, TextEditingController controller, Function(double) onSave) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'MT'),
            textAlign: TextAlign.end,
            onEditingComplete: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              onSave(value);
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meta atualizada!'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
    );
  }

  Widget _buildCategoryList(String title, List<CategoryItem> items, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        ),
        ...items.map((item) => ListTile(
          leading: Icon(item.icon, color: AppColors.primary),
          title: Text(item.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showCategoryDialog(item: item, isIncome: isIncome),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => ref.read(categoriesProvider.notifier).deleteCategory(item.id),
              ),
            ],
          ),
        )),
        TextButton.icon(
          onPressed: () => _showCategoryDialog(isIncome: isIncome),
          icon: const Icon(Icons.add),
          label: Text('Adicionar Categoria de $title'),
        ),
      ],
    );
  }

  Widget _buildFixedExpensesList(List<FixedExpense> expenses) {
    return Column(
      children: [
        if (expenses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nenhuma despesa fixa cadastrada.', style: TextStyle(color: Colors.grey)),
          ),
        ...expenses.map((e) => Card(
          child: ListTile(
            title: Text(e.title),
            subtitle: Text('${e.isBusiness ? 'Negócio' : 'Pessoal'} • Vence dia ${e.dueDay.toString().padLeft(2, '0')} • ${e.amount} MT'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showFixedExpenseDialog(expense: e),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  onPressed: () => ref.read(fixedExpensesProvider.notifier).deleteExpense(e.id),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showFixedExpenseDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Nova Despesa Fixa'),
        ),
      ],
    );
  }

  void _showCategoryDialog({CategoryItem? item, required bool isIncome}) {
    final nameController = TextEditingController(text: item?.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Nova Categoria' : 'Editar Categoria'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nome da Categoria'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newItem = CategoryItem(
                  id: item?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  isIncome: isIncome,
                  icon: item?.icon ?? (isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline),
                );
                if (item == null) {
                  ref.read(categoriesProvider.notifier).addCategory(newItem);
                } else {
                  ref.read(categoriesProvider.notifier).updateCategory(newItem);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showFixedExpenseDialog({FixedExpense? expense}) {
    final titleController = TextEditingController(text: expense?.title);
    final amountController = TextEditingController(text: expense?.amount.toString());
    final dayController = TextEditingController(text: expense?.dueDay.toString());
    bool isBusiness = expense?.isBusiness ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(expense == null ? 'Nova Despesa Fixa' : 'Editar Despesa Fixa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Valor'), keyboardType: TextInputType.number),
              TextField(controller: dayController, decoration: const InputDecoration(labelText: 'Dia de Vencimento'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Negócio?'),
                subtitle: Text(isBusiness ? 'Despesa da Empresa' : 'Despesa Pessoal'),
                value: isBusiness,
                onChanged: (val) => setDialogState(() => isBusiness = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newExpense = FixedExpense(
                    id: expense?.id ?? const Uuid().v4(),
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    dueDay: int.tryParse(dayController.text) ?? 1,
                    isBusiness: isBusiness,
                  );
                  if (expense == null) {
                    ref.read(fixedExpensesProvider.notifier).addExpense(newExpense);
                  } else {
                    ref.read(fixedExpensesProvider.notifier).updateExpense(newExpense);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
