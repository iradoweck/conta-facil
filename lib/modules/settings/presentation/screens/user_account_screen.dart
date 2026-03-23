import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/settings/presentation/screens/settings_screen.dart';
import 'package:conta_facil/modules/auth/providers/auth_provider.dart';

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil & Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserHeader(context, user?.email ?? 'Usuário'),
          const SizedBox(height: 32),
          _buildSectionTitle('Configurações Financeiras'),
          _buildMenuTile(
            context,
            Icons.account_balance_outlined,
            'Gestão de Contas',
            'Configurar bancos e carteiras',
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())), // SettingsScreen handles financial setups
          ),
          _buildMenuTile(
            context,
            Icons.category_outlined,
            'Categorias',
            'Gerir categorias de entrada e saída',
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          _buildMenuTile(
            context,
            Icons.timer_outlined,
            'Despesas Fixas',
            'Gerir pagamentos recorrentes',
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Dados Pessoais'),
          _buildMenuTile(
            context,
            Icons.person_outline,
            'Informações Básicas',
            'Nome, Email e Senha',
            () {},
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Terminar Sessão', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, String email) {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            email,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Text('Utilizador Conta Fácil', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
