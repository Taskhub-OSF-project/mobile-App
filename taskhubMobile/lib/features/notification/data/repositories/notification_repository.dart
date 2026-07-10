import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/models/result.dart';
import 'package:taskhub_mobile/core/models/page_response.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final ApiService _api;

  NotificationRepository(this._api);

  Future<Result<PageResponse<NotificationResponse>>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response =
        await _api.get<PageResponse<NotificationResponse>>(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<NotificationResponse>.fromJson(
        json as Map<String, dynamic>,
        (e) => NotificationResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<List<NotificationResponse>>> getUnread() async {
    final response = await _api.get<List<NotificationResponse>>(
      ApiConstants.unreadNotifications,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) =>
                NotificationResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response;
  }

  Future<Result<int>> getUnreadCount() async {
    final response = await _api.get<int>(
      ApiConstants.unreadCount,
      parser: (json) {
        final data = json;
        if (data is Map) {
          return (data['unreadCount'] ?? 0) as int;
        }
        return 0;
      },
    );
    return response;
  }

  Future<Result<void>> markAsRead(int notificationId) async {
    return _api.post<void>(ApiConstants.markRead(notificationId));
  }

  Future<Result<void>> markAllAsRead() async {
    return _api.post<void>(ApiConstants.markAllRead);
  }
}
