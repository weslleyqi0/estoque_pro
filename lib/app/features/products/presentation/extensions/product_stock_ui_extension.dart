import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

extension ProductStockUIExtension on ProductEntity {
  double get maxStockProgress => minStock > 0 ? (minStock * 2).toDouble() : 10.0;

  double get rawStockProgress => maxStockProgress > 0 ? stock / maxStockProgress : 0.0;

  double get stockProgressValue => rawStockProgress.clamp(0.0, 1.0);

  Color get stockStatusColor {
    if (rawStockProgress < 0.25) {
      return AppColors.error;
    } else if (rawStockProgress < 0.50) {
      return AppColors.warning;
    } else if (rawStockProgress < 0.75) {
      return AppColors.success;
    } else {
      return AppColors.info;
    }
  }
}
