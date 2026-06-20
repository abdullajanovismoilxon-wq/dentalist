class DoctorSchedule {
  final int id;
  final int? doctor;
  final int dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool isWorking;

  DoctorSchedule({
    required this.id,
    this.doctor,
    this.dayOfWeek = 0,
    this.startTime,
    this.endTime,
    this.isWorking = false,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['id'] ?? 0,
      doctor: json['doctor'],
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'],
      endTime: json['end_time'],
      isWorking: json['is_working'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctor': doctor,
    'day_of_week': dayOfWeek,
    'start_time': startTime,
    'end_time': endTime,
    'is_working': isWorking,
  };

  static const dayNamesUz = [
    'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba',
  ];

  String get dayLabel => dayOfWeek >= 1 && dayOfWeek <= 7 ? dayNamesUz[dayOfWeek - 1] : 'Noma\'lum';
}
