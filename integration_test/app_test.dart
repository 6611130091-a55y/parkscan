// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkscan/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ParkScan E2E', () {
    testWidgets('เปิดแอปแสดงหน้าหลัก', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('ParkScan'), findsOneWidget);
    });

    testWidgets('Bottom nav มี 3 tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('สแกน'),     findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('ประวัติ'),  findsOneWidget);
    });

    testWidgets('กด Dashboard tab เปลี่ยนหน้า', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('สรุปภาพรวม'), findsOneWidget);
    });

    testWidgets('กด ประวัติ tab เปลี่ยนหน้า', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('ประวัติ'));
      await tester.pumpAndSettle();
      expect(find.text('ประวัติการจอดรถ'), findsOneWidget);
    });
  });
}
