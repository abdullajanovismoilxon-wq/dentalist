class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  static const String login = '$baseUrl/users/login/';
  static const String register = '$baseUrl/users/register/';
  static const String registerDoctor = '$baseUrl/users/register/doctor/';
  static const String tokenRefresh = '$baseUrl/users/refresh/';
  static const String profile = '$baseUrl/users/profile/';
  static const String doctors = '$baseUrl/doctors/';
  static const String doctorNearby = '$baseUrl/doctors/nearby/';
  static const String doctorProfile = '$baseUrl/doctors/profile/';
  static const String doctorServices = '$baseUrl/doctors/services/';
  static const String doctorSchedule = '$baseUrl/doctors/schedule/';
  static const String doctorBlockedSlots = '$baseUrl/doctors/blocked-slots/';
  static const String doctorSlots = '$baseUrl/doctors/slots/';
  static const String doctorDashboard = '$baseUrl/doctors/dashboard/';
  static const String doctorUploadClinicImage = '$baseUrl/doctors/clinic/upload-image/';
  static const String specializations = '$baseUrl/doctors/specializations/';

  static const String clinics = '$baseUrl/clinics/';
  static const String clinicReviews = '$baseUrl/clinics/';
  static const String clinicGallery = '$baseUrl/clinics/';
  static const String clinicAvatar = '$baseUrl/clinics/';

  static const String appointments = '$baseUrl/appointments/';
  static const String appointmentCreate = '$baseUrl/appointments/create/';

  static const String reviews = '$baseUrl/reviews/';

  static const String availableTimes = '$baseUrl/appointments/available-times/';

  static const String reviewsBase = '$baseUrl/reviews/';

  static const String scheduleSchedules = '$baseUrl/schedule/schedules/';
  static const String scheduleSlots = '$baseUrl/schedule/slots/';
  static const String scheduleGenerate = '$baseUrl/schedule/generate/';
  static const String scheduleBlocked = '$baseUrl/schedule/blocked/';

  static const String notifications = '$baseUrl/notifications/';
  static const String notificationUnreadCount = '$baseUrl/notifications/unread-count/';

  static const String chats = '$baseUrl/chat/rooms/';
  static const String chatGetOrCreate = '$baseUrl/chat/rooms/get-or-create/';

  static const String favorites = '$baseUrl/favorites/';

  static const String search = '$baseUrl/search/';
}

class AppConstants {
  static const String appName = 'Dentalist';
  static const String appVersion = '1.0.0';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
}

class AppColors {
  // Web-matching palette (#00B5D8 cyan primary)
  static const int primary = 0xFF00B5D8;
  static const int primaryDark = 0xFF0099B8;
  static const int primaryLight = 0xFFE0F7FA;
  static const int secondary = 0xFFE056C5;
  static const int secondaryLight = 0xFFFCE4F8;
  static const int background = 0xFFF8FAFC;
  static const int surface = 0xFFFFFFFF;
  static const int error = 0xFFEF4444;
  static const int warning = 0xFFF59E0B;
  static const int success = 0xFF10B981;
  static const int textPrimary = 0xFF1E293B;
  static const int textSecondary = 0xFF64748B;
  static const int textHint = 0xFF94A3B8;
  static const int border = 0xFFE2E8F0;
  static const int divider = 0xFFF1F5F9;
  static const int unreadBadge = 0xFFEF4444;
  static const int online = 0xFF10B981;
  static const int offline = 0xFF94A3B8;
  static const int bottomNavActive = 0xFF00B5D8;
  static const int bottomNavInactive = 0xFF94A3B8;
  static const int cardShadow = 0x1A000000;
}

class AppTextStyles {
  static const String fontFamily = 'Roboto';
}
