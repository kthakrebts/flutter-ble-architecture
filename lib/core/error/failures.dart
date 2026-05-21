import 'package:equatable/equatable.dart';

/// Base class representing errors/failures in the domain layer.
abstract class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable error message.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents failures arising from native BLE operations (e.g. scan failures, connection drops).
class BleFailure extends Failure {
  const BleFailure(super.message, {this.errorCode});

  final String? errorCode;

  @override
  List<Object?> get props => [message, errorCode];
}

/// Represents failure to obtain critical OS-level permissions (e.g. Bluetooth, Location).
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Represents cache or local storage errors.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Fallback failure for unexpected errors.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
