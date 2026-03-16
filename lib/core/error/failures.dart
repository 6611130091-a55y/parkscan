// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}
class ScanFailure        extends Failure { const ScanFailure(super.m); }
class NetworkFailure     extends Failure { const NetworkFailure(super.m); }
class DatabaseFailure    extends Failure { const DatabaseFailure(super.m); }
class ClassificationFailure extends Failure { const ClassificationFailure(super.m); }
