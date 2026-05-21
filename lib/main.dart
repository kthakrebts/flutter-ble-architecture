import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/app/app.dart';
import 'package:flutter_ble_architecture/core/di/injection_container.dart';
import 'package:flutter_ble_architecture/core/logger/app_logger.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initDI();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.e(
        'Framework Exception: ${details.exception}',
        tag: 'FlutterFramework',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.e(
        'Uncaught Platform Exception: $error',
        tag: 'PlatformDispatcher',
        error: error,
        stackTrace: stack,
      );
      return true;
    };

    runApp(const App());
  }, (error, stack) {
    AppLogger.f(
      'Fatal Zone Exception: $error',
      tag: 'ZonedGuarded',
      error: error,
      stackTrace: stack,
    );
  });
}
