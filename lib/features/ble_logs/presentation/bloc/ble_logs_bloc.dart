import 'dart:async';
import 'package:flutter_ble_architecture/features/ble_logs/domain/repositories/ble_logs_repository.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_event.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Business Logic Component managing telemetry event log retrieval.
class BleLogsBloc extends Bloc<BleLogsEvent, BleLogsState> {
  BleLogsBloc({
    required BleLogsRepository logsRepository,
  })  : _logsRepository = logsRepository,
        super(const BleLogsState()) {
    on<LoadLogs>(_onLoadLogs);
    on<ClearLogs>(_onClearLogs);
    on<UpdateLogsList>(_onUpdateLogsList);

    _logsSubscription = _logsRepository.logsStream.listen((logs) {
      add(UpdateLogsList(logs));
    });
  }

  final BleLogsRepository _logsRepository;
  StreamSubscription<dynamic>? _logsSubscription;

  Future<void> _onLoadLogs(LoadLogs event, Emitter<BleLogsState> emit) async {
    emit(state.copyWith(status: BleLogsStatus.loading));
    try {
      final logs = await _logsRepository.getLogs();
      emit(state.copyWith(status: BleLogsStatus.success, logs: logs));
    } on Exception catch (e) {
      emit(state.copyWith(status: BleLogsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearLogs(ClearLogs event, Emitter<BleLogsState> emit) async {
    try {
      await _logsRepository.clearLogs();
    } on Exception catch (e) {
      emit(state.copyWith(status: BleLogsStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onUpdateLogsList(UpdateLogsList event, Emitter<BleLogsState> emit) {
    emit(state.copyWith(status: BleLogsStatus.success, logs: event.logs));
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}
