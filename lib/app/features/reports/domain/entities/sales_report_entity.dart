import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_chart_point.dart';

class SalesReportEntity extends Equatable {
  final int salesCount;
  final double totalSales;
  final double totalCost;
  final double grossProfit;
  final double marginPercent;
  final double totalDiscount;
  final double cashAmount;
  final double cardCreditAmount;
  final double cardDebitAmount;
  final double fiadoAmount;
  final double pixAmount;
  final double previousTotalSales;
  final List<SalesChartPoint> chartPoints;

  double get cardTotalAmount => cardCreditAmount + cardDebitAmount;

  double get averageTicket => salesCount > 0 ? totalSales / salesCount : 0.0;

  /// Variação percentual de vendas em relação ao período anterior
  double get growthPercent {
    if (previousTotalSales <= 0) {
      return totalSales > 0 ? 100.0 : 0.0;
    }
    return ((totalSales - previousTotalSales) / previousTotalSales) * 100;
  }

  const SalesReportEntity({
    this.salesCount = 0,
    this.totalSales = 0.0,
    this.totalCost = 0.0,
    this.grossProfit = 0.0,
    this.marginPercent = 0.0,
    this.totalDiscount = 0.0,
    this.cashAmount = 0.0,
    this.cardCreditAmount = 0.0,
    this.cardDebitAmount = 0.0,
    this.fiadoAmount = 0.0,
    this.pixAmount = 0.0,
    this.previousTotalSales = 0.0,
    this.chartPoints = const [],
  });

  @override
  List<Object?> get props => [
        salesCount,
        totalSales,
        totalCost,
        grossProfit,
        marginPercent,
        totalDiscount,
        cashAmount,
        cardCreditAmount,
        cardDebitAmount,
        fiadoAmount,
        pixAmount,
        previousTotalSales,
        chartPoints,
      ];
}
