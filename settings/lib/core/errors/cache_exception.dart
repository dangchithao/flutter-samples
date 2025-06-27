import 'package:equatable/equatable.dart';

class CacheException extends Equatable implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const CacheException(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'CacheException: $message';
}
