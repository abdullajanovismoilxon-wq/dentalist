import '../models/chat.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class ChatRepository {
  final ApiService _api;

  ChatRepository(this._api);

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _api.get(ApiConstants.chats);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Conversation.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Conversation?> getConversation(int id) async {
    try {
      final response = await _api.get('${ApiConstants.chats}$id/');
      return Conversation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Conversation?> createConversation(int doctorId) async {
    try {
      final response = await _api.post(
        ApiConstants.chats,
        data: {'doctor': doctorId},
      );
      return Conversation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    try {
      final response = await _api.get(
        '${ApiConstants.chats}$conversationId/messages/',
      );
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage(int conversationId, String text) async {
    try {
      await _api.post(
        '${ApiConstants.chats}$conversationId/messages/',
        data: {'text': text},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('${ApiConstants.chats}unread-count/');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
