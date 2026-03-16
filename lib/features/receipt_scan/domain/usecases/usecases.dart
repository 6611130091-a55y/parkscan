// lib/features/receipt_scan/domain/usecases/scan_receipt_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/parking_session.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class ScanReceiptUseCase {
  final ReceiptRepository _repo;
  ScanReceiptUseCase(this._repo);
  Future<Either<Failure, Receipt>> call(String imagePath) =>
      _repo.scanAndClassify(imagePath);
}

// lib/features/receipt_scan/domain/usecases/calculate_parking_usecase.dart
// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../entities/parking_session.dart';
// import '../repositories/receipt_repository.dart';

class CalculateParkingParams {
  final DateTime exitTime;
  final DateTime entryDate;
  const CalculateParkingParams({required this.exitTime, required this.entryDate});
}

class CalculateParkingUseCase {
  final ReceiptRepository _repo;
  CalculateParkingUseCase(this._repo);
  Future<Either<Failure, ParkingSession>> call(CalculateParkingParams p) =>
      _repo.calculateParking(exitTime: p.exitTime, entryDate: p.entryDate);
}

// lib/features/receipt_scan/domain/usecases/get_receipts_usecase.dart
// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../entities/receipt.dart';
// import '../entities/parking_session.dart';
// import '../repositories/receipt_repository.dart';

class GetReceiptsByDateUseCase {
  final ReceiptRepository _repo;
  GetReceiptsByDateUseCase(this._repo);
  Future<Either<Failure, List<Receipt>>> call(DateTime date) =>
      _repo.getReceiptsByDate(date);
}

class GetAllReceiptsUseCase {
  final ReceiptRepository _repo;
  GetAllReceiptsUseCase(this._repo);
  Future<Either<Failure, List<Receipt>>> call() => _repo.getAllReceipts();
}

class GetParkingHistoryUseCase {
  final ReceiptRepository _repo;
  GetParkingHistoryUseCase(this._repo);
  Future<Either<Failure, List<ParkingSession>>> call() => _repo.getParkingHistory();
}

class DeleteReceiptUseCase {
  final ReceiptRepository _repo;
  DeleteReceiptUseCase(this._repo);
  Future<Either<Failure, void>> call(String id) => _repo.deleteReceipt(id);
}