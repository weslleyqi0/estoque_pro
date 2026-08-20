import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';

class SaleEditHistoryEntity extends Equatable {
  final String id;
  final int sequenceNumber;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String reason;
  final List<SaleItemEntity> addedItems;
  final List<SaleItemEntity> removedItems;
  final String? comment;

  const SaleEditHistoryEntity({
    required this.id,
    required this.sequenceNumber,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.reason,
    this.addedItems = const [],
    this.removedItems = const [],
    this.comment,
  });

  @override
  List<Object?> get props => [
    id,
    sequenceNumber,
    userId,
    userName,
    timestamp,
    reason,
    addedItems,
    removedItems,
    comment,
  ];
}
