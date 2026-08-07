import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

enum UserRole { ADMIN, HIRER, STUDENT }

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'token')
  final String? accessToken;
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;
  @JsonKey(name: 'userId')
  final int userId;
  final String email;
  @JsonKey(name: 'fullName')
  final String fullName;
  final UserRole role;
  final int? expiresAt;
  final bool? emailOtpRequired;
  final String? otpChallengeId;
  final String? otpPurpose;
  final int? otpExpiresIn;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.expiresAt,
    this.emailOtpRequired,
    this.otpChallengeId,
    this.otpPurpose,
    this.otpExpiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  @JsonKey(name: 'fullName')
  final String fullName;
  final String? university;
  final String? major;
  final String role;
  @JsonKey(name: 'phoneNumber')
  final String? phoneNumber;
  @JsonKey(name: 'dateOfBirth')
  final String? dateOfBirth;
  final int? age;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.university,
    this.major,
    required this.role,
    this.phoneNumber,
    this.dateOfBirth,
    this.age,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordResponse {
  @JsonKey(name: 'resetLink')
  final String? resetLink;
  final String? token;
  @JsonKey(name: 'emailSent')
  final bool emailSent;

  ForgotPasswordResponse({
    this.resetLink,
    this.token,
    required this.emailSent,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  @JsonKey(name: 'newPassword')
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String token;

  VerifyEmailRequest({required this.token});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'currentPassword')
  final String currentPassword;
  @JsonKey(name: 'newPassword')
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable()
class LogoutRequest {
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  LogoutRequest({this.refreshToken});

  factory LogoutRequest.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}

@JsonSerializable()
class RecoverAccountRequest {
  final String email;

  RecoverAccountRequest({required this.email});

  factory RecoverAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$RecoverAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecoverAccountRequestToJson(this);
}

@JsonSerializable()
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PasswordResetConfirmRequest {
  final String token;
  final String newPassword;

  PasswordResetConfirmRequest({
    required this.token,
    required this.newPassword,
  });

  factory PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetConfirmRequestToJson(this);
}

@JsonSerializable()
class GoogleAuthRequest {
  final String credential;
  final String? role;

  GoogleAuthRequest({required this.credential, this.role});

  factory GoogleAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthRequestToJson(this);
}

@JsonSerializable()
class EmailOtpVerifyRequest {
  final String challengeId;
  final String code;

  EmailOtpVerifyRequest({required this.challengeId, required this.code});

  factory EmailOtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailOtpVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailOtpVerifyRequestToJson(this);
}

@JsonSerializable()
class EmailOtpResendRequest {
  final String challengeId;

  EmailOtpResendRequest({required this.challengeId});

  factory EmailOtpResendRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailOtpResendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailOtpResendRequestToJson(this);
}
