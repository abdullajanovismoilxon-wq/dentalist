class Slot {
  final int? id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final int? doctor;

  Slot({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'available',
    this.doctor,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    String status = json['status'] ?? 'available';
    if (status == 'available' && json['is_available'] == false) {
      status = 'blocked';
    } else if (status == 'available' && json['is_available'] == true) {
      status = 'available';
    }
    return Slot(
      id: json['id'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      startTime: json['start_time'] ?? '00:00',
      endTime: json['end_time'] ?? '00:00',
      status: status,
      doctor: json['doctor'],
    );
  }

  bool get isAvailable => status == 'available';
}