import 'package:estoque_pro/app/core/utils/cpf_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpfInputFormatter Tests', () {
    test('formatString formats CPF correctly', () {
      expect(CpfInputFormatter.formatString('12345678901'), '123.456.789-01');
      expect(CpfInputFormatter.formatString('123'), '123');
      expect(CpfInputFormatter.formatString('1234'), '123.4');
      expect(CpfInputFormatter.formatString('123456'), '123.456');
      expect(CpfInputFormatter.formatString('1234567'), '123.456.7');
      expect(CpfInputFormatter.formatString('1234567890'), '123.456.789-0');
      expect(CpfInputFormatter.formatString('123456789012345'), '123.456.789-01');
    });

    test('formatString handles empty or invalid strings', () {
      expect(CpfInputFormatter.formatString(''), '');
      expect(CpfInputFormatter.formatString('abc'), '');
      expect(CpfInputFormatter.formatString('123.abc.456'), '123.456');
    });

    test('formatEditUpdate formats input progressively', () {
      final formatter = CpfInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '12345678901',
        selection: TextSelection.collapsed(offset: 11),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '123.456.789-01');
      expect(result.selection.baseOffset, 14);
    });
  });
}
