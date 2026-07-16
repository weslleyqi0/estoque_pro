import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result Tests', () {
    test('Success pattern matching and fold works', () {
      const result = Result.success('ok');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, equals('ok'));
      expect(result.error, isNull);

      final foldResult = result.fold(
        onSuccess: (value) => 'Success: $value',
        onFailure: (error) => 'Failure',
      );

      expect(foldResult, equals('Success: ok'));
    });

    test('Failure pattern matching and fold works', () {
      final exception = Exception('error message');
      final result = Result<String>.failure(exception);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.value, isNull);
      expect(result.error, equals(exception));

      final foldResult = result.fold(
        onSuccess: (value) => 'Success',
        onFailure: (error) => 'Failure: ${error.toString()}',
      );

      expect(foldResult, equals('Failure: Exception: error message'));
    });
  });
}
