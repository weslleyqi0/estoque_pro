import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyInputFormatter Tests', () {
    late CurrencyInputFormatter formatter;

    setUp(() {
      formatter = CurrencyInputFormatter();
    });

    test('formats single digit as cents', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '5');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('R\$ 0,05'));
    });

    test('formats consecutive digits correctly', () {
      const oldValue = TextEditingValue(text: 'R\$ 0,05');
      const newValue = TextEditingValue(text: 'R\$ 0,050');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('R\$ 0,50'));
    });

    test('formats hundreds and thousands correctly', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '123456');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('R\$ 1.234,56'));
    });

    test('handles empty input when deleting all characters', () {
      const oldValue = TextEditingValue(text: 'R\$ 0,05');
      const newValue = TextEditingValue.empty;
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals(''));
    });

    test('formats without currency symbol when includeSymbol is false', () {
      final noSymbolFormatter = CurrencyInputFormatter(includeSymbol: false);
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '500');
      final result = noSymbolFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('5,00'));
    });
  });
}
