// lib/features/receipt_scan/domain/entities/parking_session.dart
import 'package:equatable/equatable.dart';

class ParkingSession extends Equatable {
  final String id;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double totalSpend;
  final int freeHours;
  final int usedHours;
  final double chargeAmount;
  final List<String> receiptIds;

  const ParkingSession({
    required this.id, required this.entryTime, this.exitTime,
    required this.totalSpend, required this.freeHours,
    required this.usedHours, required this.chargeAmount,
    required this.receiptIds,
  });

  bool get canExitFree => chargeAmount == 0;

  @override
  List<Object?> get props => [id, entryTime, totalSpend, freeHours];
}
