import 'dart:async';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/core/error/failures.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_event.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_state.dart';
import 'package:flutter_ble_architecture/features/ble_logs/domain/repositories/ble_logs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Business Logic Component managing connection lifecycle and GATT transactions.
class BleConnectionBloc extends Bloc<BleConnectionEvent, BleConnectionState> {
  BleConnectionBloc({
    required BleRepository bleRepository,
    required BleLogsRepository logsRepository,
  }) : _bleRepository = bleRepository,
       _logsRepository = logsRepository,
       super(const BleConnectionState()) {
    on<ConnectDevice>(_onConnectDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<DiscoverServices>(_onDiscoverServices);
    on<UpdateConnectionStatus>(_onUpdateConnectionStatus);
  }

  final BleRepository _bleRepository;
  final BleLogsRepository _logsRepository;
  StreamSubscription<BleConnectionStatus>? _statusSubscription;

  Future<void> _onConnectDevice(
    ConnectDevice event,
    Emitter<BleConnectionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BleConnectionStatus.connecting,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
        failure: null,
        services: [],
      ),
    );

    await _logsRepository.log(
      'Initiating connection to ${event.deviceName} (${event.deviceId})',
      deviceId: event.deviceId,
    );

    _statusSubscription?.cancel();
    _statusSubscription = _bleRepository
        .monitorConnection(event.deviceId)
        .listen((status) {
          add(UpdateConnectionStatus(deviceId: event.deviceId, status: status));
        });

    try {
      await _bleRepository.connect(event.deviceId);
    } on Exception catch (e) {
      await _logsRepository.log(
        'Failed to connect to ${event.deviceName}: $e',
        level: 'ERROR',
        deviceId: event.deviceId,
      );
      emit(
        state.copyWith(
          status: BleConnectionStatus.disconnected,
          failure: BleFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onDisconnectDevice(
    DisconnectDevice event,
    Emitter<BleConnectionState> emit,
  ) async {
    emit(state.copyWith(status: BleConnectionStatus.disconnecting));

    await _logsRepository.log(
      'Initiating disconnect from device: ${event.deviceId}',
      deviceId: event.deviceId,
    );

    try {
      await _bleRepository.disconnect(event.deviceId);
      _statusSubscription?.cancel();
    } on Exception catch (e) {
      await _logsRepository.log(
        'Disconnection error: $e',
        level: 'WARN',
        deviceId: event.deviceId,
      );
      emit(
        state.copyWith(
          status: BleConnectionStatus.disconnected,
          failure: BleFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onDiscoverServices(
    DiscoverServices event,
    Emitter<BleConnectionState> emit,
  ) async {
    await _logsRepository.log(
      'Starting GATT service discovery for device: ${event.deviceId}',
      deviceId: event.deviceId,
    );

    try {
      final services = await _bleRepository.discoverServices(event.deviceId);
      await _logsRepository.log(
        'Discovered ${services.length} services: ${services.join(", ")}',
        deviceId: event.deviceId,
      );
      emit(state.copyWith(services: services));
    } on Exception catch (e) {
      await _logsRepository.log(
        'Service discovery failed: $e',
        level: 'ERROR',
        deviceId: event.deviceId,
      );
      emit(state.copyWith(failure: BleFailure(e.toString())));
    }
  }

  Future<void> _onUpdateConnectionStatus(
    UpdateConnectionStatus event,
    Emitter<BleConnectionState> emit,
  ) async {
    if (event.deviceId != state.deviceId) return;

    await _logsRepository.log(
      'Connection state changed to: ${event.status.name}',
      deviceId: event.deviceId,
    );

    emit(state.copyWith(status: event.status));

    if (event.status == BleConnectionStatus.connected) {
      add(DiscoverServices(deviceId: event.deviceId));
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
