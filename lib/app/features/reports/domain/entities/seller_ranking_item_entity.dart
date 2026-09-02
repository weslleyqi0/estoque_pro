import 'package:equatable/equatable.dart';

class SellerRankingItemEntity extends Equatable {
  final String userId;
  final String userName;
  final int salesCount;
  final double totalAmount;

  const SellerRankingItemEntity({
    required this.userId,
    required this.userName,
    required this.salesCount,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        salesCount,
        totalAmount,
      ];
}
