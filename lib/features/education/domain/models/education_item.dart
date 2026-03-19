import 'package:flutter/material.dart';

class EducationItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> topics;
  final String category;

  EducationItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.topics,
    required this.category,
  });

  // Futuro: Factory fromJson para carregar do Firestore
}

final List<EducationItem> mockEducationData = [
  EducationItem(
    title: 'Desenvolvimento Web',
    description: 'Como criar sites em Moçambique usando as últimas tecnologias.',
    icon: Icons.code,
    color: Colors.blue,
    category: 'TI',
    topics: ['HTML & CSS Especial', 'React para Negócios', 'Hospedagem em Moçambique'],
  ),
  EducationItem(
    title: 'Negócios & Gestão',
    description: 'Estratégias para fazer sua empresa crescer de forma sustentável.',
    icon: Icons.business_center,
    color: Colors.green,
    category: 'Business',
    topics: ['Primeiro Plano de Negócios', 'Como vender serviços de TI', 'Networking em Maputo'],
  ),
  EducationItem(
    title: 'Contabilidade & Fiscalidade',
    description: 'Mantenha suas contas em dia e entenda os impostos locais.',
    icon: Icons.account_balance,
    color: Colors.orange,
    category: 'Fiscal',
    topics: ['Guia de ISPC para Totais', 'IVA: Quando cobrar?', 'Organização de Faturas'],
  ),
];
