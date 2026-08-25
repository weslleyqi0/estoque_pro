import 'dart:math';

/// Utility to generate unambiguous 6-character alphanumeric sale codes
/// following an alternating Letter-Number pattern (Letra-Número-Letra-Número-Letra-Número).
///
/// Excludes characters that can be visually confused with each other:
/// - `0`, `O`, `o` (Zero and letter O)
/// - `1`, `I`, `i`, `L`, `l` (Number one, letters I and L)
class SaleCodeGenerator {
  SaleCodeGenerator._();

  /// 23 unambiguous uppercase letters (excluding I, L, O)
  static const String allowedLetters = 'ABCDEFGHJKMNPQRSTUVWXYZ';

  /// 8 unambiguous digits (excluding 0, 1)
  static const String allowedDigits = '23456789';

  /// Generates a random alphanumeric sale code following the pattern:
  /// Letra - Número - Letra - Número - Letra - Número (default 6 characters, prefixed with '#').
  ///
  /// Examples: `#A3K9X2`, `#B7N4P8`, `#M5Z2R9`
  static String generate({
    int length = 6,
    bool withPrefix = true,
    Random? random,
  }) {
    final rnd = random ?? Random();
    final buffer = StringBuffer(withPrefix ? '#' : '');
    for (var i = 0; i < length; i++) {
      if (i.isEven) {
        buffer.write(allowedLetters[rnd.nextInt(allowedLetters.length)]);
      } else {
        buffer.write(allowedDigits[rnd.nextInt(allowedDigits.length)]);
      }
    }
    return buffer.toString();
  }
}
