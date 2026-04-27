/// API Configuration — all base URL constants live here.
/// Mirrors the role of Laravel's routes/api.php for the mobile side.
class ApiConfig {
  ApiConfig._(); // prevent instantiation

  /// Base URL for the mobile API.
  ///
  /// Android Emulator:  10.0.2.2 maps to host machine's localhost.
  /// Physical device:   replace with your LAN IP, e.g. http://192.168.1.x:8000/api/mobile
  static const String baseUrl = 'http://10.0.2.2:8000/api/mobile';

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String studentLogin     = '$baseUrl/student/login';
  static const String announcements    = '$baseUrl/announcements';
  static const String studentSchedule  = '$baseUrl/student-schedule';
}
