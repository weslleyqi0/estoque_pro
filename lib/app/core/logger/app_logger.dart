import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logger for the application with severity levels and tag support.
class AppLogger {
  final String tag;

  const AppLogger([this.tag = 'App']);

  /// Log a debug message
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Static helper to log a debug message
  static void debug(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Static helper to log an info message
  static void info(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Static helper to log a warning message
  static void warning(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Static helper to log an error message
  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Core log function dispatching formatted logs to developer.log and console
  static void log(
    LogLevel level,
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final prefix = switch (level) {
      LogLevel.debug => '🔍 [DEBUG]',
      LogLevel.info => 'ℹ️ [INFO]',
      LogLevel.warning => '⚠️ [WARN]',
      LogLevel.error => '🛑 [ERROR]',
    };

    final formattedMessage = '$prefix [$tag] $message';

    developer.log(
      formattedMessage,
      name: tag,
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _levelToInt(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }
}
