import 'dart:async';
import 'dart:convert';
import 'package:flutter_ble_architecture/core/constants/app_constants.dart';
import 'package:flutter_ble_architecture/core/logger/app_logger.dart';
import 'package:flutter_ble_architecture/features/ble_logs/domain/entities/ble_log_entry.dart';
import 'package:flutter_ble_architecture/features/ble_logs/domain/repositories/ble_logs_repository.dart';
import 'package:hive/hive.dart';

/// Concrete implementation of [BleLogsRepository] using Hive.
class BleLogsRepositoryImpl implements BleLogsRepository {
  BleLogsRepositoryImpl(this._box) {
    _initStream();
  }

  final Box<String> _box;
  final StreamController<List<BleLogEntry>> _controller =
      StreamController<List<BleLogEntry>>.broadcast();

  void _initStream() {
    _controller.add(_getLogsSync());
  }

  List<BleLogEntry> _getLogsSync() {
    try {
      final stored = _box.get(AppConstants.keyLogList);
      if (stored == null) return [];
      final decoded = jsonDecode(stored) as List<dynamic>;
      return decoded
          .map((e) => BleLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      AppLogger.e(
        'Failed to parse cached BLE logs: $e',
        tag: 'BleLogsRepositoryImpl',
      );
      return [];
    }
  }

  @override
  Stream<List<BleLogEntry>> get logsStream => _controller.stream;

  @override
  Future<List<BleLogEntry>> getLogs() async {
    return _getLogsSync();
  }

  @override
  Future<void> log(
    String message, {
    String level = 'INFO',
    String? deviceId,
  }) async {
    try {
      final entry = BleLogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: level,
        deviceId: deviceId,
      );

      final logs = _getLogsSync()..insert(0, entry);

      if (logs.length > 500) {
        logs.removeRange(500, logs.length);
      }

      await _box.put(
        AppConstants.keyLogList,
        jsonEncode(logs.map((e) => e.toJson()).toList()),
      );
      _controller.add(logs);

      AppLogger.d('[$level] $message', tag: 'BLE_EVENT');
    } on Exception catch (e) {
      AppLogger.e(
        'Failed to write BLE log to disk: $e',
        tag: 'BleLogsRepositoryImpl',
      );
    }
  }

  @override
  Future<void> clearLogs() async {
    try {
      await _box.delete(AppConstants.keyLogList);
      _controller.add([]);
      AppLogger.i(
        'BLE Logs cleared successfully',
        tag: 'BleLogsRepositoryImpl',
      );
    } on Exception catch (e) {
      AppLogger.e('Failed to clear BLE logs: $e', tag: 'BleLogsRepositoryImpl');
    }
  }
}
