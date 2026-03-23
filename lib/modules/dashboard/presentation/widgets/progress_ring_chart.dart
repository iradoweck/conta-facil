import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/shared/components/fintech_card.dart';
import 'package:conta_facil/modules/reports/presentation/screens/analytics_screen.dart';

class ProgressRingChart extends StatelessWidget {
  final double income;
  final double expense;

  const ProgressRingChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    // Calculates a simple efficiency score
    final double efficiency = (income / ((income + expense) > 0 ? (income + expense) : 1)) * 100;
    
    return FintechCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saúde Financeira', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      income >= expense ? 'Operando com lucro' : 'Alerta de Fluxo',
                      style: TextStyle(
                        color: income >= expense ? AppColors.success : AppColors.alert,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                icon: const Icon(Icons.analytics_outlined, size: 16, color: AppColors.primary),
                label: const Text('Análise Completa', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    startDegreeOffset: 270,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.success,
                        value: income == 0 && expense == 0 ? 1 : income,
                        title: '',
                        radius: 14,
                        showTitle: false,
                        badgeWidget: income > 0 
                            ? _buildBadge(Icons.trending_up, AppColors.success) 
                            : null,
                        badgePositionPercentageOffset: 1.1,
                      ),
                      PieChartSectionData(
                        color: AppColors.alert,
                        value: income == 0 && expense == 0 ? 0 : expense,
                        title: '',
                        radius: 14,
                        showTitle: false,
                        badgeWidget: expense > 0 
                            ? _buildBadge(Icons.trending_down, AppColors.alert) 
                            : null,
                        badgePositionPercentageOffset: 1.1,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${efficiency.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.primary, letterSpacing: -1.0),
                      ),
                      const Text(
                        'Eficiência', 
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Receitas', AppColors.success),
              _buildLegendItem('Despesas', AppColors.alert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
