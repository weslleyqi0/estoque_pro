import 'package:equatable/equatable.dart';

class SalesChartPoint extends Equatable {
  final String label;
  final double currentAmount;
  final double previousAmount;

  const SalesChartPoint({
    required this.label,
    required this.currentAmount,
    this.previousAmount = 0.0,
  });

  SalesChartPoint copyWith({
    String? label,
    double? currentAmount,
    double? previousAmount,
  }) {
    return SalesChartPoint(
      label: label ?? this.label,
      currentAmount: currentAmount ?? this.currentAmount,
      previousAmount: previousAmount ?? this.previousAmount,
    );
  }

  @override
  List<Object?> get props => [label, currentAmount, previousAmount];
}
