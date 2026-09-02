import 'package:equatable/equatable.dart';

class CustomersDebtReportEntity extends Equatable {
  final int totalCustomers;
  final int customersInDebtCount;
  final double totalDebtAmount;

  const CustomersDebtReportEntity({
    this.totalCustomers = 0,
    this.customersInDebtCount = 0,
    this.totalDebtAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        totalCustomers,
        customersInDebtCount,
        totalDebtAmount,
      ];
}
