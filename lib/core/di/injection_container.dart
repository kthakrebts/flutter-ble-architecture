import 'package:flutter_ble_architecture/core/ble/data/repositories/ble_repository_impl.dart';
import 'package:flutter_ble_architecture/core/ble/domain/repositories/ble_repository.dart';
import 'package:flutter_ble_architecture/core/constants/app_constants.dart';
import 'package:flutter_ble_architecture/features/ble_connection/presentation/bloc/ble_connection_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_logs/data/repositories/ble_logs_repository_impl.dart';
import 'package:flutter_ble_architecture/features/ble_logs/domain/repositories/ble_logs_repository.dart';
import 'package:flutter_ble_architecture/features/ble_logs/presentation/bloc/ble_logs_bloc.dart';
import 'package:flutter_ble_architecture/features/ble_scan/presentation/bloc/ble_scan_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initialise application dependencies, storage layer, and blocs.
Future<void> initDI() async {
  // --- Local Storage (Hive) ---
  await Hive.initFlutter();

  // Open the telemetry logs box (stores logs as JSON strings)
  final logsBox = await Hive.openBox<String>(AppConstants.bleLogsBox);

  // --- Core Services / Repositories ---
  sl
    ..registerLazySingleton<BleLogsRepository>(
      () => BleLogsRepositoryImpl(logsBox),
    )
    ..registerLazySingleton<BleRepository>(BleRepositoryImpl.new)
    // --- Features (Blocs) ---
    ..registerFactory(() => BleScanBloc(bleRepository: sl()))
    ..registerFactory(
      () => BleConnectionBloc(bleRepository: sl(), logsRepository: sl()),
    )
    ..registerFactory(() => BleLogsBloc(logsRepository: sl()));
}
