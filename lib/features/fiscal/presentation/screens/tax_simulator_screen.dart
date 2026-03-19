import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'fiscal_guide_screen.dart';

class TaxSimulatorScreen extends StatefulWidget {
  const TaxSimulatorScreen({super.key});

  @override
  State<TaxSimulatorScreen> createState() => _TaxSimulatorScreenState();
}

class _TaxSimulatorScreenState extends State<TaxSimulatorScreen> {
  final _revenueController = TextEditingController();
  double _revenue = 0;
  final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

  @override
  void dispose() {
    _revenueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Crescimento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            Text('Faturamento Mensal (MT)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _revenueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0,00',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                final cleaned = val.replaceAll(',', '.');
                setState(() => _revenue = double.tryParse(cleaned) ?? 0);
              },
            ),
            const SizedBox(height: 32),
            _buildResultCard(),
            if (_revenue * 12 > 2500000) _buildWarningLimit(),
            const SizedBox(height: 40),
            Text('Aprenda mais', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildEducationLinks(),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'O ISPC é o melhor amigo do pequeno negócio em Moçambique. Ele simplifica os seus impostos para podermos crescer juntos!',
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    double tax = _revenue * 0.03; 
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Imposto Estimado (3%)',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(tax),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          const Text(
            'Regime Simplificado para Pequenos Contribuintes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningLimit() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          const Icon(Icons.rocket_launch_outlined, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Uau! O seu faturamento já superou o limite do ISPC. 🚀 Isso é sinal de sucesso! Vamos conversar com o Edmilson sobre a transição?',
              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationLinks() {
    return Column(
      children: [
        _buildEduLink('Como pagar o ISPC?', 'Passo a passo presencial e eletrônico.', Icons.payment_outlined),
        _buildEduLink('Quando declarar?', 'O pagamento é trimestral em Moçambique.', Icons.calendar_today_outlined),
        _buildEduLink('Vantagens do ISPC', 'Redução da carga burocrática.', Icons.check_circle_outline),
      ],
    );
  }

  Widget _buildEduLink(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FiscalGuideScreen()),
          );
        },
      ),
    );
  }
}
