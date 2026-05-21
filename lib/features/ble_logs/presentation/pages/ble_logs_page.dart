import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/core/di/injection_container.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_event.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class BleLogsPage extends StatelessWidget {
  const BleLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BleLogsBloc>()..add(LoadLogs()),
      child: const _BleLogsView(),
    );
  }
}

class _BleLogsView extends StatelessWidget {
  const _BleLogsView();

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return Colors.redAccent;
      case 'WARN':
      case 'WARNING':
        return Colors.orangeAccent;
      case 'DEBUG':
        return Colors.blueAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry Logs'),
        actions: [
          IconButton(
            tooltip: 'Clear telemetry cache',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              context.read<BleLogsBloc>().add(ClearLogs());
            },
          ),
        ],
      ),
      body: BlocBuilder<BleLogsBloc, BleLogsState>(
        builder: (context, state) {
          if (state.status == BleLogsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.terminal_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withAlpha(64),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Telemetry Data Available',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Perform scans or connect to peripherals to populate logs.',
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF070A13), // Deep terminal black
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withAlpha(51), width: 1.5),
            ),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final entry = state.logs[index];
                final timeStr = entry.timestamp.toIso8601String().substring(
                  11,
                  19,
                );
                final levelColor = _getLevelColor(entry.level);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '[$timeStr] ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: '[${entry.level}] ',
                          style: TextStyle(
                            color: levelColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (entry.deviceId != null)
                          TextSpan(
                            text: '(${entry.deviceId}) ',
                            style: const TextStyle(color: Colors.cyanAccent),
                          ),
                        TextSpan(
                          text: entry.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
