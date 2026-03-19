import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/domain/models/account.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';
import 'package:conta_facil/features/settings/domain/models/settings_models.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  final Transaction? transactionToEdit;

  const AddTransactionScreen({
    super.key, 
    this.initialType = TransactionType.expense,
    this.transactionToEdit,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  late bool _isBusiness;
  String? _selectedAccountId;
  
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _customCategoryController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _showCustomCategory = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transactionToEdit;
    if (t != null) {
      _type = t.type;
      _isBusiness = t.isBusiness;
      _amountController.text = t.amount.toString();
      _titleController.text = t.title;
      _selectedDate = t.date;
      _selectedCategory = t.category;
      _selectedAccountId = t.accountId;
    } else {
      _type = widget.initialType;
      _isBusiness = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um valor válido.')),
      );
      return;
    }

    final category = _showCustomCategory 
        ? _customCategoryController.text 
        : (_selectedCategory ?? 'Geral');
    
    final transaction = widget.transactionToEdit?.copyWith(
      title: _titleController.text.isEmpty ? 'Sem título' : _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: category,
      type: _type,
      isBusiness: _isBusiness,
      accountId: _selectedAccountId,
    ) ?? Transaction(
      title: _titleController.text.isEmpty ? 'Sem título' : _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: category,
      type: _type,
      isBusiness: _isBusiness,
      accountId: _selectedAccountId,
    );

    if (widget.transactionToEdit != null) {
      ref.read(transactionsProvider.notifier).updateTransaction(transaction);
    } else {
      ref.read(transactionsProvider.notifier).addTransaction(transaction);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit != null 
            ? 'Editar Transação' 
            : (_type == TransactionType.income ? 'Nova Entrada' : 'Nova Saída')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 24),
            _buildContextToggle(),
            const SizedBox(height: 32),
            _buildAmountInput(),
            const SizedBox(height: 24),
            Text('Detalhes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildAccountPicker(),
            const SizedBox(height: 16),
            _buildCategoryPicker(),
            if (_showCustomCategory) ...[
              const SizedBox(height: 16),
              _buildCustomCategoryInput(),
            ],
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.income ? AppColors.success : AppColors.alert,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  widget.transactionToEdit != null ? 'Atualizar Transação' : 'Salvar Transação', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(TransactionType.expense, 'Saída', AppColors.alert),
          ),
          Expanded(
            child: _buildToggleItem(TransactionType.income, 'Entrada', AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(TransactionType type, String label, Color color) {
    bool isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _selectedCategory = null; // Reset category when type changes
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finalidade', style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Negócio')),
                selected: _isBusiness,
                onSelected: (val) => setState(() {
                  _isBusiness = true;
                  _selectedAccountId = null;
                }),
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(color: _isBusiness ? AppColors.primary : Colors.black54),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Pessoal')),
                selected: !_isBusiness,
                onSelected: (val) => setState(() {
                  _isBusiness = false;
                  _selectedAccountId = null;
                }),
                selectedColor: Colors.blue.withOpacity(0.2),
                labelStyle: TextStyle(color: !_isBusiness ? Colors.blue : Colors.black54),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valor (MT)', style: TextStyle(fontSize: 16, color: Colors.black54)),
        TextField(
          controller: _amountController,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '0,00',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Título / Descrição',
        prefixIcon: Icon(Icons.description_outlined),
      ),
    );
  }

  Widget _buildAccountPicker() {
    final accountsAsync = ref.watch(accountsProvider);
    return accountsAsync.when(
      data: (accounts) {
        final contextAccounts = accounts.where((a) => a.type == (_isBusiness ? AccountType.business : AccountType.personal)).toList();
        return DropdownButtonFormField<String>(
          value: _selectedAccountId,
          decoration: const InputDecoration(
            labelText: 'Conta / Origem',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          ),
          items: contextAccounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
          onChanged: (val) => setState(() => _selectedAccountId = val),
          hint: const Text('Selecione uma conta'),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Erro ao carregar contas'),
    );
  }

  Widget _buildCategoryPicker() {
    final allCategories = ref.watch(categoriesProvider);
    final filteredCategories = allCategories.where((CategoryItem c) => c.isIncome == (_type == TransactionType.income)).toList();
    
    final categoryNames = filteredCategories.map((c) => c.name).toList();
    categoryNames.add('Outra...');

    if (_selectedCategory != null && !categoryNames.contains(_selectedCategory)) {
       // If currently selected category is not in the list (maybe deleted?), fallback
       _selectedCategory = categoryNames.first;
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: categoryNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) => setState(() {
        _selectedCategory = val!;
        _showCustomCategory = val == 'Outra...';
      }),
      hint: const Text('Selecione uma categoria'),
    );
  }

  Widget _buildCustomCategoryInput() {
    return TextField(
      controller: _customCategoryController,
      decoration: const InputDecoration(
        labelText: 'Nome da Categoria',
        hintText: 'Ex: Marketing, Consultoria, etc.',
        prefixIcon: Icon(Icons.edit_note),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) setState(() => _selectedDate = d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDEE2E6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.black54),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
