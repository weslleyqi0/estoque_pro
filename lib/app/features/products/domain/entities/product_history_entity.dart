import 'package:equatable/equatable.dart';

enum ProductHistoryAction { add, remove, set, sale }

class ProductHistoryEntity extends Equatable {
  final ProductHistoryAction action;
  final int quantity;
  final DateTime date;
  final String note;
  final String? userName;

  const ProductHistoryEntity({
    required this.action,
    required this.quantity,
    required this.date,
    this.note = '',
    this.userName,
  });

  @override
  List<Object?> get props => [action, quantity, date, note, userName];
}
