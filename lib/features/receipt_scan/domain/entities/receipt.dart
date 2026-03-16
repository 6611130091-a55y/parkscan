// lib/features/receipt_scan/domain/entities/receipt.dart
import 'package:equatable/equatable.dart';

enum ReceiptCategory { shopping, restaurant, beverageBakery, unknown }

extension ReceiptCategoryLabel on ReceiptCategory {
  String get label {
    switch (this) {
      case ReceiptCategory.shopping:      return 'Shopping';
      case ReceiptCategory.restaurant:    return 'ร้านอาหาร';
      case ReceiptCategory.beverageBakery: return 'เครื่องดื่ม/เบเกอรี่';
      case ReceiptCategory.unknown:       return 'ไม่ระบุ';
    }
  }
}

class Receipt extends Equatable {
  final String id;
  final String storeName;
  final double totalAmount;
  final DateTime receiptDate;
  final ReceiptCategory category;
  final String rawText;
  final String imagePath;
  final DateTime createdAt;

  const Receipt({
    required this.id, required this.storeName, required this.totalAmount,
    required this.receiptDate, required this.category, required this.rawText,
    required this.imagePath, required this.createdAt,
  });

  @override
  List<Object?> get props => [id, storeName, totalAmount, receiptDate, category];
}
