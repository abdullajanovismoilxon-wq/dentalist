class WorkingHours {
  final int id;
  final String day;
  final String? startTime;
  final String? endTime;
  final bool isWorking;

  WorkingHours({
    required this.id,
    required this.day,
    this.startTime,
    this.endTime,
    this.isWorking = true,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'] ?? 0,
      day: json['day'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      isWorking: json['is_working'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'is_working': isWorking,
    };
  }

  String get dayLabel {
    switch (day.toLowerCase()) {
      case 'monday': return 'Dushanba';
      case 'tuesday': return 'Seshanba';
      case 'wednesday': return 'Chorshanba';
      case 'thursday': return 'Payshanba';
      case 'friday': return 'Juma';
      case 'saturday': return 'Shanba';
      case 'sunday': return 'Yakshanba';
      default: return day;
    }
  }
}
