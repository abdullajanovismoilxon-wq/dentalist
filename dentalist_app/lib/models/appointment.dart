class Appointment {
  final int id;
  final int? patient;
  final String? patientName;
  final String? patientPhone;
  final int? doctor;
  final String? doctorName;
  final int? clinic;
  final String? clinicName;
  final String? service;
  final String? serviceName;
  final DateTime date;
  final String time;
  final String status;
  final String? notes;
  final String? cancelReason;
  final DateTime createdAt;

  Appointment({
    required this.id,
    this.patient,
    this.patientName,
    this.patientPhone,
    this.doctor,
    this.doctorName,
    this.clinic,
    this.clinicName,
    this.service,
    this.serviceName,
    required this.date,
    required this.time,
    this.status = 'pending',
    this.notes,
    this.cancelReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      patient: json['patient'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'],
      doctor: json['doctor'],
      doctorName: json['doctor_name'],
      clinic: json['clinic'],
      clinicName: json['clinic_name'],
      service: json['service'],
      serviceName: json['service_name'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '00:00',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      cancelReason: json['cancel_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'confirmed':
        return 'Tasdiqlangan';
      case 'completed':
        return 'Yakunlangan';
      case 'cancelled':
        return 'Bekor qilingan';
      default:
        return status;
    }
  }

  bool get isActive => status == 'pending' || status == 'confirmed';
}
