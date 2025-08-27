import '../error/failures.dart';

/// A generic result type that encapsulates either a success value or a failure
sealed class Result<T> {
  const Result();

  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure;

  /// Get the success value (throws if failure)
  T get value => switch (this) {
        Success<T> s => s.value,
        ResultFailure<T> _ =>
          throw StateError('Cannot get value from failure result'),
      };

  /// Get the failure (throws if success)
  dynamic get failure => switch (this) {
        Success<T> _ =>
          throw StateError('Cannot get failure from success result'),
        ResultFailure<T> f => f.failure,
      };

  /// Transform the success value if present
  Result<U> map<U>(U Function(T) transform) => switch (this) {
        Success<T> s => Success(transform(s.value)),
        ResultFailure<T> f => ResultFailure(f.failure),
      };

  /// Chain operations on success values
  Result<U> flatMap<U>(Result<U> Function(T) transform) => switch (this) {
        Success<T> s => transform(s.value),
        ResultFailure<T> f => ResultFailure(f.failure),
      };

  /// Execute a function on success, return the original result
  Result<T> onSuccess(void Function(T) action) {
    if (this case Success<T> s) {
      action(s.value);
    }
    return this;
  }

  /// Execute a function on failure, return the original result
  Result<T> onFailure(void Function(dynamic) action) {
    if (this case ResultFailure<T> f) {
      action(f.failure);
    }
    return this;
  }

  /// Return the value if success, or default value if failure
  T getOrElse(T defaultValue) => switch (this) {
        Success<T> s => s.value,
        ResultFailure<T> _ => defaultValue,
      };

  /// Return the value if success, or compute default from failure
  T getOrElseCompute(T Function(dynamic) computeDefault) => switch (this) {
        Success<T> s => s.value,
        ResultFailure<T> f => computeDefault(f.failure),
      };
}

/// Represents a successful result with a value
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) {
    return other is Success<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a failed result with a failure
class ResultFailure<T> extends Result<T> {
  final dynamic failure;

  const ResultFailure(this.failure);

  @override
  String toString() => 'ResultFailure($failure)';

  @override
  bool operator ==(Object other) {
    return other is ResultFailure<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
}

/// Helper functions for creating Results
extension ResultHelper<T> on T {
  Result<T> toSuccess() => Success(this);
}

extension FailureHelper on dynamic {
  Result<T> toFailure<T>() => ResultFailure<T>(this);
}
