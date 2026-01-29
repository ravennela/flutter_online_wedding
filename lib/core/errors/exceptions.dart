/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  
  const AppException(this.message, [this.originalError]);
  
  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException(super.message, [super.originalError]);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message, [super.originalError]);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(super.message, [super.originalError]);
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message, [super.originalError]);
}

/// Unauthorized exception
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.originalError]);
}
