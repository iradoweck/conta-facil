import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/shared/components/fintech_card.dart';
import 'package:intl/intl.dart';
import 'fiscal_guide_screen.dart';

class TaxSimulatorScreen extends StatefulWidget {
  const TaxSimulatorScreen({super.key});

  @override
  State<TaxSimulatorScreen> createState() => _TaxSimulatorScreenState();
}

class _TaxSimulatorScreenState extends State<TaxSimulatorScreen> {
  double _revenue = 250000;
  final double _maxRevenue = 10000000; // 10M MT max on slider
  final double _ispcLimit = 2500000;
  
  final currencyFormat = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Simulador Fiscal (ISPC)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            const Text('Faturamento Anual Estimado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildInteractiveSlider(),
            const SizedBox(height: 32),
            _buildResultGauge(),
            if (_revenue > _ispcLimit) _buildWarningLimit(),
            const SizedBox(height: 48),
            const Text('Aprenda mais sobre impostos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
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
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'O ISPC (Imposto Simplificado para Pequenos Contribuintes) cobra apenas 3% da sua receita bruta anual, até ao limite de 2.500.000 MT.',
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSlider() {
    return FintechCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            currencyFormat.format(_revenue),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _revenue > _ispcLimit ? AppColors.alert : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _revenue <= _ispcLimit ? 'Elegível para ISPC' : 'Fora do limite ISPC (Aplicável IRPC)',
            style: TextStyle(
              color: _revenue <= _ispcLimit ? AppColors.success : AppColors.alert,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _revenue <= _ispcLimit ? AppColors.primary : AppColors.alert,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
              thumbColor: _revenue <= _ispcLimit ? AppColors.primary : AppColors.alert,
              trackHeight: 8,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _revenue,
              min: 0,
              max: _maxRevenue,
              divisions: 100,
              onChanged: (val) {
                setState(() {
                  _revenue = val;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0 MT', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Máx ISPC: 2.5M', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('10M+ MT', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResultGauge() {
    // Calculo do Imposto (3% ISPC) 
    // Se for maior que o limite, simula IRPC (aprox 32% sobre lucro, mas vamos aplicar 32% simbolico com aviso)
    final isIspc = _revenue <= _ispcLimit;
    double tax = isIspc ? (_revenue * 0.03) : (_revenue * 0.32 * 0.20); // Simulação de 32% sobre margem de 20%
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isIspc ? AppColors.primary : AppColors.alert,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isIspc ? AppColors.primary : AppColors.alert).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isIspc ? 'Imposto ISPC Estimado (3%)' : 'Imposto IRPC Estimado (32% s/ Lucro Esperado)',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(tax),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: isIspc ? _revenue / _ispcLimit : 1.0,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningLimit() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alert.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.rocket_launch_rounded, color: AppColors.alert, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'O seu faturamento anual superou o teto do ISPC (2.5M MT). Está na hora de transitar para o IRPC (Regime Geral/Simplificado). Fale com o Edmilson para planear a transição.',
              style: TextStyle(color: AppColors.alert, fontSize: 13, height: 1.5),
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
        _buildEduLink('Vantagens fiscais de 2024', 'Novos limites do código do IRPC.', Icons.info_outline_rounded),
      ],
    );
  }

  Widget _buildEduLink(String title, String subtitle, IconData icon) {
    return FintechCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FiscalGuideScreen()),
          );
        },
      ),
    );
  }
}
