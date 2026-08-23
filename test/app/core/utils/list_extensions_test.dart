import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

class _Item {
  final String name;
  _Item(this.name);
}

void main() {
  group('ListSortingExtension Tests', () {
    test('sortedByName sorts iterable alphabetically case-insensitively without modifying original', () {
      final items = [
        _Item('Zebra'),
        _Item('banana'),
        _Item('Abacaxi'),
      ];

      final sorted = items.sortedByName((item) => item.name);

      expect(sorted.map((i) => i.name).toList(), ['Abacaxi', 'banana', 'Zebra']);
      // Original remains unchanged
      expect(items.map((i) => i.name).toList(), ['Zebra', 'banana', 'Abacaxi']);
    });

    test('sortedByName supports descending order', () {
      final items = [
        _Item('banana'),
        _Item('Abacaxi'),
        _Item('Zebra'),
      ];

      final sorted = items.sortedByName((item) => item.name, ascending: false);

      expect(sorted.map((i) => i.name).toList(), ['Zebra', 'banana', 'Abacaxi']);
    });

    test('sortByName sorts list in place and returns it', () {
      final items = [
        _Item('Morango'),
        _Item('abacate'),
      ];

      final result = items.sortByName((item) => item.name);

      expect(result.map((i) => i.name).toList(), ['abacate', 'Morango']);
      expect(items.map((i) => i.name).toList(), ['abacate', 'Morango']);
    });
  });
}
