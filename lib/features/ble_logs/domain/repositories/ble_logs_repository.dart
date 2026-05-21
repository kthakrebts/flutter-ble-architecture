import 'package:flutter_ble_architecture/features/ble_logs/domain/entities/ble_log_entry.dart';

/// Contract representing BLE telemetry log event storage.
abstract class BleLogsRepository {
  /// Stream emitting real-time list of appended log entries.
  Stream<List<BleLogEntry>> get logsStream;

  /// Retrieves list of stored BLE log entries.
  Future<List<BleLogEntry>> getLogs();

  /// Persists a new telemetry log entry.
  Future<void> log(String message, {String level = 'INFO', String? deviceId});

  /// Clears all stored BLE telemetry logs.
  Future<void> clearLogs();
}
