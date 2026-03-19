import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'budget_simulator_screen.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBio(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Serviços Especializados'),
                  const SizedBox(height: 16),
                  _buildServiceList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Contactos'),
                  const SizedBox(height: 16),
                  _buildContactCard(),
                  const SizedBox(height: 100), // Espaço para o FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetSimulatorScreen()),
        ),
        label: const Text('Simular Orçamento'),
        icon: const Icon(Icons.calculate_outlined),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Edmilson Muacigarro', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.primary),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: const Icon(Icons.person, size: 80, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBadge('Contabilista'),
            const SizedBox(width: 8),
            _buildBadge('Desenvolvedor'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Especialista em transformar complexidade contabilística em soluções digitais simples para empreendedores moçambicanos.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildServiceList() {
    final services = [
      {'title': 'Acessoria Fiscal', 'desc': 'Otimização de impostos e conformidade com ISPC/IVA.'},
      {'title': 'Constituição de Empresas', 'desc': 'Apoio legal e burocrático para formalizar seu negócio.'},
      {'title': 'Gestão de Inventário', 'desc': 'Sistemas digitais para controle de stock.'},
      {'title': 'Desenvolvimento de Apps', 'desc': 'Criação de soluções personalizadas para seu setor.'},
    ];

    return Column(
      children: services.map((s) => _buildServiceItem(s['title']!, s['desc']!)).toList(),
    );
  }

  Widget _buildServiceItem(String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: AppColors.accent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }

  Widget _buildContactCard() {
    return Column(
      children: [
        _buildContactItem(Icons.email_outlined, 'contato@zedeck.com'),
        _buildContactItem(Icons.phone_outlined, '+258 84 000 0000'),
        _buildContactItem(Icons.public, 'www.zedeck.com'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
