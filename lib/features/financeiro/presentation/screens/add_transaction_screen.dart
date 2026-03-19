import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/features/financeiro/domain/models/transaction.dart';
import 'package:conta_facil/features/financeiro/providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  const AddTransactionScreen({super.key, this.initialType = TransactionType.expense});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Geral';

  final List<String> _incomeCategories = ['Venda', 'Serviço', 'Investimento', 'Outros'];
  final List<String> _expenseCategories = ['Aluguel', 'Salário', 'Mercado', 'Transporte', 'Saúde', 'Outros'];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
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
    
    final transaction = Transaction(
      title: _titleController.text.isEmpty ? 'Sem título' : _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _type,
    );

    ref.read(transactionsProvider.notifier).addTransaction(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_type == TransactionType.income ? 'Nova Entrada' : 'Nova Saída'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 32),
            _buildAmountInput(),
            const SizedBox(height: 24),
            Text('Detalhes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildCategoryPicker(),
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
                child: const Text('Salvar Transação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      onTap: () => setState(() => _type = type),
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

  Widget _buildCategoryPicker() {
    final categories = _type == TransactionType.income ? _incomeCategories : _expenseCategories;
    return DropdownButtonFormField<String>(
      value: categories.contains(_selectedCategory) ? _selectedCategory : categories.first,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
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
