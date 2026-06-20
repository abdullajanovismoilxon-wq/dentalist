class BlockedSlot {
  final int id;
  final int? doctor;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? reason;

  BlockedSlot({
    required this.id,
    this.doctor,
    this.date,
    this.startTime,
    this.endTime,
    this.reason,
  });

  factory BlockedSlot.fromJson(Map<String, dynamic> json) {
    return BlockedSlot(
      id: json['id'] ?? 0,
      doctor: json['doctor'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      reason: json['reason'],
    );
  }
}
