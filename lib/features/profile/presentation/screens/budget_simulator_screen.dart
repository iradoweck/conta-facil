import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class BudgetSimulatorScreen extends StatefulWidget {
  const BudgetSimulatorScreen({super.key});

  @override
  State<BudgetSimulatorScreen> createState() => _BudgetSimulatorScreenState();
}

class _BudgetSimulatorScreenState extends State<BudgetSimulatorScreen> {
  final List<Map<String, dynamic>> _items = [
    {'name': 'Acessoria Fiscal Mensal', 'price': 2500.0, 'selected': false},
    {'name': 'Consultoria de Negócios', 'price': 5000.0, 'selected': false},
  ];

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  double get _total => _items
      .where((item) => item['selected'] == true)
      .fold(0, (sum, item) => sum + item['price']);

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      setState(() {
        _items.add({'name': name, 'price': price, 'selected': true});
        _nameController.clear();
        _priceController.clear();
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetar o Amanhã'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => setState(() => _items.removeWhere((item) => item['selected'])),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Serviços & Metas', style: Theme.of(context).textTheme.titleLarge),
                    TextButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Novo Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._items.map((item) => _buildItemTile(item)).toList(),
                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'Ainda não desenhamos nada? O Edmilson e eu adoramos ver novas ideias no papel!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Item ou Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor Estimado (MT)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _addItem, child: const Text('Adicionar')),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    bool isSelected = item['selected'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1)),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (val) => setState(() => item['selected'] = val),
        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('MT ${item['price'].toStringAsFixed(2)}'),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTotalSummary() {
    final fmt = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pro-forma / Meta', style: TextStyle(fontSize: 16)),
                Text(
                  fmt.format(_total),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _total > 0 ? _generateQuote : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Gerar Pro-forma / Partilhar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateQuote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orçamento gerado! Vamos fazer isto acontecer juntos? 🚀')),
    );
  }
}
