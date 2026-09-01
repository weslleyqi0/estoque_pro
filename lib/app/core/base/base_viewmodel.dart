import 'package:flutter/foundation.dart';
import '../logger/app_logger.dart';

/// Base class for all ViewModels in the application.
/// Provides lifecycle tracking, safe state notification, and centralized logging.
abstract class BaseViewModel extends ChangeNotifier {
  late final AppLogger logger;
  bool _isDisposed = false;

  BaseViewModel({String? tag}) {
    logger = AppLogger(tag ?? runtimeType.toString());
  }

  /// Whether this ViewModel has been disposed.
  bool get isDisposed => _isDisposed;

  /// Log an error message with optional error and stackTrace.
  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log an informational message.
  void logInfo(String message) {
    logger.i(message);
  }

  /// Log a debug message.
  void logDebug(String message) {
    logger.d(message);
  }

  /// Log a warning message.
  void logWarning(String message) {
    logger.w(message);
  }

  /// Safely notifies listeners only if the ViewModel is not disposed.
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
