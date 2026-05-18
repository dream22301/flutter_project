import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/mobile';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/mobile';
    } else {
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

  static String announcementDetail(int id) => '$baseUrl/announcements/$id';

  static String questionDetail(int id) => '$baseUrl/questions/$id';

  static String questionByKey(String keyCode, String nis, String password) => 
      '$baseUrl/questions/key/$keyCode?nis=$nis&password=$password';

  static String submitScore(int id) => '$baseUrl/questions/$id/score';
}
