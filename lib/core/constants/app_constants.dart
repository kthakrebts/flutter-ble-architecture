/// Class holding application-wide configuration, timeouts, and storage keys.
class AppConstants {
  AppConstants._();

  // Storage Box Names
  static const String settingsBox = 'app_settings_box';
  static const String bleLogsBox = 'ble_logs_box';

  // Hive Cache Keys
  static const String keyThemeMode = 'theme_mode_key';
  static const String keyLogList = 'ble_log_list_key';

  // BLE Configuration
  static const Duration bleScanDuration = Duration(seconds: 10);
  static const Duration bleConnectionTimeout = Duration(seconds: 15);
  static const int bleMaxRetryAttempts = 3;

  // UI Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationDefault = Duration(milliseconds: 350);

  // Design Tokens
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;

  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
}
