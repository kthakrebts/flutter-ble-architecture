/// Represents the current connection status of a BLE device.
enum BleConnectionStatus {
  /// The device is disconnected from the host.
  disconnected,

  /// A connection request is in progress.
  connecting,

  /// The device is successfully connected and GATT services are available.
  connected,

  /// A disconnection request is in progress.
  disconnecting,
}
