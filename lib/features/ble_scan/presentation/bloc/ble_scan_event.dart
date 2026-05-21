import 'package:equatable/equatable.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';

/// Base event class for BLE Scanning features.
abstract class BleScanEvent extends Equatable {
  const BleScanEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers search for nearby BLE peripherals.
class StartScan extends BleScanEvent {
  const StartScan({this.serviceUuids});

  final List<String>? serviceUuids;

  @override
  List<Object?> get props => [serviceUuids];
}

/// Forcefully terminates active BLE scans.
class StopScan extends BleScanEvent {}

/// Triggered when native scanner broadcasts new results.
class UpdateScanResults extends BleScanEvent {
  const UpdateScanResults(this.devices);

  final List<BleDevice> devices;

  @override
  List<Object?> get props => [devices];
}

/// Triggered when scan active state changes.
class UpdateScanningStatus extends BleScanEvent {
  const UpdateScanningStatus({required this.isScanning});

  final bool isScanning;

  @override
  List<Object?> get props => [isScanning];
}
