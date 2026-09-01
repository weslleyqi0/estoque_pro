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

    test('Failure pattern matching and fold works with AppFailure', () {
      const failure = NetworkFailure(message: 'Connection failed');
      final result = Result<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.value, isNull);
      expect(result.error, equals(failure));

      final foldResult = result.fold(
        onSuccess: (value) => 'Success',
        onFailure: (error) => 'Failure: ${error.message}',
      );

      expect(foldResult, equals('Failure: Connection failed'));
    });

    test('Failure wraps generic Exception in UnknownFailure', () {
      final exception = Exception('error message');
      final result = Result<String>.failure(exception);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<UnknownFailure>());
      expect(result.error?.message, equals('error message'));
    });

    test('guard returns Success on successful execution', () async {
      final result = await Result.guard(() async => 42);

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(42));
    });

    test('guard returns Failure on thrown exception', () async {
      final result = await Result.guard<int>(() async {
        throw const PermissionFailure();
      });

      expect(result.isFailure, isTrue);
      expect(result.error, isA<PermissionFailure>());
    });
  });
}
