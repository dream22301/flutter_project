import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/announcement.dart';
import '../models/next_subject.dart';
import '../models/question_set.dart';
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

  // ── Student Profile ───────────────────────────────────────────────────────

  /// GET /api/mobile/student/profile?nis=…&password=…
  /// Returns a fresh [Student] from the server (used to refresh local session).
  static Future<Student> getStudentProfile({
    required String nis,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.studentProfile).replace(
      queryParameters: {'nis': nis, 'password': password},
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return Student.fromJson(body['student'] as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: body['message'] as String? ?? 'Gagal memuat profil.',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Announcements ─────────────────────────────────────────────────────────

  /// GET /api/mobile/announcements?class_major=…
  /// Returns a list of [Announcement] filtered by class.
  static Future<List<Announcement>> getAnnouncements(String classMajor) async {
    final uri = Uri.parse(ApiConfig.announcements).replace(
      queryParameters: {'class_major': classMajor},
    );

    final response = await http
        .get(uri, headers: _headers)
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

  /// GET /api/mobile/announcements/{id}
  /// Returns a single [Announcement] or throws [ApiException] on 404.
  static Future<Announcement> getAnnouncementDetail(int id) async {
    final response = await http
        .get(Uri.parse(ApiConfig.announcementDetail(id)), headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Announcement.fromJson(body as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: (body as Map<String, dynamic>)['message'] as String? ??
            'Pengumuman tidak ditemukan.',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Student Schedule ──────────────────────────────────────────────────────

  /// GET /api/mobile/student-schedule?nis=…&password=…
  /// Returns a map with keys: `student` ([Student]) and
  /// `schedules` (List<[StudentSchedule]>).
  /// Each schedule now also carries `start_time`/`end_time` (HH:MM) from the
  /// teacher's schedule cross-reference.
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

  // ── Next Subject ──────────────────────────────────────────────────────────

  /// GET /api/mobile/next-subject?nis=…&password=…
  /// Returns [NextSubject] if there is an upcoming class today, or `null`
  /// when all classes are done / today is a non-school day.
  static Future<NextSubject?> getNextSubject({
    required String nis,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.nextSubject).replace(
      queryParameters: {'nis': nis, 'password': password},
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final raw = body['next_subject'];
      if (raw == null) return null;
      return NextSubject.fromJson(raw as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: body['message'] as String? ?? 'Gagal memuat mata pelajaran.',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  /// GET /api/mobile/questions
  /// Returns the list of all [QuestionSet] (without nested questions).
  static Future<List<QuestionSet>> getQuestionSets() async {
    final response = await http
        .get(Uri.parse(ApiConfig.questions), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => QuestionSet.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        message: 'Gagal memuat daftar soal.',
        statusCode: response.statusCode,
      );
    }
  }

  /// GET /api/mobile/questions/{id}
  /// Returns a [QuestionSetDetail] with all nested questions.
  static Future<QuestionSetDetail> getQuestionSetDetail(int id) async {
    final response = await http
        .get(Uri.parse(ApiConfig.questionDetail(id)), headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return QuestionSetDetail.fromJson(body as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: (body as Map<String, dynamic>)['message'] as String? ??
            'Paket soal tidak ditemukan.',
        statusCode: response.statusCode,
      );
    }
  }
  /// GET /api/mobile/questions/key/{key_code}
  /// Returns a [QuestionSetDetail] with all nested questions by its key code.
  static Future<QuestionSetDetail> getQuestionSetByKey(String keyCode) async {
    final response = await http
        .get(Uri.parse(ApiConfig.questionByKey(keyCode)), headers: _headers)
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return QuestionSetDetail.fromJson(body as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: (body as Map<String, dynamic>)['message'] as String? ??
            'Paket soal tidak ditemukan.',
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
