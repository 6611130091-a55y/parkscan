// lib/features/receipt_scan/data/models/parking_session_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/parking_session.dart';

part 'parking_session_model.freezed.dart';
part 'parking_session_model.g.dart';

@freezed
class ParkingSessionModel with _$ParkingSessionModel {
  const factory ParkingSessionModel({
    required String id,
    required String entryTime,
    String? exitTime,
    required double totalSpend,
    required int freeHours,
    required int usedHours,
    required double chargeAmount,
    required List<String> receiptIds,
  }) = _ParkingSessionModel;

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingSessionModelFromJson(json);
}

extension ParkingSessionModelX on ParkingSessionModel {
  ParkingSession toDomain() => ParkingSession(
    id: id, entryTime: DateTime.parse(entryTime),
    exitTime: exitTime != null ? DateTime.parse(exitTime!) : null,
    totalSpend: totalSpend, freeHours: freeHours,
    usedHours: usedHours, chargeAmount: chargeAmount,
    receiptIds: receiptIds,
  );
}
