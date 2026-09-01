import 'package:estoque_pro/app/core/utils/sale_code_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleCodeGenerator Tests', () {
    test('generate returns a string with # prefix and 6 chars by default', () {
      final code = SaleCodeGenerator.generate();
      expect(code.startsWith('#'), isTrue);
      expect(code.length, 7); // '#' + 6 chars
    });

    test('generate without prefix returns exactly 6 chars', () {
      final code = SaleCodeGenerator.generate(withPrefix: false);
      expect(code.startsWith('#'), isFalse);
      expect(code.length, 6);
    });

    test('generate follows alternating Letra-Número-Letra-Número-Letra-Número pattern', () {
      final letterSet = SaleCodeGenerator.allowedLetters.split('').toSet();
      final digitSet = SaleCodeGenerator.allowedDigits.split('').toSet();

      for (var i = 0; i < 500; i++) {
        final code = SaleCodeGenerator.generate(withPrefix: false);
        expect(code.length, 6);

        // Position 0 (1ª): Letra
        expect(letterSet.contains(code[0]), isTrue, reason: 'Index 0 should be a letter: $code');
        // Position 1 (2ª): Número
        expect(digitSet.contains(code[1]), isTrue, reason: 'Index 1 should be a digit: $code');
        // Position 2 (3ª): Letra
        expect(letterSet.contains(code[2]), isTrue, reason: 'Index 2 should be a letter: $code');
        // Position 3 (4ª): Número
        expect(digitSet.contains(code[3]), isTrue, reason: 'Index 3 should be a digit: $code');
        // Position 4 (5ª): Letra
        expect(letterSet.contains(code[4]), isTrue, reason: 'Index 4 should be a letter: $code');
        // Position 5 (6ª): Número
        expect(digitSet.contains(code[5]), isTrue, reason: 'Index 5 should be a digit: $code');
      }
    });

    test('generate never contains ambiguous characters (0, O, o, 1, I, i, L, l)', () {
      const ambiguousChars = ['0', 'O', 'o', '1', 'I', 'i', 'L', 'l'];

      for (var i = 0; i < 1000; i++) {
        final code = SaleCodeGenerator.generate(withPrefix: false);
        for (final ambiguous in ambiguousChars) {
          expect(
            code.contains(ambiguous),
            isFalse,
            reason: 'Generated code $code contains ambiguous character $ambiguous',
          );
        }
      }
    });

    test('generate produces unique codes in multiple calls', () {
      final set = <String>{};
      for (var i = 0; i < 50; i++) {
        set.add(SaleCodeGenerator.generate());
      }
      expect(set.length, greaterThanOrEqualTo(45));
    });

    test('generate respects custom length', () {
      final code = SaleCodeGenerator.generate(length: 8, withPrefix: false);
      expect(code.length, 8);
    });
  });
}
