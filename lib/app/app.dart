import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/core/routing/app_router.dart';
import 'package:flutter_ble_architecture/core/theme/app_theme.dart';

/// The root Widget of the Flutter application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter BLE Clean Architecture',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to sleek developer-centric dark theme
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
