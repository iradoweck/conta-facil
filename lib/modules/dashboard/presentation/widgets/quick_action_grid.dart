import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/transactions/domain/models/transaction.dart';
import 'package:conta_facil/modules/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:conta_facil/modules/tools/fiscal/presentation/screens/tax_simulator_screen.dart';
import 'package:conta_facil/modules/intelligence/chat/presentation/screens/chat_screen.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildActionItem(
            context,
            icon: Icons.arrow_downward_rounded,
            label: 'Receber',
            color: AppColors.success,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialType: TransactionType.income)),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionItem(
            context,
            icon: Icons.arrow_upward_rounded,
            label: 'Pagar',
            color: AppColors.alert,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialType: TransactionType.expense)),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionItem(
            context,
            icon: Icons.calculate_outlined,
            label: 'Impostos',
            color: AppColors.warning,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaxSimulatorScreen()),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionItem(
            context,
            icon: Icons.auto_awesome,
            label: 'Ajuda IA',
            color: const Color(0xFF00ADEE), // Cyan / Blue Sky (Zedeck's Palette)
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
