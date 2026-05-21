/// Exception thrown during native BLE operations.
class BleException implements Exception {
  BleException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'BleException: $message (code: $errorCode)';
}

/// Exception thrown when required OS permissions are denied.
class PermissionException implements Exception {
  PermissionException(this.message);
  final String message;

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when local cache or DB operations fail.
class CacheException implements Exception {
  CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
