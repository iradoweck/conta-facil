import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class HeroBalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;
  final NumberFormat currencyFormat;

  const HeroBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.currencyFormat,
  });

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard> {
  bool _obscureBalance = false;

  void _toggleObscure() {
    setState(() {
      _obscureBalance = !_obscureBalance;
    });
  }

  String _formatValue(double value) {
    if (_obscureBalance) {
      return '${widget.currencyFormat.currencySymbol} •••••';
    }
    return widget.currencyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF1E293B), // Slightly lighter slate
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Total',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              IconButton(
                icon: Icon(
                  _obscureBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: _toggleObscure,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatValue(widget.balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                letterSpacing: -1.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniBalance('Receitas', _formatValue(widget.income), AppColors.success),
              _buildMiniBalance('Despesas', _formatValue(widget.expense), AppColors.alert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalance(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                label == 'Receitas' ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
