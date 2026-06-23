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

@JsonSerializable()
class PageResponse<T> {
  @JsonKey(name: 'content')
  final List<T> content;
  @JsonKey(name: 'page')
  final int page;
  @JsonKey(name: 'size')
  final int size;
  @JsonKey(name: 'totalElements')
  final int totalElements;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  @JsonKey(name: 'first')
  final bool first;
  @JsonKey(name: 'last')
  final bool last;
  @JsonKey(name: 'hasNext')
  final bool hasNext;
  @JsonKey(name: 'hasPrevious')
  final bool hasPrevious;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PageResponseFromJson(json, fromJsonT);
}
