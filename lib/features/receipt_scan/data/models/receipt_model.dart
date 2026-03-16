// lib/features/receipt_scan/data/models/receipt_model.dart
// รัน: flutter pub run build_runner build --delete-conflicting-outputs
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/receipt.dart';

part 'receipt_model.freezed.dart';
part 'receipt_model.g.dart';

@freezed
class ReceiptModel with _$ReceiptModel {
  const factory ReceiptModel({
    required String id,
    required String storeName,
    required double totalAmount,
    required String receiptDate,
    required String category,
    required String rawText,
    required String imagePath,
    required String createdAt,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);
}

extension ReceiptModelX on ReceiptModel {
  Receipt toDomain() => Receipt(
    id: id, storeName: storeName, totalAmount: totalAmount,
    receiptDate: DateTime.parse(receiptDate),
    category: ReceiptCategory.values.firstWhere(
      (e) => e.name == category, orElse: () => ReceiptCategory.unknown),
    rawText: rawText, imagePath: imagePath,
    createdAt: DateTime.parse(createdAt),
  );

  static ReceiptModel fromDomain(Receipt r) => ReceiptModel(
    id: r.id, storeName: r.storeName, totalAmount: r.totalAmount,
    receiptDate: r.receiptDate.toIso8601String(),
    category: r.category.name, rawText: r.rawText,
    imagePath: r.imagePath, createdAt: r.createdAt.toIso8601String(),
  );
}
