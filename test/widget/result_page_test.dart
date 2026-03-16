// test/widget/result_page_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parkscan/core/theme/app_theme.dart';
import 'package:parkscan/features/receipt_scan/presentation/bloc/scan_bloc.dart';
import 'package:parkscan/features/receipt_scan/presentation/pages/result_page.dart';

class MockScanBloc extends MockBloc<ScanEvent, ScanState>
    implements ScanBloc {}

Widget _wrap(Widget child, ScanBloc bloc) => MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<ScanBloc>.value(
        value: bloc,
        child: child,
      ),
    );

void main() {
  late MockScanBloc mockBloc;

  setUp(() {
    mockBloc = MockScanBloc();
    when(() => mockBloc.state).thenReturn(ScanInitial());
  });

  testWidgets('แสดงฟิลด์ชื่อร้าน, ยอดเงิน, วันที่', (tester) async {
    await tester.pumpWidget(_wrap(
      ResultPage(imagePath: '', onConfirm: (_) {}),
      mockBloc,
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('ชื่อร้านค้า'), findsOneWidget);
    expect(find.text('ยอดรวม (บาท)'), findsOneWidget);
    expect(find.text('วันที่ในใบเสร็จ'), findsOneWidget);
  });

  testWidgets('Validation: กด confirm โดยไม่กรอก storeName → แสดง error',
      (tester) async {
    await tester.pumpWidget(_wrap(
      ResultPage(imagePath: '', onConfirm: (_) {}),
      mockBloc,
    ));
    await tester.pump(const Duration(seconds: 2));

    // Clear store name
    final storeField = find.widgetWithText(TextFormField, 'Central World');
    await tester.tap(storeField);
    await tester.pump();
    await tester.enterText(storeField, '');
    await tester.pump();

    // Tap confirm
    await tester.tap(find.text('ยืนยันและบันทึก'));
    await tester.pump();

    expect(find.text('กรุณาระบุชื่อร้าน'), findsOneWidget);
  });

  testWidgets('Validation: กรอก amount เป็นตัวอักษร → แสดง error',
      (tester) async {
    await tester.pumpWidget(_wrap(
      ResultPage(imagePath: '', onConfirm: (_) {}),
      mockBloc,
    ));
    await tester.pump(const Duration(seconds: 2));

    final amountField = find.widgetWithText(TextFormField, '650');
    await tester.tap(amountField);
    await tester.pump();
    await tester.enterText(amountField, 'abc');
    await tester.pump();

    await tester.tap(find.text('ยืนยันและบันทึก'));
    await tester.pump();

    expect(find.text('ตัวเลขไม่ถูกต้อง'), findsOneWidget);
  });

  testWidgets('แสดง 3 category chips', (tester) async {
    await tester.pumpWidget(_wrap(
      ResultPage(imagePath: '', onConfirm: (_) {}),
      mockBloc,
    ));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('ร้านอาหาร'), findsOneWidget);
    expect(find.text('เครื่องดื่ม'), findsOneWidget);
  });
}
