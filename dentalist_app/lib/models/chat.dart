class Conversation {
  final int id;
  final int? doctor;
  final String? doctorName;
  final String? doctorImage;
  final int? patient;
  final String? patientName;
  final String? patientImage;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    this.doctor,
    this.doctorName,
    this.doctorImage,
    this.patient,
    this.patientName,
    this.patientImage,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      doctor: json['doctor'],
      doctorName: json['doctor_name'],
      doctorImage: json['doctor_image'],
      patient: json['patient'],
      patientName: json['patient_name'],
      patientImage: json['patient_image'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final int conversation;
  final int? sender;
  final String? senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversation,
    this.sender,
    this.senderName,
    required this.text,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversation: json['conversation'] ?? 0,
      sender: json['sender'],
      senderName: json['sender_name'],
      text: json['text'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}
