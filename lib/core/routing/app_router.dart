import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/pages/ble_connection_page.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/pages/ble_logs_page.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/pages/ble_scan_page.dart';
import 'package:flutter_ble_architecture/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_ble_architecture/shared/widgets/splash_screen.dart';
import 'package:go_router/go_router.dart';

/// Centralized routing configuration for the application.
class AppRouter {
  AppRouter._();

  static const String routeSplash = '/splash';
  static const String routeDashboard = '/';
  static const String routeScan = '/scan';
  static const String routeDeviceDetails = '/device-details';
  static const String routeLogs = '/logs';

  static final GoRouter router = GoRouter(
    initialLocation: routeSplash,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: routeSplash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: routeDashboard,
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const DashboardPage(),
      ),
      GoRoute(
        path: routeScan,
        name: 'scan',
        builder: (BuildContext context, GoRouterState state) =>
            const BleScanPage(),
      ),
      GoRoute(
        path: routeDeviceDetails,
        name: 'device-details',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final deviceId = extra?['deviceId'] as String? ?? '';
          final deviceName =
              extra?['deviceName'] as String? ?? 'Unknown Device';

          return BleConnectionPage(deviceId: deviceId, deviceName: deviceName);
        },
      ),
      GoRoute(
        path: routeLogs,
        name: 'logs',
        builder: (BuildContext context, GoRouterState state) =>
            const BleLogsPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Navigation error: ${state.error}'))),
  );
}
