import 'package:equatable/equatable.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';

/// Base event class for BLE connection operations.
abstract class BleConnectionEvent extends Equatable {
  const BleConnectionEvent();

  @override
  List<Object?> get props => [];
}

/// Requests GATT connection to a peripheral.
class ConnectDevice extends BleConnectionEvent {
  const ConnectDevice({required this.deviceId, required this.deviceName});

  final String deviceId;
  final String deviceName;

  @override
  List<Object?> get props => [deviceId, deviceName];
}

/// Request disconnect from a peripheral.
class DisconnectDevice extends BleConnectionEvent {
  const DisconnectDevice({required this.deviceId});

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

/// Discovers GATT services for the current connected peripheral.
class DiscoverServices extends BleConnectionEvent {
  const DiscoverServices({required this.deviceId});

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

/// Triggered when the peripheral's connection state shifts.
class UpdateConnectionStatus extends BleConnectionEvent {
  const UpdateConnectionStatus({required this.deviceId, required this.status});

  final String deviceId;
  final BleConnectionStatus status;

  @override
  List<Object?> get props => [deviceId, status];
}
