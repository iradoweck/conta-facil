import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class TiDevScreen extends StatelessWidget {
  const TiDevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TI e Dev')),
      body: _buildPlaceholder(context, Icons.code, 'Novidades de TI e Desenvolvimento', 'Em breve, as melhores dicas de tecnologia para o seu negócio.'),
    );
  }
}

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contabilidade e Gestão')),
      body: _buildPlaceholder(context, Icons.business_center, 'Gestão e Contabilidade', 'Estratégias para manter o seu negócio saudável e lucrativo.'),
    );
  }
}

Widget _buildPlaceholder(BuildContext context, IconData icon, String title, String description) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}
