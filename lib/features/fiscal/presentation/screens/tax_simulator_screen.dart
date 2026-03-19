import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class TaxSimulatorScreen extends StatefulWidget {
  const TaxSimulatorScreen({super.key});

  @override
  State<TaxSimulatorScreen> createState() => _TaxSimulatorScreenState();
}

class _TaxSimulatorScreenState extends State<TaxSimulatorScreen> {
  double _revenue = 0;
  String _regime = 'ISPC (Moçambique)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador Fiscal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            Text('Faturamento Mensal (MZN)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ex: 50.000'),
              onChanged: (val) => setState(() => _revenue = double.tryParse(val) ?? 0),
            ),
            const SizedBox(height: 32),
            _buildResultCard(),
            const SizedBox(height: 40),
            _buildEducationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este simulador fornece estimativas baseadas no regime ISPC de Moçambique. Consulte Edmilson Muacigarro para suporte profissional.',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    double tax = _revenue * 0.03; // Simulação simples de 3% de ISPC
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          const Text('Estimativa de Imposto Mensal'),
          const SizedBox(height: 12),
          Text(
            'MZN ${tax.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          const Text('Regime: 3% sobre faturamento bruto (ISPC)', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Educação Fiscal', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildEduLink('O que é o ISPC?', Icons.help_outline),
        _buildEduLink('Como declarar minhas vendas?', Icons.description_outlined),
        _buildEduLink('Prazos de pagamento', Icons.calendar_month_outlined),
      ],
    );
  }

  Widget _buildEduLink(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
