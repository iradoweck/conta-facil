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
    title: 'Edmilson: Dev Web Real',
    description: 'Aprenda a criar sites que vendem em Moçambique, sem complicações técnicas.',
    icon: Icons.code,
    color: Colors.blue,
    category: 'TI',
    topics: ['HTML & CSS para Empreendedores', 'Por que usar React no seu negócio?', 'Hospedagem e Domínios .co.mz'],
  ),
  EducationItem(
    title: 'Mentoria: Gestão de Parceiro',
    description: 'Como eu organizo os meus negócios e como você pode fazer o mesmo para crescer.',
    icon: Icons.business_center,
    color: Colors.green,
    category: 'Business',
    topics: ['Primeiro Plano de Negócios Prático', 'Vender serviços de TI com confiança', 'Networking: A Chave em Maputo'],
  ),
  EducationItem(
    title: 'Guia Fiscal: Papo Direto',
    description: 'O que você realmente precisa saber sobre ISPC e IVA para não ter problemas.',
    icon: Icons.account_balance,
    color: Colors.orange,
    category: 'Fiscal',
    topics: ['ISPC descodificado para você', 'O segredo da organização de faturas', 'IVA: O que todo parceiro deve saber'],
  ),
];
