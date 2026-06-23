import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/models/api_response.dart';
import '../models/messaging_models.dart';

class MessagingRepository {
  final ApiService _api;

  MessagingRepository(this._api);

  Future<Result<PageResponse<ConversationResponse>>> getConversations({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get<PageResponse<ConversationResponse>>(
      ApiConstants.conversationsPaged,
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<ConversationResponse>.fromJson(
        json['data'] as Map<String, dynamic>,
        (e) => ConversationResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<ConversationResponse>> getOrCreateConversation(int taskId) async {
    final response = await _api.post<ConversationResponse>(
      ApiConstants.createConversation(taskId),
      parser: (json) =>
          ConversationResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<MessageResponse>> sendMessage(
      int conversationId, String content) async {
    final response = await _api.post<MessageResponse>(
      ApiConstants.sendMessage(conversationId),
      data: {'content': content},
      parser: (json) =>
          MessageResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
    return response;
  }

  Future<Result<PageResponse<MessageResponse>>> getMessages(
    int conversationId, {
    int page = 0,
    int size = 50,
  }) async {
    final response = await _api.get<PageResponse<MessageResponse>>(
      ApiConstants.getMessages(conversationId),
      queryParameters: {'page': page, 'size': size},
      parser: (json) => PageResponse<MessageResponse>.fromJson(
        json['data'] as Map<String, dynamic>,
        (e) => MessageResponse.fromJson(e as Map<String, dynamic>),
      ),
    );
    return response;
  }

  Future<Result<void>> markAsRead(int conversationId) async {
    return _api.post<void>(ApiConstants.markConversationRead(conversationId));
  }

  Future<Result<int>> getUnreadCount() async {
    final response = await _api.get<int>(
      ApiConstants.unreadMessageCount,
      parser: (json) {
        final data = json['data'];
        if (data is Map) {
          return (data['unreadCount'] ?? 0) as int;
        }
        return 0;
      },
    );
    return response;
  }
}
