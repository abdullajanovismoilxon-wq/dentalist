import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationListProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationListProvider.notifier).markAllAsRead(),
              child: const Text('O\'qilgan'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Color(AppColors.textHint)),
                      SizedBox(height: 16),
                      Text('Bildirishnomalar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  itemBuilder: (_, i) {
                    final notif = state.notifications[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: notif.isRead ? null : const Color(AppColors.primary).withOpacity(0.03),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notif.isRead
                              ? const Color(AppColors.background)
                              : const Color(AppColors.primary).withOpacity(0.1),
                          child: Icon(
                            notif.type == 'appointment' ? Icons.calendar_today : Icons.notifications_outlined,
                            color: notif.isRead ? const Color(AppColors.textHint) : const Color(AppColors.primary),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.body, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd.MM HH:mm').format(notif.createdAt),
                              style: const TextStyle(fontSize: 11, color: Color(AppColors.textHint)),
                            ),
                          ],
                        ),
                        trailing: notif.isRead
                            ? null
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(AppColors.primary),
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () => ref.read(notificationListProvider.notifier).markAsRead(notif.id),
                      ),
                    );
                  },
                ),
    );
  }
}
