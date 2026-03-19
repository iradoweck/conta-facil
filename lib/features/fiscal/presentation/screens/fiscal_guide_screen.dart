import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class FiscalGuideScreen extends StatelessWidget {
  const FiscalGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia Fiscal Moçambique')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildGuideSection(
            'Imposto Simplificado (ISPC)',
            'O ISPC é um imposto único que substitui o IRPC/IRPS e o IVA para pequenos negócios.\n\n'
            '• Taxa: 3% sobre o faturamento bruto.\n'
            '• Limite: Até 2.500.000 MT anuais.\n'
            '• Vantagem: Menos burocracia e contabilidade simplificada.',
            Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            'Calendário do Empreendedor',
            'Fique atento aos prazos para evitar multas:\n\n'
            '• Declaração Trimestral: Até ao dia 15 do mês seguinte ao trimestre.\n'
            '• Jan-Mar: Pagar até 15 de Abril.\n'
            '• Abr-Jun: Pagar até 15 de Julho.',
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            'Dicas de Boas Práticas',
            '1. Separe a conta pessoal da conta do negócio.\n'
            '2. Guarde todos os recibos de compras (custos).\n'
            '3. Registe cada venda no momento em que acontece.',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: 48),
          _buildProfessionalSupport(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Educação Fiscal',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Informação essencial para o seu negócio crescer legalmente em Moçambique.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String content, IconData icon) {
    return ExpansionTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalSupport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Dúvidas Específicas?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'O simulador e guia são informativos. Para suporte contabilístico personalizado, contacte um especialista.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent_outlined, color: AppColors.success),
            label: const Text('Falar com Especialista', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}
