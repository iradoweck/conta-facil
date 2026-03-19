import 'package:flutter/material.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/features/education/domain/models/education_item.dart';

class EducationHubScreen extends StatelessWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educação & Dicas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockEducationData.length,
        itemBuilder: (context, index) {
          final item = mockEducationData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildEducationItemCard(context, item),
          );
        },
      ),
    );
  }

  Widget _buildEducationItemCard(BuildContext context, EducationItem item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: item.color.withOpacity(0.1),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(item.description, style: const TextStyle(fontSize: 12)),
        children: item.topics.map((topic) => ListTile(
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
