import 'package:estoque_pro/app/features/categories/data/models/category_model.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel', () {
    const category = CategoryEntity(
      id: 'cat-1',
      name: 'Eletrônicos',
      icon: 'devices',
      color: 0xFF00FF00,
    );

    test('fromMap creates valid CategoryModel', () {
      final map = {
        'name': 'Eletrônicos',
        'icon': 'devices',
        'color': 0xFF00FF00,
      };

      final model = CategoryModel.fromMap('cat-1', map);

      expect(model.id, equals('cat-1'));
      expect(model.name, equals('Eletrônicos'));
      expect(model.icon, equals('devices'));
      expect(model.color, equals(0xFF00FF00));
    });

    test('fromMap handles missing/null values with defaults', () {
      final model = CategoryModel.fromMap('cat-2', {});

      expect(model.id, equals('cat-2'));
      expect(model.name, isEmpty);
      expect(model.icon, equals('category'));
      expect(model.color, isNull);
    });

    test('toMap converts model to map representation', () {
      const model = CategoryModel(
        id: 'cat-1',
        name: 'Eletrônicos',
        icon: 'devices',
        color: 0xFF00FF00,
      );

      final map = model.toMap();

      expect(map['name'], equals('Eletrônicos'));
      expect(map['icon'], equals('devices'));
      expect(map['color'], equals(0xFF00FF00));
    });

    test('toEntity converts CategoryModel to CategoryEntity', () {
      const model = CategoryModel(
        id: 'cat-1',
        name: 'Eletrônicos',
        icon: 'devices',
        color: 0xFF00FF00,
      );

      final entity = model.toEntity();

      expect(entity.id, equals('cat-1'));
      expect(entity.name, equals('Eletrônicos'));
      expect(entity.icon, equals('devices'));
      expect(entity.color, equals(0xFF00FF00));
    });

    test('fromEntity converts CategoryEntity to CategoryModel', () {
      final model = CategoryModel.fromEntity(category);

      expect(model.id, equals('cat-1'));
      expect(model.name, equals('Eletrônicos'));
      expect(model.icon, equals('devices'));
      expect(model.color, equals(0xFF00FF00));
    });
  });
}
