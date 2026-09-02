import 'package:equatable/equatable.dart';

class StockReportEntity extends Equatable {
  final int totalProducts;
  final int activeProducts;
  final int totalUnitsInStock;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalCostStock;
  final double totalSellingStock;
  final double totalProjectedProfit;

  double get projectedMarginPercent =>
      totalSellingStock > 0 ? (totalProjectedProfit / totalSellingStock) * 100 : 0.0;

  const StockReportEntity({
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.totalUnitsInStock = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.totalCostStock = 0.0,
    this.totalSellingStock = 0.0,
    this.totalProjectedProfit = 0.0,
  });

  @override
  List<Object?> get props => [
        totalProducts,
        activeProducts,
        totalUnitsInStock,
        lowStockCount,
        outOfStockCount,
        totalCostStock,
        totalSellingStock,
        totalProjectedProfit,
      ];
}
