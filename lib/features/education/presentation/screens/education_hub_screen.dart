import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class EducationHubScreen extends StatelessWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educação & Dicas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEducationCard(
            context,
            'Desenvolvimento Web',
            'Aprenda a criar sites modernos e escaláveis usando as últimas tecnologias.',
            Icons.code_outlined,
            Colors.blue,
            ['HTML & CSS Especial', 'React para Negócios', 'Hospedagem em Moçambique'],
          ),
          const SizedBox(height: 16),
          _buildEducationCard(
            context,
            'Negócios & Gestão',
            'Estratégias para fazer sua empresa crescer de forma sustentável.',
            Icons.business_center_outlined,
            Colors.green,
            ['Primeiro Plano de Negócios', 'Como vender serviços de TI', 'Networking em Maputo'],
          ),
          const SizedBox(height: 16),
          _buildEducationCard(
            context,
            'Contabilidade & Fiscalidade',
            'Mantenha suas contas em dia e entenda os impostos de Moçambique.',
            Icons.account_balance_outlined,
            Colors.orange,
            ['Guia de ISPC para Totais', 'IVA: Quando cobrar?', 'Organização de Faturas'],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> topics,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        children: topics.map((topic) => ListTile(
          dense: true,
          leading: const Icon(Icons.play_circle_outline, size: 20, color: AppColors.primary),
          title: Text(topic),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('A abrir conteúdo: $topic...')),
            );
          },
        )).toList(),
      ),
    );
  }
}
