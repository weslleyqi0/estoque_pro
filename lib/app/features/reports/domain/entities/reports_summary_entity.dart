import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/customers_debt_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/deliveries_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/stock_report_entity.dart';

class ReportsSummaryEntity extends Equatable {
  final ReportPeriod period;
  final SalesReportEntity sales;
  final StockReportEntity stock;
  final CustomersDebtReportEntity customersDebt;
  final DeliveriesReportEntity deliveries;

  const ReportsSummaryEntity({
    required this.period,
    this.sales = const SalesReportEntity(),
    this.stock = const StockReportEntity(),
    this.customersDebt = const CustomersDebtReportEntity(),
    this.deliveries = const DeliveriesReportEntity(),
  });

  @override
  List<Object?> get props => [
        period,
        sales,
        stock,
        customersDebt,
        deliveries,
      ];
}
