import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum ReportCardType {
  salesComparison(
    id: 'sales_comparison',
    title: 'Comparativo de Vendas',
    subTitle: 'Gráfico temporal comparativo com período anterior',
    icon: Icons.show_chart_rounded,
    color: AppColors.primary,
  ),
  salesSummary(
    id: 'sales_summary',
    title: 'Resumo de Vendas',
    subTitle: 'Faturamento, gráfico de pizza por pagamento, lucro e custo',
    icon: Icons.pie_chart_outline_rounded,
    color: Colors.deepPurple,
  ),
  salesPerformance(
    id: 'sales_performance',
    title: 'Desempenho de Vendas',
    subTitle: 'Ticket médio, total de descontos e margem bruta',
    icon: Icons.point_of_sale_outlined,
    color: Colors.green,
  ),
  stock(
    id: 'stock',
    title: 'Produtos & Estoque',
    subTitle: 'Estoque baixo, vazio, desativados, arquivados e projeções',
    icon: Icons.inventory_2_outlined,
    color: AppColors.primary,
  ),
  customersDebt(
    id: 'customers_debt',
    title: 'Clientes & Fiados',
    subTitle: 'Total de devedores e saldo a receber',
    icon: Icons.people_outline,
    color: Colors.pink,
  ),
  deliveries(
    id: 'deliveries',
    title: 'Entregas',
    subTitle: 'Pendentes, atrasadas e concluídas no período',
    icon: Icons.local_shipping_outlined,
    color: Colors.orange,
  ),
  sellerRanking(
    id: 'seller_ranking',
    title: 'Ranking por Vendedor',
    subTitle: 'Desempenho da equipe: vendas e faturamento por vendedor',
    icon: Icons.leaderboard_outlined,
    color: Colors.amber,
  );

  final String id;
  final String title;
  final String subTitle;
  final IconData icon;
  final Color color;

  const ReportCardType({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
  });

  static ReportCardType? fromId(String id) {
    for (final type in ReportCardType.values) {
      if (type.id == id) return type;
    }
    return null;
  }

  static const List<ReportCardType> defaultOrder = [
    ReportCardType.salesComparison,
    ReportCardType.salesSummary,
    ReportCardType.salesPerformance,
    ReportCardType.sellerRanking,
    ReportCardType.stock,
    ReportCardType.customersDebt,
    ReportCardType.deliveries,
  ];
}
