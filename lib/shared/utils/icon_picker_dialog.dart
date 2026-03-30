import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // A predefined list of icons useful for financial categories
    final List<IconData> icons = [
      Icons.shopping_cart, Icons.fastfood, Icons.directions_car,
      Icons.local_gas_station, Icons.home, Icons.build,
      Icons.medical_services, Icons.school, Icons.fitness_center,
      Icons.pets, Icons.flight, Icons.hotel,
      Icons.movie, Icons.music_note, Icons.sports_esports,
      Icons.receipt, Icons.account_balance, Icons.attach_money,
      Icons.trending_up, Icons.smartphone, Icons.wifi,
      Icons.water_drop, Icons.bolt, Icons.local_dining,
      Icons.work, Icons.store, Icons.business_center,
    ];

    return AlertDialog(
      title: const Text('Escolher Ícone da Categoria'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final icon = icons[index];
            return InkWell(
              onTap: () => Navigator.pop(context, icon),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
