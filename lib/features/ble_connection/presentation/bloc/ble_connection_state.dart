import 'package:equatable/equatable.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';
import 'package:flutter_ble_architecture/core/error/failures.dart';

/// State of the BLE device connection.
class BleConnectionState extends Equatable {
  const BleConnectionState({
    this.status = BleConnectionStatus.disconnected,
    this.deviceId = '',
    this.deviceName = '',
    this.services = const [],
    this.failure,
  });

  final BleConnectionStatus status;
  final String deviceId;
  final String deviceName;
  final List<String> services;
  final Failure? failure;

  BleConnectionState copyWith({
    BleConnectionStatus? status,
    String? deviceId,
    String? deviceName,
    List<String>? services,
    Failure? failure,
  }) {
    return BleConnectionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      services: services ?? this.services,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, deviceId, deviceName, services, failure];
}
