import '../errors/app_failure.dart';

export '../errors/app_failure.dart';

typedef AsyncResult<T extends Object> = Future<Result<T>>;

sealed class Result<T extends Object> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  const factory Result.success(T value) = Success<T>;

  factory Result.failure(Object error, [StackTrace? stackTrace]) = Failure<T>;

  static Future<Result<T>> guard<T extends Object>(
    Future<T> Function() computation,
  ) async {
    try {
      return Result.success(await computation());
    } on AppFailure catch (e) {
      return Result.failure(e);
    } catch (e, stackTrace) {
      return Result.failure(e, stackTrace);
    }
  }

  /// value returns null if this is a Failure, otherwise the value. This allows
  /// access to the value without folding when the caller only cares about
  /// the success case, such as for caching the last successful value.
  T? get value => switch (this) {
    Success(:final value) => value,
    _ => null,
  };

  AppFailure? get error => switch (this) {
    Failure(:final error) => error,
    _ => null,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure error) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final error) => onFailure(error),
    };
  }
}

final class Success<T extends Object> extends Result<T> {
  final T _value;

  @override
  T get value => _value;

  const Success(this._value);
}

final class Failure<T extends Object> extends Result<T> {
  final AppFailure _error;

  @override
  AppFailure get error => _error;

  const Failure.of(this._error);

  const Failure._(this._error);

  factory Failure(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return Failure._(error);
    }
    return Failure._(
      UnknownFailure(
        message: error.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
