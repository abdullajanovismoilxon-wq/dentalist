import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/chat_provider.dart';
import '../../utils/image_utils.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider(widget.conversationId).notifier).loadMessages();
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(messagesProvider(widget.conversationId).notifier).sendMessage(text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatListProvider);
    final messagesState = ref.watch(messagesProvider(widget.conversationId));

    // Find conversation to get doctor info
    final conversation = chatState.conversations.where((c) => c.id == widget.conversationId).firstOrNull;
    final doctorName = conversation?.doctorName ?? 'Shifokor';
    final doctorImage = conversation?.doctorImage;

    final isDoctor = conversation?.doctorName != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            // Navigate to doctor profile if available
            if (conversation?.doctor != null) {
              context.go('/doctors/${conversation!.doctor}');
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(AppColors.primaryLight),
                backgroundImage: doctorImage != null ? CachedNetworkImageProvider(resolveImageUrl(doctorImage)) : null,
                child: doctorImage == null
                    ? Text(doctorName.isNotEmpty ? doctorName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 16, color: Color(AppColors.primary)))
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Shifokor', style: const TextStyle(fontSize: 11, color: Color(AppColors.textSecondary))),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messagesState.messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Color(AppColors.textHint)),
                            SizedBox(height: 12),
                            Text('Xabarlar yo\'q', style: TextStyle(color: Color(AppColors.textSecondary))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messagesState.messages.length,
                        itemBuilder: (_, i) {
                          final msg = messagesState.messages[i];
                          final isMe = msg.sender != null && msg.sender == 0;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(AppColors.primary) : const Color(AppColors.background),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                ),
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              child: Text(
                                msg.text,
                                style: TextStyle(color: isMe ? Colors.white : const Color(AppColors.textPrimary), fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(AppColors.divider))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Xabar yozish...',
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(AppColors.primary)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
