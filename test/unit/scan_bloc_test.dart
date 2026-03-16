// test/unit/scan_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parkscan/core/error/failures.dart';
import 'package:parkscan/features/receipt_scan/domain/entities/receipt.dart';
import 'package:parkscan/features/receipt_scan/domain/entities/parking_session.dart';
import 'package:parkscan/features/receipt_scan/domain/repositories/receipt_repository.dart';
import 'package:parkscan/features/receipt_scan/domain/usecases/usecases.dart';
import 'package:parkscan/features/receipt_scan/presentation/bloc/scan_bloc.dart';

// ── Mocks ────────────────────────────────────────────────
class MockScanReceiptUseCase      extends Mock implements ScanReceiptUseCase {}
class MockCalculateParkingUseCase extends Mock implements CalculateParkingUseCase {}
class MockGetReceiptsByDate       extends Mock implements GetReceiptsByDateUseCase {}
class MockDeleteReceiptUseCase    extends Mock implements DeleteReceiptUseCase {}
class MockReceiptRepository       extends Mock implements ReceiptRepository {}
class FakeCalculateParkingParams  extends Fake implements CalculateParkingParams {}

// ── Test data ─────────────────────────────────────────────
final _receipt = Receipt(
  id: 'r1', storeName: 'Central World', totalAmount: 650,
  receiptDate: DateTime(2025, 6, 1), category: ReceiptCategory.shopping,
  rawText: 'test', imagePath: '/img.jpg', createdAt: DateTime(2025, 6, 1),
);

final _session = ParkingSession(
  id: 's1', entryTime: DateTime(2025, 6, 1, 10),
  totalSpend: 0, freeHours: 1, usedHours: 0,
  chargeAmount: 0, receiptIds: [],
);

void main() {
  late MockScanReceiptUseCase      mockScan;
  late MockCalculateParkingUseCase mockCalc;
  late MockGetReceiptsByDate       mockGet;
  late MockDeleteReceiptUseCase    mockDelete;
  late MockReceiptRepository       mockRepo;

  setUpAll(() => registerFallbackValue(FakeCalculateParkingParams()));

  setUp(() {
    mockScan   = MockScanReceiptUseCase();
    mockCalc   = MockCalculateParkingUseCase();
    mockGet    = MockGetReceiptsByDate();
    mockDelete = MockDeleteReceiptUseCase();
    mockRepo   = MockReceiptRepository();
  });

  ScanBloc build() => ScanBloc(
    scan: mockScan, calc: mockCalc, getByDate: mockGet,
    delete: mockDelete, repo: mockRepo,
  );

  group('ScanImageRequested', () {
    blocTest<ScanBloc, ScanState>(
      'emit [Loading, ScanSuccess] เมื่อสแกนสำเร็จ',
      build: () {
        when(() => mockScan(any())).thenAnswer((_) async => Right(_receipt));
        return build();
      },
      act: (b) => b.add(const ScanImageRequested('/img.jpg')),
      expect: () => [ScanLoading(), ScanSuccess(_receipt)],
    );

    blocTest<ScanBloc, ScanState>(
      'emit [Loading, ScanFailureState] เมื่อสแกนล้มเหลว',
      build: () {
        when(() => mockScan(any()))
            .thenAnswer((_) async => Left(ScanFailure('ไม่พบข้อความ')));
        return build();
      },
      act: (b) => b.add(const ScanImageRequested('/bad.jpg')),
      expect: () => [ScanLoading(), const ScanFailureState('ไม่พบข้อความ')],
    );
  });

  group('ParkingSessionStarted', () {
    blocTest<ScanBloc, ScanState>(
      'emit [Loading, ParkingSessionActive]',
      build: () {
        when(() => mockRepo.startParkingSession(any()))
            .thenAnswer((_) async => Right(_session));
        return build();
      },
      act: (b) => b.add(ParkingSessionStarted(DateTime(2025, 6, 1, 10))),
      expect: () => [ScanLoading(), ParkingSessionActive(_session)],
    );
  });

  group('ActiveSessionRequested', () {
    blocTest<ScanBloc, ScanState>(
      'emit ParkingSessionActive เมื่อมี session',
      build: () {
        when(() => mockRepo.getActiveParkingSession())
            .thenAnswer((_) async => Right(_session));
        return build();
      },
      act: (b) => b.add(const ActiveSessionRequested()),
      expect: () => [ParkingSessionActive(_session)],
    );

    blocTest<ScanBloc, ScanState>(
      'emit ParkingNoSession เมื่อไม่มี session',
      build: () {
        when(() => mockRepo.getActiveParkingSession())
            .thenAnswer((_) async => const Right(null));
        return build();
      },
      act: (b) => b.add(const ActiveSessionRequested()),
      expect: () => [ParkingNoSession()],
    );
  });
}
