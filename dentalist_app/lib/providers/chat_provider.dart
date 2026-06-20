import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../repositories/chat_repository.dart';
import 'api_service_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(apiServiceProvider));
});

class ChatListState {
  final bool isLoading;
  final List<Conversation> conversations;
  final int unreadCount;

  const ChatListState({
    this.isLoading = false,
    this.conversations = const [],
    this.unreadCount = 0,
  });

  ChatListState copyWith({
    bool? isLoading,
    List<Conversation>? conversations,
    int? unreadCount,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, ChatListState>((ref) {
  return ChatListNotifier(ref.read(chatRepositoryProvider));
});

class ChatListNotifier extends StateNotifier<ChatListState> {
  final ChatRepository _repository;

  ChatListNotifier(this._repository) : super(const ChatListState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);
    final conversations = await _repository.getConversations();
    final unreadCount = await _repository.getUnreadCount();
    state = state.copyWith(
      isLoading: false,
      conversations: conversations,
      unreadCount: unreadCount,
    );
  }
}

class MessagesState {
  final bool isLoading;
  final List<ChatMessage> messages;

  const MessagesState({
    this.isLoading = false,
    this.messages = const [],
  });

  MessagesState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
  }) {
    return MessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
    );
  }
}

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, MessagesState, int>((ref, conversationId) {
  return MessagesNotifier(ref.read(chatRepositoryProvider), conversationId);
});

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ChatRepository _repository;
  final int conversationId;

  MessagesNotifier(this._repository, this.conversationId) : super(const MessagesState());

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);
    final messages = await _repository.getMessages(conversationId);
    state = state.copyWith(isLoading: false, messages: messages);
  }

  Future<bool> sendMessage(String text) async {
    final success = await _repository.sendMessage(conversationId, text);
    if (success) {
      await loadMessages();
    }
    return success;
  }
}
