import 'package:equatable/equatable.dart';

class CustomerSummaryEntity extends Equatable {
  final String customerId;
  final int totalPurchasesCount;
  final double totalDebt;
  final double totalPaid;
  final double currentDebt;

  const CustomerSummaryEntity({
    required this.customerId,
    this.totalPurchasesCount = 0,
    this.totalDebt = 0.0,
    this.totalPaid = 0.0,
    this.currentDebt = 0.0,
  });

  bool get hasPendingDebt => currentDebt > 0;

  @override
  List<Object?> get props => [
        customerId,
        totalPurchasesCount,
        totalDebt,
        totalPaid,
        currentDebt,
      ];
}
