import '../models/notification.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class NotificationRepository {
  final ApiService _api;

  NotificationRepository(this._api);

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _api.get(ApiConstants.notifications);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => AppNotification.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      await _api.patch(
        '${ApiConstants.notifications}$id/',
        data: {'is_read': true},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _api.post('${ApiConstants.notifications}mark-all-read/');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('${ApiConstants.notifications}unread-count/');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
