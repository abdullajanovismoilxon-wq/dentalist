import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatListProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Xabarlar')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_outlined, size: 64, color: Color(AppColors.textHint)),
                      SizedBox(height: 16),
                      Text('Xabarlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.conversations.length,
                  itemBuilder: (_, i) {
                    final conv = state.conversations[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(AppColors.primary).withOpacity(0.1),
                        child: Text(
                          (conv.doctorName ?? conv.patientName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Color(AppColors.primary)),
                        ),
                      ),
                      title: Text(
                        conv.doctorName ?? conv.patientName ?? 'Foydalanuvchi',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        conv.lastMessage ?? 'Xabar yo\'q',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (conv.lastMessageTime != null)
                            Text(
                              DateFormat('HH:mm').format(conv.lastMessageTime!),
                              style: const TextStyle(fontSize: 11, color: Color(AppColors.textHint)),
                            ),
                          if (conv.unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(AppColors.unreadBadge),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () => context.go('/chat/${conv.id}'),
                    );
                  },
                ),
    );
  }
}
