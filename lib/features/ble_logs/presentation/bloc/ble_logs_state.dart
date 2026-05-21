import 'package:equatable/equatable.dart';
import '../../domain/entities/ble_log_entry.dart';

/// Status of the logs feature.
enum BleLogsStatus { initial, loading, success, failure }

/// State containing current active log messages.
class BleLogsState extends Equatable {
  const BleLogsState({
    this.status = BleLogsStatus.initial,
    this.logs = const [],
    this.errorMessage,
  });

  final BleLogsStatus status;
  final List<BleLogEntry> logs;
  final String? errorMessage;

  BleLogsState copyWith({
    BleLogsStatus? status,
    List<BleLogEntry>? logs,
    String? errorMessage,
  }) {
    return BleLogsState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, logs, errorMessage];
}
