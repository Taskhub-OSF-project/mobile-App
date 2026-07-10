class ApiError implements Exception {
  final int? statusCode;
  final String message;
  final dynamic payload;

  ApiError({
    this.statusCode,
    required this.message,
    this.payload,
  });

  @override
  String toString() {
    return 'ApiError: $message (Status Code: $statusCode)';
  }
}

class AuthExpiredError extends ApiError {
  AuthExpiredError({String message = 'Session expired, please login again'})
      : super(message: message, statusCode: 401);
}
