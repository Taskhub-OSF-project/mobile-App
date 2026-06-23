import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_exception.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<Result<AuthResponse>> login(LoginRequest request) async {
    final response = await _api.post<AuthResponse>(
      ApiConstants.login,
      data: request.toJson(),
      parser: (json) => AuthResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<AuthResponse>> register(RegisterRequest request) async {
    final response = await _api.post<AuthResponse>(
      ApiConstants.register,
      data: request.toJson(),
      parser: (json) => AuthResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> logout(String? refreshToken) async {
    final data = refreshToken != null
        ? {'refreshToken': refreshToken}
        : null;
    return _api.post<void>(
      ApiConstants.logout,
      data: data,
    );
  }

  Future<Result<void>> logoutAll() async {
    return _api.post<void>(ApiConstants.logoutAll);
  }

  Future<Result<ForgotPasswordResponse>> forgotPassword(String email) async {
    final response = await _api.post<ForgotPasswordResponse>(
      ApiConstants.forgotPassword,
      data: {'email': email},
      parser: (json) =>
          ForgotPasswordResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> resetPassword(String token, String newPassword) async {
    return _api.post<void>(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  Future<Result<void>> verifyEmail(String token) async {
    return _api.post<void>(
      ApiConstants.verifyEmail,
      data: {'token': token},
    );
  }
}
