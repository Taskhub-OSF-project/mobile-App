import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<Result<AuthResponse>> login(LoginRequest request) async {
    return _api.post<AuthResponse>(
      ApiConstants.login,
      data: request.toJson(),
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<AuthResponse>> register(RegisterRequest request) async {
    return _api.post<AuthResponse>(
      ApiConstants.register,
      data: request.toJson(),
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> logout(String? refreshToken) async {
    return _api.post<void>(
      ApiConstants.logout,
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }

  Future<Result<AuthResponse>> refreshToken(RefreshTokenRequest request) async {
    return _api.post<AuthResponse>(
      ApiConstants.refresh,
      data: request.toJson(),
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<ForgotPasswordResponse>> forgotPassword(ForgotPasswordRequest request) async {
    return _api.post<ForgotPasswordResponse>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
      parser: (json) => ForgotPasswordResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> recoverAccount(RecoverAccountRequest request) async {
    return _api.post<void>(
      '/api/auth/recover', // Add actual endpoint from constants later if needed
      data: request.toJson(),
    );
  }

  Future<Result<void>> requestPasswordReset(PasswordResetRequest request) async {
    return _api.post<void>(
      '/api/auth/password-reset-request', // Add actual endpoint from constants later
      data: request.toJson(),
    );
  }

  Future<Result<void>> confirmPasswordReset(PasswordResetConfirmRequest request) async {
    return _api.post<void>(
      '/api/auth/password-reset-confirm', // Add actual endpoint from constants later
      data: request.toJson(),
    );
  }

  Future<Result<void>> resetPassword(ResetPasswordRequest request) async {
    return _api.post<void>(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );
  }

  Future<Result<void>> verifyEmail(VerifyEmailRequest request) async {
    return _api.post<void>(
      ApiConstants.verifyEmail,
      data: request.toJson(),
    );
  }

  // Maintaining Phone Auth endpoints from scaffold in case they are used
  Future<Result<AuthResponse>> loginByPhone(String phone, String password) async {
    return _api.post<AuthResponse>(
      ApiConstants.loginPhone,
      data: {'phone': phone, 'password': password},
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> requestPhoneOtp(String phone, String type) async {
    return _api.post<void>(
      ApiConstants.requestPhoneOtp,
      data: {'phone': phone, 'type': type},
    );
  }

  Future<Result<void>> resetPasswordWithOtp(String phone, String code, String newPassword) async {
    return _api.post<void>(
      ApiConstants.resetPasswordOtp,
      data: {'phone': phone, 'code': code, 'newPassword': newPassword},
    );
  }
}

