import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int? color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.color,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color];
}
