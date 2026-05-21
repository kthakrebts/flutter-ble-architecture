import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';

/// Contract representing BLE operations at the domain layer.
abstract class BleRepository {
  /// Stream emitting active list of scanned BLE peripherals.
  Stream<List<BleDevice>> get scanResults;

  /// Stream emitting scanning state (true = actively scanning).
  Stream<bool> get isScanning;

  /// Starts scanning for nearby BLE peripherals.
  /// Optional [serviceUuids] can be provided to filter devices.
  Future<void> startScan({List<String>? serviceUuids});

  /// Stops the current BLE scan.
  Future<void> stopScan();

  /// Establishes a GATT connection to a peripheral.
  Future<void> connect(String deviceId);

  /// Severs an active or pending connection to a peripheral.
  Future<void> disconnect(String deviceId);

  /// Monitors the real-time connection state of a specific device.
  Stream<BleConnectionStatus> monitorConnection(String deviceId);

  /// Discovers GATT services for a connected device and returns their UUIDs.
  Future<List<String>> discoverServices(String deviceId);
}
