import 'package:equatable/equatable.dart';

class DeliveriesReportEntity extends Equatable {
  final int totalDeliveries;
  final int pendingCount;
  final int delayedCount;
  final int completedCount;
  final int cancelledCount;

  const DeliveriesReportEntity({
    this.totalDeliveries = 0,
    this.pendingCount = 0,
    this.delayedCount = 0,
    this.completedCount = 0,
    this.cancelledCount = 0,
  });

  @override
  List<Object?> get props => [
        totalDeliveries,
        pendingCount,
        delayedCount,
        completedCount,
        cancelledCount,
      ];
}
