import 'package:equatable/equatable.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';
import 'package:flutter_ble_architecture/core/error/failures.dart';

/// Enum representing high level status of the scanning bloc.
enum BleScanStatus { initial, scanning, success, failure }

/// Represents the state of the BLE scanner.
class BleScanState extends Equatable {
  const BleScanState({
    this.status = BleScanStatus.initial,
    this.devices = const [],
    this.isScanning = false,
    this.failure,
  });

  final BleScanStatus status;
  final List<BleDevice> devices;
  final bool isScanning;
  final Failure? failure;

  BleScanState copyWith({
    BleScanStatus? status,
    List<BleDevice>? devices,
    bool? isScanning,
    Failure? failure,
  }) {
    return BleScanState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, devices, isScanning, failure];
}
