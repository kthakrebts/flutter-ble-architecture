import 'package:equatable/equatable.dart';

/// Represents a scanned BLE peripheral in the domain layer.
class BleDevice extends Equatable {
  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnectable,
    this.serviceUuids = const [],
  });

  /// The unique hardware address / UUID of the BLE peripheral.
  final String id;

  /// The broadcasted name of the device (defaults to 'Unknown Device').
  final String name;

  /// Received Signal Strength Indicator (RSSI) indicating signal strength.
  final int rssi;

  /// Indicates if the peripheral allows GATT connection.
  final bool isConnectable;

  /// List of advertised Service UUIDs.
  final List<String> serviceUuids;

  @override
  List<Object?> get props => [id, name, rssi, isConnectable, serviceUuids];
}
