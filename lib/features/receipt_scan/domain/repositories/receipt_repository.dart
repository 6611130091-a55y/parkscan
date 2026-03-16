// lib/features/receipt_scan/domain/repositories/receipt_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/receipt.dart';
import '../entities/parking_session.dart';

abstract class ReceiptRepository {
  Future<Either<Failure, Receipt>> scanAndClassify(String imagePath);
  Future<Either<Failure, List<Receipt>>> getReceiptsByDate(DateTime date);
  Future<Either<Failure, List<Receipt>>> getAllReceipts();
  Future<Either<Failure, ParkingSession>> startParkingSession(DateTime entryTime);
  Future<Either<Failure, ParkingSession>> calculateParking({required DateTime exitTime, required DateTime entryDate});
  Future<Either<Failure, ParkingSession?>> getActiveParkingSession();
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory();
  Future<Either<Failure, void>> deleteReceipt(String id);
}
