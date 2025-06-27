// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

// Thrown when there's a cache-related error
class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Thrown when there's a server-related error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(String message, {this.statusCode, StackTrace? stackTrace})
      : super(message, stackTrace);
}

// Thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
