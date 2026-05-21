import 'package:flutter/material.dart';
import 'package:flutter_ble_architecture/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(AppRouter.routeDashboard);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.surface, theme.scaffoldBackgroundColor],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(26),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(51),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.bluetooth,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BLE ARCHITECTURE',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Production-Grade Engineering Foundation',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
