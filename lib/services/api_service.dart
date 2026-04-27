import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/announcement.dart';
import '../models/student.dart';
import '../models/student_schedule.dart';

/// Central HTTP client — all raw API calls live here.
/// Think of this as the Repository layer (analogous to Laravel Services).
class ApiService {
  ApiService._();

  // ── Headers ──────────────────────────────────────────────────────────────
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
  };

  // ── Student Login ─────────────────────────────────────────────────────────

  /// POST /api/mobile/student/login
  /// Returns [Student] on success or throws [ApiException].
  static Future<Student> loginStudent({
    required String nis,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.studentLogin),
          headers: _headers,
          body: jsonEncode({'nis': nis, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return Student.fromJson(body['student'] as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: body['message'] as String? ?? 'Login gagal.',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Announcements ─────────────────────────────────────────────────────────

  /// GET /api/mobile/announcements
  /// Returns a list of [Announcement].
  static Future<List<Announcement>> getAnnouncements() async {
    final response = await http
        .get(Uri.parse(ApiConfig.announcements), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        message: 'Gagal memuat pengumuman.',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Student Schedule ──────────────────────────────────────────────────────

  /// GET /api/mobile/student-schedule?nis=…&password=…
  /// Returns a map with keys: `student` ([Student]) and
  /// `schedules` (List<[StudentSchedule]>).
  static Future<Map<String, dynamic>> getStudentSchedule({
    required String nis,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.studentSchedule).replace(
      queryParameters: {'nis': nis, 'password': password},
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final student = Student.fromJson(
        body['student'] as Map<String, dynamic>,
      );
      final schedules = (body['schedules'] as List<dynamic>)
          .map((e) => StudentSchedule.fromJson(e as Map<String, dynamic>))
          .toList();

      return {'student': student, 'schedules': schedules};
    } else {
      throw ApiException(
        message: body['message'] as String? ?? 'Gagal memuat jadwal.',
        statusCode: response.statusCode,
      );
    }
  }
}

// ── API Exception ─────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
