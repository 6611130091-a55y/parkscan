// lib/features/receipt_scan/data/repositories/receipt_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/parking_calculator.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/parking_session.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/ml_kit_ds.dart';
import '../datasources/remote/gemini_ds.dart';
import '../models/receipt_model.dart';
import '../models/parking_session_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final AppDatabase     _db;
  final MlKitDataSource _mlKit;
  final GeminiDataSource _gemini;
  final _uuid = const Uuid();

  ReceiptRepositoryImpl({
    required AppDatabase db,
    required MlKitDataSource mlKit,
    required GeminiDataSource gemini,
  }) : _db = db, _mlKit = mlKit, _gemini = gemini;

  // ── Scan & classify ──────────────────────────────────────
  @override
  Future<Either<Failure, Receipt>> scanAndClassify(String imagePath) async {
    try {
      final raw = await _mlKit.extractText(imagePath);
      if (raw.isEmpty) return Left(ScanFailure('ไม่พบข้อความในภาพ'));

      final r = await _gemini.classify(raw);
      final model = ReceiptModel(
        id: _uuid.v4(),
        storeName: r.storeName,
        totalAmount: r.totalAmount,
        receiptDate: r.receiptDateIso.isNotEmpty
            ? r.receiptDateIso
            : DateTime.now().toIso8601String().substring(0, 10),
        category: r.category,
        rawText: raw,
        imagePath: imagePath,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.saveReceipt(model);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  // ── Receipts ─────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Receipt>>> getReceiptsByDate(DateTime date) async {
    try {
      final list = await _db.getReceiptsByDate(date);
      return Right(list.map((m) => m.toDomain()).toList());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<Receipt>>> getAllReceipts() async {
    try {
      final list = await _db.getAllReceipts();
      return Right(list.map((m) => m.toDomain()).toList());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, void>> deleteReceipt(String id) async {
    try {
      await _db.deleteReceipt(id);
      return const Right(null);
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  // ── Parking Session ──────────────────────────────────────
  @override
  Future<Either<Failure, ParkingSession>> startParkingSession(DateTime entry) async {
    try {
      final s = ParkingSessionModel(
        id: _uuid.v4(), entryTime: entry.toIso8601String(),
        totalSpend: 0, freeHours: 1, usedHours: 0,
        chargeAmount: 0, receiptIds: [],
      );
      await _db.saveParkingSession(s);
      return Right(s.toDomain());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, ParkingSession>> calculateParking({
    required DateTime exitTime, required DateTime entryDate,
  }) async {
    try {
      final sm = await _db.getActiveParkingSession();
      if (sm == null) return Left(DatabaseFailure('ไม่พบ session'));

      final receipts = await _db.getReceiptsByDate(entryDate);
      final valid = receipts.where((r) =>
        ParkingCalculator.isReceiptValidForSession(
          receiptDate: DateTime.parse(r.receiptDate),
          entryDate: entryDate,
        )).toList();

      final spend  = valid.fold<double>(0, (s, r) => s + r.totalAmount);
      final entry  = DateTime.parse(sm.entryTime);
      final result = ParkingCalculator.calculate(
        entryTime: entry, exitTime: exitTime, totalSpend: spend);

      final updated = sm.copyWith(
        exitTime: exitTime.toIso8601String(),
        totalSpend: spend, freeHours: result.freeHours,
        usedHours: result.parkedHours, chargeAmount: result.chargeAmount,
        receiptIds: valid.map((r) => r.id).toList(),
      );
      await _db.updateParkingSession(updated);
      return Right(updated.toDomain());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, ParkingSession?>> getActiveParkingSession() async {
    try {
      final m = await _db.getActiveParkingSession();
      return Right(m?.toDomain());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory() async {
    try {
      final list = await _db.getAllParkingSessions();
      return Right(list.map((m) => m.toDomain()).toList());
    } catch (e) { return Left(DatabaseFailure(e.toString())); }
  }
}
