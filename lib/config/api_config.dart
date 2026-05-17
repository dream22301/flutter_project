import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration — all base URL constants live here.
/// Mirrors the role of Laravel's routes/api.php for the mobile side.
class ApiConfig {
  ApiConfig._(); // prevent instantiation

  /// Base URL for the mobile API.
  /// Dynamically selects the correct localhost depending on the platform.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/mobile';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 maps to host machine's localhost inside the Android Emulator.
      // ⚠ Testing on a PHYSICAL device? Replace with your LAN IP, e.g.:
      //   return 'http://192.168.1.X:8000/api/mobile';
      return 'http://10.0.2.2:8000/api/mobile';
    } else {
      // Linux, Windows, macOS Desktop
      return 'http://127.0.0.1:8000/api/mobile';
    }
  }

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static String get studentLogin     => '$baseUrl/student/login';
  static String get studentProfile   => '$baseUrl/student/profile';
  static String get announcements    => '$baseUrl/announcements';
  static String get studentSchedule  => '$baseUrl/student-schedule';
  static String get nextSubject      => '$baseUrl/next-subject';
  static String get questions        => '$baseUrl/questions';

  /// Builds the URL for a single announcement detail.
  static String announcementDetail(int id) => '$baseUrl/announcements/$id';

  /// Builds the URL for a single question set (with all questions).
  static String questionDetail(int id) => '$baseUrl/questions/$id';

  /// Builds the URL for finding a question set by its key_code.
  static String questionByKey(String keyCode) => '$baseUrl/questions/key/$keyCode';

  /// Builds the URL for submitting a score for a question set.
  static String submitScore(int id) => '$baseUrl/questions/$id/score';
}
