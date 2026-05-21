import 'package:equatable/equatable.dart';
import '../../domain/entities/ble_log_entry.dart';

/// Base event class for telemetry logs.
abstract class BleLogsEvent extends Equatable {
  const BleLogsEvent();

  @override
  List<Object?> get props => [];
}

/// Request fetching stored logs.
class LoadLogs extends BleLogsEvent {}

/// Request clearing all stored logs.
class ClearLogs extends BleLogsEvent {}

/// Internally triggered when the repository outputs a new logs list.
class UpdateLogsList extends BleLogsEvent {
  const UpdateLogsList(this.logs);

  final List<BleLogEntry> logs;

  @override
  List<Object?> get props => [logs];
}
