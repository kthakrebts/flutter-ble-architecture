import 'dart:async';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/core/error/failures.dart';
import 'package:flutter_ble_architecture/core/logger/app_logger.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_event.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Business Logic Component managing BLE peripheral scanning.
class BleScanBloc extends Bloc<BleScanEvent, BleScanState> {
  BleScanBloc({required BleRepository bleRepository})
    : _bleRepository = bleRepository,
      super(const BleScanState()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<UpdateScanResults>(_onUpdateScanResults);
    on<UpdateScanningStatus>(_onUpdateScanningStatus);

    // Subscribe to scan results stream
    _scanResultsSubscription = _bleRepository.scanResults.listen((devices) {
      add(UpdateScanResults(devices));
    });

    // Subscribe to scan status stream
    _isScanningSubscription = _bleRepository.isScanning.listen((isScanning) {
      add(UpdateScanningStatus(isScanning: isScanning));
    });
  }

  final BleRepository _bleRepository;
  StreamSubscription<List<BleDevice>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;

  Future<void> _onStartScan(StartScan event, Emitter<BleScanState> emit) async {
    emit(
      state.copyWith(
        status: BleScanStatus.scanning,
        // ignore: avoid_redundant_argument_values, resetting failure to null on start requires explicit null assignment.
        failure: null,
      ),
    );
    try {
      await _bleRepository.startScan(serviceUuids: event.serviceUuids);
    } on Exception catch (e) {
      AppLogger.e('Scan start error: $e', tag: 'BleScanBloc');
      emit(
        state.copyWith(
          status: BleScanStatus.failure,
          failure: BleFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onStopScan(StopScan event, Emitter<BleScanState> emit) async {
    try {
      await _bleRepository.stopScan();
    } on Exception catch (e) {
      AppLogger.e('Scan stop error: $e', tag: 'BleScanBloc');
      emit(
        state.copyWith(
          status: BleScanStatus.failure,
          failure: BleFailure(e.toString()),
        ),
      );
    }
  }

  void _onUpdateScanResults(
    UpdateScanResults event,
    Emitter<BleScanState> emit,
  ) {
    emit(state.copyWith(devices: event.devices, status: BleScanStatus.success));
  }

  void _onUpdateScanningStatus(
    UpdateScanningStatus event,
    Emitter<BleScanState> emit,
  ) {
    emit(
      state.copyWith(
        isScanning: event.isScanning,
        status: event.isScanning
            ? BleScanStatus.scanning
            : BleScanStatus.success,
      ),
    );
  }

  @override
  Future<void> close() {
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    return super.close();
  }
}
