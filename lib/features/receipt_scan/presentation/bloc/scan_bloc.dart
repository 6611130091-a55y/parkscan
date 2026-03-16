import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/parking_session.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/usecases/usecases.dart';

// Events
abstract class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object?> get props => [];
}

class ScanImageRequested extends ScanEvent {
  final String imagePath;
  const ScanImageRequested(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class ParkingSessionStarted extends ScanEvent {
  final DateTime entryTime;
  const ParkingSessionStarted(this.entryTime);
  @override
  List<Object?> get props => [entryTime];
}

class ParkingExitRequested extends ScanEvent {
  final DateTime exitTime, entryDate;
  const ParkingExitRequested({required this.exitTime, required this.entryDate});
  @override
  List<Object?> get props => [exitTime, entryDate];
}

class ReceiptsLoadRequested extends ScanEvent {
  const ReceiptsLoadRequested();
}

class ActiveSessionRequested extends ScanEvent {
  const ActiveSessionRequested();
}

class ReceiptDeleted extends ScanEvent {
  final String id;
  const ReceiptDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ScanState extends Equatable {
  const ScanState();
  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final Receipt receipt;
  const ScanSuccess(this.receipt);
  @override
  List<Object?> get props => [receipt];
}

class ScanFailureState extends ScanState {
  final String message;
  const ScanFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

class ReceiptsLoaded extends ScanState {
  final List<Receipt> receipts;
  const ReceiptsLoaded(this.receipts);
  @override
  List<Object?> get props => [receipts];
}

class ParkingSessionActive extends ScanState {
  final ParkingSession session;
  const ParkingSessionActive(this.session);
  @override
  List<Object?> get props => [session];
}

class ParkingCalculated extends ScanState {
  final ParkingSession session;
  const ParkingCalculated(this.session);
  @override
  List<Object?> get props => [session];
}

class ParkingNoSession extends ScanState {}

// Bloc
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanReceiptUseCase _scan;
  final CalculateParkingUseCase _calc;
  final GetReceiptsByDateUseCase _getByDate;
  final DeleteReceiptUseCase _delete;
  final ReceiptRepository _repo;

  ScanBloc({
    required ScanReceiptUseCase scan,
    required CalculateParkingUseCase calc,
    required GetReceiptsByDateUseCase getByDate,
    required DeleteReceiptUseCase delete,
    required ReceiptRepository repo,
  })  : _scan = scan,
        _calc = calc,
        _getByDate = getByDate,
        _delete = delete,
        _repo = repo,
        super(ScanInitial()) {
    on<ScanImageRequested>(_onScan);
    on<ReceiptsLoadRequested>(_onLoad);
    on<ParkingSessionStarted>(_onStart);
    on<ParkingExitRequested>(_onExit);
    on<ActiveSessionRequested>(_onActiveSession);
    on<ReceiptDeleted>(_onDelete);
  }

  Future<void> _onScan(ScanImageRequested e, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    (await _scan(e.imagePath)).fold(
      (f) => emit(ScanFailureState(f.message)),
      (r) => emit(ScanSuccess(r)),
    );
  }

  Future<void> _onLoad(ReceiptsLoadRequested _, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    (await _getByDate(DateTime.now())).fold(
      (f) => emit(ScanFailureState(f.message)),
      (list) => emit(ReceiptsLoaded(list)),
    );
  }

  Future<void> _onStart(ParkingSessionStarted e, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    (await _repo.startParkingSession(e.entryTime)).fold(
      (f) => emit(ScanFailureState(f.message)),
      (s) => emit(ParkingSessionActive(s)),
    );
  }

  Future<void> _onExit(ParkingExitRequested e, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    (await _calc(CalculateParkingParams(exitTime: e.exitTime, entryDate: e.entryDate))).fold(
      (f) => emit(ScanFailureState(f.message)),
      (s) => emit(ParkingCalculated(s)),
    );
  }

  Future<void> _onActiveSession(ActiveSessionRequested _, Emitter<ScanState> emit) async {
    (await _repo.getActiveParkingSession()).fold(
      (f) => emit(ScanFailureState(f.message)),
      (s) => s != null ? emit(ParkingSessionActive(s)) : emit(ParkingNoSession()),
    );
  }

  Future<void> _onDelete(ReceiptDeleted e, Emitter<ScanState> emit) async {
    await _delete(e.id);
    add(const ReceiptsLoadRequested());
  }
}
