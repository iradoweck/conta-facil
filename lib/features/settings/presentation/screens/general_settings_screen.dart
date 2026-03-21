import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações do App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Preferências'),
          _buildSettingsTile(
            context,
            Icons.dark_mode_outlined,
            'Modo Escuro',
            'Alternar entre tema claro e escuro',
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          _buildSettingsTile(
            context,
            Icons.language_outlined,
            'Idioma',
            'Português (Moz)',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Sobre o App'),
          _buildSettingsTile(
            context,
            Icons.info_outline,
            'Sobre o Conta Fácil',
            'Saiba mais sobre a missão do app',
          ),
          _buildSettingsTile(
            context,
            Icons.description_outlined,
            'Termos de Uso',
            'Leia nossos termos e condições',
          ),
          _buildSettingsTile(
            context,
            Icons.privacy_tip_outlined,
            'Privacidade',
            'Como cuidamos dos seus dados',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Suporte'),
          _buildSettingsTile(
            context,
            Icons.contact_support_outlined,
            'Contactos',
            'Fale com Edmilson Muacigarro',
            onTap: () {
               // Show a dialog or snackbar with contact info
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Contactar Edmilson: muacigarro@zedeck.com'))
               );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  'Conta Fácil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Versão 1.0.0 (Beta)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                const Text('Edmilson Muacigarro • 2026', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
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

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
