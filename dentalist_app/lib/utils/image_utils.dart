import '../core/constants.dart';

/// Converts a relative image path from the backend to a full URL.
/// Backend returns paths like '/media/doctors/photo.jpg'
/// which need to be resolved to 'http://host:8000/media/doctors/photo.jpg'
String resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  // Already a full URL
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  // Relative path - prepend the media base URL
  // Extract the base URL without /api suffix
  final base = ApiConstants.baseUrl;
  // baseUrl is like 'http://host:8000/api'
  final serverBase = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  // Handle both /media/... and /uploads/... and /doctors/... etc.
  if (path.startsWith('/')) {
    return '$serverBase$path';
  }
  return '$serverBase/media/$path';
}

/// Returns the server base URL (without /api suffix)
String get serverBaseUrl {
  final base = ApiConstants.baseUrl;
  return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
}
