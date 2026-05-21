import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A production-grade wrapper for the logger package.
///
/// Prevents verbose logging in release builds and structures debug prints.
class AppLogger {
  AppLogger._internal();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    filter: ProductionFilter(),
  );

  /// Log a message at the verbose/debug level.
  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
    }
  }

  /// Log a message at the info level.
  static void i(String message, {String? tag}) {
    _logger.i(_formatMessage(message, tag));
  }

  /// Log a message at the warning level.
  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.w(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
  }

  /// Log a message at the error level.
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.e(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
  }

  /// Log a message at the wtf/critical level.
  static void f(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.f(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
  }

  static String _formatMessage(String message, String? tag) {
    return tag != null ? '[$tag] $message' : message;
  }
}
