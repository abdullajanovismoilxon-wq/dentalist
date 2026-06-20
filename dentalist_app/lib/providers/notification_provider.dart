import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';
import 'api_service_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiServiceProvider));
});

class NotificationListState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? error;

  const NotificationListState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationListState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

final notificationListProvider = StateNotifierProvider<NotificationListNotifier, NotificationListState>((ref) {
  return NotificationListNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationListNotifier extends StateNotifier<NotificationListState> {
  final NotificationRepository _repository;

  NotificationListNotifier(this._repository) : super(const NotificationListState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    final notifications = await _repository.getNotifications();
    final unreadCount = await _repository.getUnreadCount();
    state = state.copyWith(
      isLoading: false,
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  Future<void> markAsRead(int id) async {
    await _repository.markAsRead(id);
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) return AppNotification(id: n.id, title: n.title, body: n.body, type: n.type, isRead: true);
        return n;
      }).toList(),
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    state = state.copyWith(
      notifications: state.notifications.map((n) => AppNotification(id: n.id, title: n.title, body: n.body, type: n.type, isRead: true)).toList(),
      unreadCount: 0,
    );
  }
}
