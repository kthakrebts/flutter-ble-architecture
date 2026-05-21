import 'dart:async';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/core/error/exceptions.dart';
import 'package:flutter_ble_architecture/core/logger/app_logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Concrete implementation of [BleRepository] leveraging the [FlutterBluePlus] library.
class BleRepositoryImpl implements BleRepository {
  BleRepositoryImpl();

  static const String _tag = 'BleRepositoryImpl';

  @override
  Stream<List<BleDevice>> get scanResults {
    return FlutterBluePlus.scanResults.map((results) {
      return results.map((r) {
        return BleDevice(
          id: r.device.remoteId.str,
          name: r.device.platformName.isNotEmpty
              ? r.device.platformName
              : 'Unknown Device',
          rssi: r.rssi,
          isConnectable: r.advertisementData.connectable,
          serviceUuids: r.advertisementData.serviceUuids
              .map((g) => g.toString())
              .toList(),
        );
      }).toList();
    });
  }

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Future<void> startScan({List<String>? serviceUuids}) async {
    try {
      AppLogger.i('Starting BLE scan...', tag: _tag);
      final uuids = serviceUuids?.map(Guid.new).toList() ?? [];

      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      await FlutterBluePlus.startScan(
        withServices: uuids,
        timeout: const Duration(seconds: 15),
      );
    } catch (e, stack) {
      AppLogger.e(
        'Failed to start scan: $e',
        tag: _tag,
        error: e,
        stackTrace: stack,
      );
      throw BleException('Failed to start BLE scan: ${e.toString()}');
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      AppLogger.i('Stopping BLE scan...', tag: _tag);
      await FlutterBluePlus.stopScan();
    } catch (e) {
      AppLogger.e('Failed to stop scan: $e', tag: _tag);
      throw BleException('Failed to stop BLE scan: ${e.toString()}');
    }
  }

  @override
  Future<void> connect(String deviceId) async {
    try {
      AppLogger.i('Connecting to device: $deviceId', tag: _tag);
      final device = BluetoothDevice.fromId(deviceId);

      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
    } catch (e, stack) {
      AppLogger.e(
        'Failed to connect to device $deviceId: $e',
        tag: _tag,
        error: e,
        stackTrace: stack,
      );
      throw BleException('Connection failed: ${e.toString()}');
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    try {
      AppLogger.i('Disconnecting from device: $deviceId', tag: _tag);
      final device = BluetoothDevice.fromId(deviceId);
      await device.disconnect();
    } catch (e) {
      AppLogger.e('Failed to disconnect device $deviceId: $e', tag: _tag);
      throw BleException('Disconnection failed: ${e.toString()}');
    }
  }

  @override
  Stream<BleConnectionStatus> monitorConnection(String deviceId) {
    final device = BluetoothDevice.fromId(deviceId);
    return device.connectionState.map((state) {
      switch (state) {
        case BluetoothConnectionState.disconnected:
          return BleConnectionStatus.disconnected;
        case BluetoothConnectionState.connecting:
          return BleConnectionStatus.connecting;
        case BluetoothConnectionState.connected:
          return BleConnectionStatus.connected;
        case BluetoothConnectionState.disconnecting:
          return BleConnectionStatus.disconnecting;
      }
    });
  }

  @override
  Future<List<String>> discoverServices(String deviceId) async {
    try {
      AppLogger.i('Discovering services for device: $deviceId', tag: _tag);
      final device = BluetoothDevice.fromId(deviceId);
      final services = await device.discoverServices();
      return services.map((s) => s.uuid.toString()).toList();
    } catch (e) {
      AppLogger.e(
        'Failed to discover services for device $deviceId: $e',
        tag: _tag,
      );
      throw BleException('Service discovery failed: ${e.toString()}');
    }
  }
}
