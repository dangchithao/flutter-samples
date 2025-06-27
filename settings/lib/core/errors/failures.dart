import 'package:dartz/dartz.dart';

// Base class for all failures
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => 'Failure: $message';
}

// Common failures
class ServerFailure extends Failure {
  const ServerFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Extension for Either<L, R> to handle failures
extension EitherX<L, R> on Either<L, R> {
  R getOrThrow() {
    return fold(
      (failure) => throw failure is Failure
          ? failure
          : Exception('Unexpected failure: $failure'),
      (r) => r,
    );
  }
}
