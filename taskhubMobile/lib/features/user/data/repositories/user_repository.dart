import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_exception.dart';
import '../models/user_models.dart';

class UserRepository {
  final ApiService _api;

  UserRepository(this._api);

  Future<Result<UserProfileResponse>> getMyProfile() async {
    final response = await _api.get<UserProfileResponse>(
      ApiConstants.me,
      parser: (json) =>
          UserProfileResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<UserProfileResponse>> getProfile(int userId) async {
    final response = await _api.get<UserProfileResponse>(
      ApiConstants.userById(userId),
      parser: (json) =>
          UserProfileResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<UserProfileResponse>> updateProfile(
      UserProfileUpdateRequest request) async {
    final response = await _api.put<UserProfileResponse>(
      ApiConstants.me,
      data: request.toJson(),
      parser: (json) =>
          UserProfileResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<void>> setAvailability(bool available) async {
    return _api.post<void>(
      ApiConstants.setAvailability,
      queryParameters: {'available': available},
    );
  }

  Future<Result<void>> changePassword(
      String currentPassword, String newPassword) async {
    return _api.patch<void>(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
