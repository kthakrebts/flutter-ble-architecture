import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';
import 'package:flutter_ble_architecture/core/di/injection_container.dart';
import 'package:flutter_ble_architecture/core/routing/app_router.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_event.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanPage extends StatelessWidget {
  const BleScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BleScanBloc>(),
      child: const _BleScanView(),
    );
  }
}

class _BleScanView extends StatefulWidget {
  const _BleScanView();

  @override
  State<_BleScanView> createState() => _BleScanViewState();
}

class _BleScanViewState extends State<_BleScanView> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if ((status[Permission.bluetoothScan]?.isGranted ?? false) && mounted) {
      context.read<BleScanBloc>().add(const StartScan());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Device Discovery'),
        actions: [
          BlocBuilder<BleScanBloc, BleScanState>(
            builder: (context, state) {
              if (state.isScanning) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, state) {
          if (state.status == BleScanStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan Initialization Failed',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.failure?.message ?? 'Unknown error occurred.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<BleScanBloc>().add(const StartScan()),
                      child: const Text('Retry Scan'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 64,
                    color: theme.colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No BLE Devices Discovered',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ensure Bluetooth is enabled and permissions granted.',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.devices.length,
            itemBuilder: (context, index) {
              final device = state.devices[index];
              return _DeviceCard(
                device: device,
                onTap: () {
                  context.read<BleScanBloc>().add(StopScan());
                  context.push(
                    AppRouter.routeDeviceDetails,
                    extra: {'deviceId': device.id, 'deviceName': device.name},
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (state.isScanning) {
                context.read<BleScanBloc>().add(StopScan());
              } else {
                context.read<BleScanBloc>().add(const StartScan());
              }
            },
            icon: Icon(state.isScanning ? Icons.stop : Icons.search),
            label: Text(
              state.isScanning ? 'STOP DISCOVERY' : 'START DISCOVERY',
            ),
            backgroundColor: state.isScanning
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onTap});

  final BleDevice device;
  final VoidCallback onTap;

  Color _getRssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rssiColor = _getRssiColor(device.rssi);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            device.isConnectable ? Icons.bluetooth : Icons.bluetooth_disabled,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              device.id,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            ),
            if (device.serviceUuids.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Services: ${device.serviceUuids.length}',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${device.rssi} dBm',
                  style: TextStyle(
                    color: rssiColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: rssiColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ((device.rssi + 100) / 60).clamp(0.1, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: rssiColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
