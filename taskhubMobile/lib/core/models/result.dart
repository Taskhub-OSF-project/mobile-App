import 'api_error.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(ApiError error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  ApiError? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiError error) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Failure<T>) {
      return onFailure((this as Failure<T>).error);
    }
    throw StateError('Unreachable state in Result.fold');
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) failure,
  }) {
    return fold(onSuccess: success, onFailure: failure);
  }

  T? get data => dataOrNull;
  ApiError? get error => errorOrNull;
}

class Success<T> extends Result<T> {
  @override
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  @override
  final ApiError error;
  const Failure(this.error);
}
