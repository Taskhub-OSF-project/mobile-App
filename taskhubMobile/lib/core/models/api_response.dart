import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? errorCode;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.errorCode,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(T Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  bool get isSuccess => success;
  bool get isError => !success;
}


