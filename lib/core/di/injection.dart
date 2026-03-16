// lib/core/di/injection.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/receipt_scan/data/datasources/local/app_database.dart';
import '../../features/receipt_scan/data/datasources/local/ml_kit_ds.dart';
import '../../features/receipt_scan/data/datasources/remote/gemini_ds.dart';
import '../../features/receipt_scan/data/repositories/receipt_repository_impl.dart';
import '../../features/receipt_scan/domain/repositories/receipt_repository.dart';
import '../../features/receipt_scan/domain/usecases/usecases.dart';
import '../../features/receipt_scan/presentation/bloc/scan_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Hive cache ───────────────────────────────────────────
  final cache = await Hive.openBox('gemini_cache');
  sl.registerSingleton(cache);

  // ── Dio ──────────────────────────────────────────────────
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.addAll([
    LogInterceptor(
      requestBody: kDebugMode,
      responseBody: false,
      logPrint: (o) => debugPrint('[DIO] $o'),
    ),
    InterceptorsWrapper(
      onError: (e, h) { debugPrint('[DIO ERR] ${e.message}'); h.next(e); },
    ),
  ]);
  sl.registerSingleton<Dio>(dio);

  // ── Datasources ──────────────────────────────────────────
  sl.registerLazySingleton<AppDatabase>(() => AppDatabaseImpl());
  sl.registerLazySingleton<MlKitDataSource>(() => MlKitDataSourceImpl());
  sl.registerLazySingleton<GeminiDataSource>(() => GeminiDataSourceImpl(
    dio: sl<Dio>(), cache: sl(), apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  ));

  // ── Repository ───────────────────────────────────────────
  sl.registerLazySingleton<ReceiptRepository>(() => ReceiptRepositoryImpl(
    db: sl<AppDatabase>(), mlKit: sl<MlKitDataSource>(),
    gemini: sl<GeminiDataSource>(),
  ));

  // ── Use cases ────────────────────────────────────────────
  sl.registerLazySingleton(() => ScanReceiptUseCase(sl<ReceiptRepository>()));
  sl.registerLazySingleton(() => CalculateParkingUseCase(sl<ReceiptRepository>()));
  sl.registerLazySingleton(() => GetReceiptsByDateUseCase(sl<ReceiptRepository>()));
  sl.registerLazySingleton(() => GetAllReceiptsUseCase(sl<ReceiptRepository>()));
  sl.registerLazySingleton(() => GetParkingHistoryUseCase(sl<ReceiptRepository>()));
  sl.registerLazySingleton(() => DeleteReceiptUseCase(sl<ReceiptRepository>()));

  // ── BLoC ─────────────────────────────────────────────────
  sl.registerFactory(() => ScanBloc(
    scan: sl(), calc: sl(), getByDate: sl(), delete: sl(), repo: sl(),
  ));
}
