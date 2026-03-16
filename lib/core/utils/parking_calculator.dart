// lib/core/utils/parking_calculator.dart
class ParkingResult {
  final int freeHours;
  final int parkedMinutes;
  final int parkedHours;
  final double chargeAmount;
  final bool isOvertime;
  final String summary;
  const ParkingResult({
    required this.freeHours, required this.parkedMinutes,
    required this.parkedHours, required this.chargeAmount,
    required this.isOvertime, required this.summary,
  });
}

class ParkingCalculator {
  static const double _rate = 20.0;

  static int freeHoursFromSpend(double spend) {
    if (spend >= 1000) return 4;
    if (spend >= 500)  return 2;
    return 0;
  }

  static bool isReceiptValidForSession({
    required DateTime receiptDate, required DateTime entryDate,
  }) =>
      receiptDate.year  == entryDate.year  &&
      receiptDate.month == entryDate.month &&
      receiptDate.day   == entryDate.day;

  static ParkingResult calculate({
    required DateTime entryTime,
    required DateTime exitTime,
    required double totalSpend,
  }) {
    final parkedMins    = exitTime.difference(entryTime).inMinutes;
    final parkedHrsCeil = (parkedMins / 60).ceil();
    final spendFree     = freeHoursFromSpend(totalSpend);
    final totalFree     = 1 + spendFree;
    final chargeableMins = parkedMins - totalFree * 60;
    final chargeableHrs  = chargeableMins > 0 ? (chargeableMins / 60).ceil() : 0;
    final charge         = chargeableHrs * _rate;

    final h = parkedMins ~/ 60, m = parkedMins % 60;
    final sb = StringBuffer()
      ..writeln('⏱ จอดรถ: $h ชม. $m นาที')
      ..writeln('🎁 ฟรี: $totalFree ชม.')
      ..writeln(totalSpend > 0 ? '🧾 ยอดซื้อ: ฿${totalSpend.toStringAsFixed(2)}' : '')
      ..writeln(charge > 0 ? '💳 ค่าจอดเพิ่ม: ฿${charge.toStringAsFixed(2)}' : '✅ ออกได้ฟรี!');

    return ParkingResult(
      freeHours: totalFree, parkedMinutes: parkedMins,
      parkedHours: parkedHrsCeil, chargeAmount: charge,
      isOvertime: charge > 0, summary: sb.toString(),
    );
  }
}
