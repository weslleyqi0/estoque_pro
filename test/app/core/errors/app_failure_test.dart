import 'package:estoque_pro/app/core/errors/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure Tests', () {
    test('NetworkFailure has correct defaults and properties', () {
      const failure = NetworkFailure();
      expect(failure.message, contains('Sem conexão'));
      expect(failure.props, equals([failure.message, null, null]));
      expect(failure.toString(), contains('NetworkFailure'));
    });

    test('PermissionFailure has correct defaults and properties', () {
      const failure = PermissionFailure(code: 'permission-denied');
      expect(failure.message, contains('permissão'));
      expect(failure.code, equals('permission-denied'));
      expect(failure.toString(), contains('Code: permission-denied'));
    });

    test('BusinessRuleFailure stores custom message', () {
      const failure = BusinessRuleFailure(message: 'Estoque insuficiente');
      expect(failure.message, equals('Estoque insuficiente'));
    });

    test('NotFoundFailure has correct defaults', () {
      const failure = NotFoundFailure();
      expect(failure.message, contains('não foi encontrado'));
    });

    test('DatabaseFailure has correct defaults', () {
      const failure = DatabaseFailure(code: 'unavailable');
      expect(failure.message, contains('banco de dados'));
      expect(failure.code, equals('unavailable'));
    });

    test('UnknownFailure wraps unknown errors', () {
      final exception = Exception('Something bad');
      final failure = UnknownFailure(message: 'Erro desconhecido', error: exception);
      expect(failure.error, equals(exception));
    });

    test('Equality holds for same failure type and properties', () {
      const failure1 = NetworkFailure(message: 'timeout', code: '408');
      const failure2 = NetworkFailure(message: 'timeout', code: '408');
      const failure3 = NetworkFailure(message: 'offline', code: '408');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });
}
