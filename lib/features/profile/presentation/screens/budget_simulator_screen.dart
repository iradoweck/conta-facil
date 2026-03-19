import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class BudgetSimulatorScreen extends StatefulWidget {
  const BudgetSimulatorScreen({super.key});

  @override
  State<BudgetSimulatorScreen> createState() => _BudgetSimulatorScreenState();
}

class _BudgetSimulatorScreenState extends State<BudgetSimulatorScreen> {
  final Map<String, double> _services = {
    'Acessoria Fiscal Mensal': 2500.0,
    'Constituição de Lda/Eireli': 15000.0,
    'Declaração de Rendimentos': 1200.0,
    'Auditoria de Contas': 8000.0,
    'Desenvolvimento Mobile Core': 45000.0,
    'Apoio em Software Financeiro': 5000.0,
  };

  final Set<String> _selectedServices = {};

  double get _total => _selectedServices.fold(0, (sum, s) => sum + _services[s]!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Orçamento')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Selecione os serviços desejados:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ..._services.keys.map((s) => _buildServiceTile(s)).toList(),
              ],
            ),
          ),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildServiceTile(String service) {
    bool isSelected = _selectedServices.contains(service);
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (val) {
          setState(() {
            if (val!) {
              _selectedServices.add(service);
            } else {
              _selectedServices.remove(service);
            }
          });
        },
        title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('MZN ${_services[service]!.toStringAsFixed(2)}'),
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildTotalSummary() {
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
                const Text('Total Estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text(
                  'MZN ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedServices.isEmpty ? null : _sendRequest,
              child: const Text('Solicitar Proposta Oficial'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendRequest() {
    // Simular envio de pedido ou abrir WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido de orçamento enviado com sucesso para Edmilson Muacigarro!')),
    );
    Navigator.of(context).pop();
  }
}
