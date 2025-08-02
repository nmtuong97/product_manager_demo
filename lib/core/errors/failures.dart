/// Core error handling classes for the application
/// Provides a consistent way to handle different types of failures

/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Server-related failures (API, network, etc.)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ServerFailure.connectionTimeout() => const ServerFailure(
        message: 'Connection timeout',
        code: 'CONNECTION_TIMEOUT',
      );

  factory ServerFailure.noInternetConnection() => const ServerFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );

  factory ServerFailure.serverError([String? message]) => ServerFailure(
        message: message ?? 'Server error occurred',
        code: 'SERVER_ERROR',
      );

  factory ServerFailure.unauthorized() => const ServerFailure(
        message: 'Unauthorized access',
        code: 'UNAUTHORIZED',
      );

  factory ServerFailure.notFound() => const ServerFailure(
        message: 'Resource not found',
        code: 'NOT_FOUND',
      );
}

/// Cache and local storage related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Data not found in cache',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheFailure.writeError() => const CacheFailure(
        message: 'Failed to write to cache',
        code: 'CACHE_WRITE_ERROR',
      );

  factory CacheFailure.readError() => const CacheFailure(
        message: 'Failed to read from cache',
        code: 'CACHE_READ_ERROR',
      );

  factory CacheFailure.corruptedData() => const CacheFailure(
        message: 'Cached data is corrupted',
        code: 'CACHE_CORRUPTED',
      );
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ValidationFailure.invalidInput(String field) => ValidationFailure(
        message: 'Invalid input for $field',
        code: 'INVALID_INPUT',
        details: field,
      );

  factory ValidationFailure.requiredField(String field) => ValidationFailure(
        message: '$field is required',
        code: 'REQUIRED_FIELD',
        details: field,
      );

  factory ValidationFailure.invalidFormat(String field) => ValidationFailure(
        message: 'Invalid format for $field',
        code: 'INVALID_FORMAT',
        details: field,
      );
}

/// Business logic related failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory BusinessLogicFailure.insufficientStock() => const BusinessLogicFailure(
        message: 'Insufficient stock available',
        code: 'INSUFFICIENT_STOCK',
      );

  factory BusinessLogicFailure.duplicateEntry() => const BusinessLogicFailure(
        message: 'Entry already exists',
        code: 'DUPLICATE_ENTRY',
      );

  factory BusinessLogicFailure.operationNotAllowed() => const BusinessLogicFailure(
        message: 'Operation not allowed',
        code: 'OPERATION_NOT_ALLOWED',
      );
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory UnknownFailure.fromException(Exception exception) => UnknownFailure(
        message: exception.toString(),
        code: 'UNKNOWN_EXCEPTION',
        details: exception,
      );

  factory UnknownFailure.fromError(Error error) => UnknownFailure(
        message: error.toString(),
        code: 'UNKNOWN_ERROR',
        details: error,
      );
}