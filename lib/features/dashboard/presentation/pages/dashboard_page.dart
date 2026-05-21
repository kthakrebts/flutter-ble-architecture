import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Control Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings placeholder
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engineering Showcase',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Clean BLE Architecture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Production-grade foundations with structured architecture, telemetry logging, and native MethodChannel interoperability.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Navigation Modules', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MenuCard(
                      title: 'Peripheral Scanner',
                      subtitle: 'Discover and connect to local BLE devices',
                      icon: Icons.bluetooth_searching,
                      color: theme.colorScheme.primary,
                      onTap: () => context.push(AppRouter.routeScan),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(
                      title: 'Telemetry Logs',
                      subtitle: 'Real-time telemetry event streams',
                      icon: Icons.terminal,
                      color: theme.colorScheme.secondary,
                      onTap: () => context.push(AppRouter.routeLogs),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Native Bridge Integration',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PlatformBridgeTile(
                        platform: 'Android Core (Kotlin)',
                        status:
                            'BleManager, BleScanner, BleConnectionManager, GattCallbackHandler',
                        icon: Icons.android,
                        statusColor: theme.colorScheme.primary,
                      ),
                      const Divider(height: 24),
                      _PlatformBridgeTile(
                        platform: 'iOS Core (Swift)',
                        status: 'BLEManager, BLEScanner, BLEConnectionManager',
                        icon: Icons.phone_iphone,
                        statusColor: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformBridgeTile extends StatelessWidget {
  const _PlatformBridgeTile({
    required this.platform,
    required this.status,
    required this.icon,
    required this.statusColor,
  });

  final String platform;
  final String status;
  final IconData icon;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(26),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor.withAlpha(51)),
          ),
          child: Text(
            'ACTIVE',
            style: TextStyle(
              color: statusColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
