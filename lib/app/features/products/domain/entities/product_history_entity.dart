import 'package:equatable/equatable.dart';

enum ProductHistoryAction { add, remove, set, sale }

class ProductHistoryEntity extends Equatable {
  final ProductHistoryAction action;
  final int quantity;
  final int oldStock;
  final int newStock;
  final DateTime date;
  final String note;
  final String? userName;
  final bool isNew;

  const ProductHistoryEntity({
    required this.action,
    required this.quantity,
    required this.oldStock,
    required this.newStock,
    required this.date,
    this.note = '',
    this.userName,
    this.isNew = false,
  });

  @override
  List<Object?> get props => [action, quantity, oldStock, newStock, date, note, userName, isNew];
}
