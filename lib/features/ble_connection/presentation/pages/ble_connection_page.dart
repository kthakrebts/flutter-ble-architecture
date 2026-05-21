import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_connection_status.dart';
import 'package:flutter_ble_architecture/core/di/injection_container.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_event.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_state.dart';

class BleConnectionPage extends StatelessWidget {
  const BleConnectionPage({
    required this.deviceId,
    required this.deviceName,
    super.key,
  });

  final String deviceId;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BleConnectionBloc>()
        ..add(ConnectDevice(deviceId: deviceId, deviceName: deviceName)),
      child: _BleConnectionView(deviceId: deviceId, deviceName: deviceName),
    );
  }
}

class _BleConnectionView extends StatelessWidget {
  const _BleConnectionView({
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;

  Color _getStatusColor(BleConnectionStatus status) {
    switch (status) {
      case BleConnectionStatus.connected:
        return Colors.green;
      case BleConnectionStatus.connecting:
        return Colors.amber;
      case BleConnectionStatus.disconnecting:
        return Colors.orange;
      case BleConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  String _getStatusText(BleConnectionStatus status) {
    switch (status) {
      case BleConnectionStatus.connected:
        return 'GATT CONNECTED';
      case BleConnectionStatus.connecting:
        return 'CONNECTING...';
      case BleConnectionStatus.disconnecting:
        return 'DISCONNECTING...';
      case BleConnectionStatus.disconnected:
        return 'DISCONNECTED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
      ),
      body: BlocBuilder<BleConnectionBloc, BleConnectionState>(
        builder: (context, state) {
          final statusColor = _getStatusColor(state.status);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Device Status',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withAlpha(76), width: 1.5),
                              ),
                              child: Text(
                                _getStatusText(state.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.fingerprint, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              deviceId,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            if (state.status == BleConnectionStatus.disconnected)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<BleConnectionBloc>().add(
                                      ConnectDevice(
                                        deviceId: deviceId,
                                        deviceName: deviceName,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.link),
                                  label: const Text('CONNECT'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<BleConnectionBloc>().add(
                                      DisconnectDevice(deviceId: deviceId),
                                    );
                                  },
                                  icon: const Icon(Icons.link_off),
                                  label: const Text('DISCONNECT'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.error.withAlpha(128)),
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discovered GATT Services',
                      style: theme.textTheme.titleLarge,
                    ),
                    if (state.status == BleConnectionStatus.connected)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.services.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schema_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withAlpha(64),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.status == BleConnectionStatus.connected
                                      ? 'Discovering services...'
                                      : 'Connect device to discover GATT services.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.services.length,
                          itemBuilder: (context, index) {
                            final serviceUuid = state.services[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.settings_input_component, color: Colors.grey),
                                title: Text(
                                  _resolveServiceName(serviceUuid),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  serviceUuid,
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_right),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _resolveServiceName(String uuid) {
    final cleanUuid = uuid.toUpperCase();
    if (cleanUuid.contains('1800')) return 'Generic Access Service';
    if (cleanUuid.contains('1801')) return 'Generic Attribute Service';
    if (cleanUuid.contains('180A')) return 'Device Information Service';
    if (cleanUuid.contains('180F')) return 'Battery Service';
    if (cleanUuid.contains('180D')) return 'Heart Rate Service';
    return 'Custom Service';
  }
}
