import 'package:estoque_pro/app/core/utils/date_parser.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_item_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:firebase_database/firebase_database.dart';

class SaleEditHistoryModel {
  final String id;
  final int sequenceNumber;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String reason;
  final List<SaleItemModel> addedItems;
  final List<SaleItemModel> removedItems;
  final String? comment;

  const SaleEditHistoryModel({
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

  factory SaleEditHistoryModel.fromMap(Map<dynamic, dynamic> map) {
    return SaleEditHistoryModel(
      id: map['id'] as String? ?? '',
      sequenceNumber: (map['sequence_number'] as num?)?.toInt() ?? 0,
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      timestamp: DateParser.parse(map['timestamp']) ?? DateTime.now(),
      reason: map['reason'] as String? ?? '',
      addedItems: _parseList(map['added_items'], SaleItemModel.fromMap),
      removedItems: _parseList(map['removed_items'], SaleItemModel.fromMap),
      comment: map['comment'] as String?,
    );
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<dynamic, dynamic>) mapper) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .where((e) => e != null && e is Map)
          .map((e) => mapper(Map<dynamic, dynamic>.from(e as Map)))
          .toList();
    }
    if (raw is Map) {
      return raw.values
          .where((e) => e != null && e is Map)
          .map((e) => mapper(Map<dynamic, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sequence_number': sequenceNumber,
      'user_id': userId,
      'user_name': userName,
      'timestamp': ServerValue.timestamp,
      'reason': reason,
      'added_items': addedItems.map((e) => e.toMap()).toList(),
      'removed_items': removedItems.map((e) => e.toMap()).toList(),
      if (comment != null) 'comment': comment,
    };
  }

  SaleEditHistoryEntity toEntity() {
    return SaleEditHistoryEntity(
      id: id,
      sequenceNumber: sequenceNumber,
      userId: userId,
      userName: userName,
      timestamp: timestamp,
      reason: reason,
      addedItems: addedItems.map((e) => e.toEntity()).toList(),
      removedItems: removedItems.map((e) => e.toEntity()).toList(),
      comment: comment,
    );
  }

  factory SaleEditHistoryModel.fromEntity(SaleEditHistoryEntity entity) {
    return SaleEditHistoryModel(
      id: entity.id,
      sequenceNumber: entity.sequenceNumber,
      userId: entity.userId,
      userName: entity.userName,
      timestamp: entity.timestamp,
      reason: entity.reason,
      addedItems: entity.addedItems.map((e) => SaleItemModel.fromEntity(e)).toList(),
      removedItems: entity.removedItems.map((e) => SaleItemModel.fromEntity(e)).toList(),
      comment: entity.comment,
    );
  }
}
