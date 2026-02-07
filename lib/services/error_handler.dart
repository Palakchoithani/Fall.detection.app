import 'logger_service.dart';

/// Custom exception classes
class HealthCompanionException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  HealthCompanionException({
    required this.message,
    this.code = 'UNKNOWN_ERROR',
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class AuthException extends HealthCompanionException {
  AuthException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'AUTH_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class NetworkException extends HealthCompanionException {
  NetworkException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'NETWORK_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class DataException extends HealthCompanionException {
  DataException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'DATA_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Error handler with logging and user-friendly messages
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final LoggerService _logger = LoggerService();

  String getErrorMessage(dynamic error) {
    try {
      if (error is HealthCompanionException) {
        _logger.error(
          error.message,
          tag: 'ErrorHandler',
          stackTrace: error.stackTrace,
        );
        return error.message;
      }

      if (error is NetworkException) {
        return 'Network connection failed. Please check your internet.';
      }

      if (error is AuthException) {
        return 'Authentication failed. Please try again.';
      }

      if (error is DataException) {
        return 'Failed to process data. Please try again.';
      }

      _logger.error(
        'Unknown error: $error',
        tag: 'ErrorHandler',
      );
      return 'An unexpected error occurred. Please try again.';
    } catch (e) {
      _logger.error('Error in error handler: $e', tag: 'ErrorHandler');
      return 'Something went wrong. Please try again later.';
    }
  }

  void logError(
    dynamic error, {
    String? tag,
    StackTrace? stackTrace,
  }) {
    _logger.error(
      '$error',
      tag: tag ?? 'App',
      stackTrace: stackTrace,
    );
  }
}
