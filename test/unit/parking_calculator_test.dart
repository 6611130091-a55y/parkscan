// test/unit/parking_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:parkscan/core/utils/parking_calculator.dart';

void main() {
  final entry = DateTime(2025, 6, 1, 10, 0);

  group('freeHoursFromSpend', () {
    test('ยอด 0 → 0 ชม.จากยอด', () =>
        expect(ParkingCalculator.freeHoursFromSpend(0), 0));
    test('ยอด 499 → 0 ชม.จากยอด', () =>
        expect(ParkingCalculator.freeHoursFromSpend(499), 0));
    test('ยอด 500 → 2 ชม.จากยอด', () =>
        expect(ParkingCalculator.freeHoursFromSpend(500), 2));
    test('ยอด 1000 → 4 ชม.จากยอด', () =>
        expect(ParkingCalculator.freeHoursFromSpend(1000), 4));
  });

  group('calculate', () {
    test('จอด 1 ชม. ไม่ซื้อ → ฟรี ไม่มีค่าจอด', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 1)),
        totalSpend: 0,
      );
      expect(r.chargeAmount, 0);
      expect(r.isOvertime, false);
    });

    test('จอด 2 ชม. ไม่ซื้อ → เกิน 1 ชม. จ่าย 20 บาท', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 2)),
        totalSpend: 0,
      );
      expect(r.chargeAmount, 20.0);
      expect(r.isOvertime, true);
    });

    test('จอด 3 ชม. ซื้อ 500 → ฟรี 3 ชม. (1+2)', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 3)),
        totalSpend: 500,
      );
      expect(r.freeHours, 3);
      expect(r.chargeAmount, 0);
    });

    test('จอด 4 ชม. ซื้อ 500 → เกิน 1 ชม. จ่าย 20 บาท', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 4)),
        totalSpend: 500,
      );
      expect(r.chargeAmount, 20.0);
    });

    test('จอด 5 ชม. ซื้อ 1000 → ฟรี 5 ชม. (1+4)', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 5)),
        totalSpend: 1000,
      );
      expect(r.freeHours, 5);
      expect(r.chargeAmount, 0);
    });

    test('จอด 7 ชม. ซื้อ 1000 → เกิน 2 ชม. จ่าย 40 บาท', () {
      final r = ParkingCalculator.calculate(
        entryTime: entry,
        exitTime: entry.add(const Duration(hours: 7)),
        totalSpend: 1000,
      );
      expect(r.chargeAmount, 40.0);
    });
  });

  group('isReceiptValidForSession', () {
    test('วันตรงกัน → true', () {
      expect(
        ParkingCalculator.isReceiptValidForSession(
          receiptDate: DateTime(2025, 6, 1, 14, 0),
          entryDate:   DateTime(2025, 6, 1, 9, 0),
        ),
        true,
      );
    });

    test('วันต่างกัน → false', () {
      expect(
        ParkingCalculator.isReceiptValidForSession(
          receiptDate: DateTime(2025, 6, 2, 9, 0),
          entryDate:   DateTime(2025, 6, 1, 9, 0),
        ),
        false,
      );
    });
  });
}
