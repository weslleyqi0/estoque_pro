import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int? color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.color,
  });

  factory CategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String? ?? 'category',
      color: map['color'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
    );
  }
}
