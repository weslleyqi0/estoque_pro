import 'package:estoque_pro/app/core/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger Tests', () {
    test('Static logging methods execute without throwing', () {
      expect(() => AppLogger.debug('Debug message'), returnsNormally);
      expect(() => AppLogger.info('Info message'), returnsNormally);
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
      expect(
        () => AppLogger.error('Error message', error: Exception('test')),
        returnsNormally,
      );
    });

    test('Instance logger methods execute without throwing', () {
      const logger = AppLogger('CustomTag');
      expect(() => logger.d('Debug message'), returnsNormally);
      expect(() => logger.i('Info message'), returnsNormally);
      expect(() => logger.w('Warning message'), returnsNormally);
      expect(
        () => logger.e('Error message', error: Exception('test')),
        returnsNormally,
      );
    });
  });
}
