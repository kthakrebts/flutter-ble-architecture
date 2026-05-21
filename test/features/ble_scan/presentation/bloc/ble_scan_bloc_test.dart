import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_ble_architecture/core/ble/domain/entities/ble_device.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_event.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_state.dart';

class MockBleRepository extends Mock implements BleRepository {}

void main() {
  late BleRepository bleRepository;
  late BleScanBloc bleScanBloc;

  setUp(() {
    bleRepository = MockBleRepository();
    // Stub the streams so initialization does not throw or block
    when(() => bleRepository.scanResults).thenAnswer((_) => const Stream.empty());
    when(() => bleRepository.isScanning).thenAnswer((_) => const Stream.empty());
    bleScanBloc = BleScanBloc(bleRepository: bleRepository);
  });

  tearDown(() {
    bleScanBloc.close();
  });

  group('BleScanBloc', () {
    test('initial state is default values', () {
      expect(bleScanBloc.state, const BleScanState());
    });

    blocTest<BleScanBloc, BleScanState>(
      'emits scanning status and calls startScan when StartScan is added',
      setUp: () {
        when(() => bleRepository.startScan(serviceUuids: any(named: 'serviceUuids')))
            .thenAnswer((_) async {});
      },
      build: () => bleScanBloc,
      act: (bloc) => bloc.add(const StartScan()),
      expect: () => [
        const BleScanState(status: BleScanStatus.scanning),
      ],
      verify: (_) {
        verify(() => bleRepository.startScan()).called(1);
      },
    );

    blocTest<BleScanBloc, BleScanState>(
      'emits success status and device list when UpdateScanResults is received',
      build: () => bleScanBloc,
      act: (bloc) => bloc.add(const UpdateScanResults([
        BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Telemetry Hub', rssi: -55, isConnectable: true),
      ])),
      expect: () => [
        const BleScanState(
          status: BleScanStatus.success,
          devices: [
            BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Telemetry Hub', rssi: -55, isConnectable: true),
          ],
        ),
      ],
    );
  });
}
