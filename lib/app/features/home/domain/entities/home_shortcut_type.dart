import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum HomeShortcutType {
  products(
    id: 'products',
    title: 'Produtos',
    subTitle: 'Gerenciar Catalogo',
    icon: AppIcons.lists,
    color: AppColors.primary,
  ),
  sales(
    id: 'sales',
    title: 'Vendas',
    subTitle: 'Histórico e andamento',
    icon: AppIcons.orderApprove,
    color: Colors.green,
  ),
  categories(
    id: 'categories',
    title: 'Categorias',
    subTitle: 'Organizar produtos',
    icon: AppIcons.stacks,
    color: Colors.deepPurple,
  ),
  suppliers(
    id: 'suppliers',
    title: 'Fornecedores',
    subTitle: 'Gerenciar parceiros',
    icon: AppIcons.localShipping,
    color: Colors.cyan,
  ),
  customers(
    id: 'customers',
    title: 'Clientes',
    subTitle: 'Cadastros e fiados',
    icon: AppIcons.group,
    color: Colors.pink,
  ),
  deliveries(
    id: 'deliveries',
    title: 'Entregas',
    subTitle: 'Gerenciar entregas',
    icon: AppIcons.truck,
    color: Colors.orange,
  ),
  reports(
    id: 'reports',
    title: 'Relatórios',
    subTitle: 'Análise completa',
    icon: AppIcons.barChart,
    color: Colors.blue,
    managerOnly: true,
  ),
  users(
    id: 'users',
    title: 'Usuários',
    subTitle: 'Gerenciar equipe',
    icon: AppIcons.supervisorAccount,
    color: Colors.blueGrey,
    managerOnly: true,
  );

  final String id;
  final String title;
  final String subTitle;
  final IconData icon;
  final Color color;
  final bool managerOnly;

  const HomeShortcutType({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
    this.managerOnly = false,
  });

  static HomeShortcutType? fromId(String id) {
    for (final type in HomeShortcutType.values) {
      if (type.id == id) return type;
    }
    return null;
  }

  static const List<HomeShortcutType> defaultOrder = [
    HomeShortcutType.products,
    HomeShortcutType.sales,
    HomeShortcutType.categories,
    HomeShortcutType.suppliers,
    HomeShortcutType.customers,
    HomeShortcutType.deliveries,
    HomeShortcutType.reports,
    HomeShortcutType.users,
  ];
}
