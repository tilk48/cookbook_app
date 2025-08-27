import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network connection failed',
    int? code,
  }) : super(message: message, code: code);
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error occurred',
    int? code,
  }) : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error occurred',
    int? code,
  }) : super(message: message, code: code);
}

class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
    int? code,
  }) : super(message: message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Validation failed',
    int? code,
  }) : super(message: message, code: code);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Resource not found',
    int? code,
  }) : super(message: message, code: code);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Request timeout',
    int? code,
  }) : super(message: message, code: code);
}