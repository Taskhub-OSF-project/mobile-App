// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$RoleMap = {
  'ADMIN': UserRole.ADMIN,
  'HIRER': UserRole.HIRER,
  'STUDENT': UserRole.STUDENT,
};

const _$RoleValueMap = {
  UserRole.ADMIN: 'ADMIN',
  UserRole.HIRER: 'HIRER',
  UserRole.STUDENT: 'STUDENT',
};

T? _$enumDecode<T>(Map<String, dynamic> enumValues, Object? source) {
  if (source == null) return null;
  for (final entry in enumValues.entries) {
    if (entry.value == source) return entry.key as T;
  }
  return null;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      accessToken: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: _$enumDecode(_$RoleMap, json['role']) ?? UserRole.STUDENT,
      expiresAt: (json['expiresAt'] as num).toInt(),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'userId': instance.userId,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': _$RoleValueMap[instance.role],
      'expiresAt': instance.expiresAt,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      university: json['university'] as String?,
      major: json['major'] as String?,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'fullName': instance.fullName,
      'university': instance.university,
      'major': instance.major,
      'role': instance.role,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': instance.dateOfBirth,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestToJson(RefreshTokenRequest instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestToJson(
        ForgotPasswordRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ForgotPasswordResponse _$ForgotPasswordResponseFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordResponse(
      resetLink: json['resetLink'] as String?,
      token: json['token'] as String?,
      emailSent: json['emailSent'] as bool,
    );

Map<String, dynamic> _$ForgotPasswordResponseToJson(
        ForgotPasswordResponse instance) =>
    <String, dynamic>{
      'resetLink': instance.resetLink,
      'token': instance.token,
      'emailSent': instance.emailSent,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(Map<String, dynamic> json) =>
    ResetPasswordRequest(
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestToJson(
        ResetPasswordRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'newPassword': instance.newPassword,
    };

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(
      token: json['token'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

ChangePasswordRequest _$ChangePasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestToJson(
        ChangePasswordRequest instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
    };

LogoutRequest _$LogoutRequestFromJson(Map<String, dynamic> json) =>
    LogoutRequest(
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$LogoutRequestToJson(LogoutRequest instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };
