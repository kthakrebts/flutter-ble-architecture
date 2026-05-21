import 'package:flutter_ble_architecture/app/app.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/core/di/injection_container.dart';
import 'package:flutter_ble_architecture/features/ble_logs/domain/repositories/ble_logs_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBleRepository extends Mock implements BleRepository {}

class MockBleLogsRepository extends Mock implements BleLogsRepository {}

void main() {
  setUpAll(() {
    // Stub global dependencies inside the locator for widget testing
    final mockBle = MockBleRepository();
    final mockLogs = MockBleLogsRepository();

    when(() => mockBle.scanResults).thenAnswer((_) => const Stream.empty());
    when(() => mockBle.isScanning).thenAnswer((_) => const Stream.empty());

    sl
      ..registerLazySingleton<BleRepository>(() => mockBle)
      ..registerLazySingleton<BleLogsRepository>(() => mockLogs);
  });

  testWidgets('App renders splash screen initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    expect(find.text('BLE ARCHITECTURE'), findsOneWidget);
    expect(
      find.text('Production-Grade Engineering Foundation'),
      findsOneWidget,
    );

    // Let the splash navigation timer complete and settle to avoid test leaks
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
