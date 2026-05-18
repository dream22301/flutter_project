import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class AuthController {
  static const _keyName       = 'student_name';
  static const _keyNis        = 'student_nis';
  static const _keyClassMajor = 'student_class_major';
  static const _keyPassword   = 'student_password';

  // ── Login ─────────────────────────────────────────────────────────────────

  static Future<Student> login({
    required String nis,
    required String password,
  }) async {
    final student = await ApiService.loginStudent(nis: nis, password: password);
    await _saveSession(student, password);
    return student;
  }

  // ── Session ───────────────────────────────────────────────────────────────

  static Future<void> _saveSession(Student student, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName,       student.name);
    await prefs.setString(_keyNis,        student.nis);
    await prefs.setString(_keyClassMajor, student.classMajor);
    await prefs.setString(_keyPassword,   password);
  }

  static Future<Student?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final nis = prefs.getString(_keyNis);
    if (nis == null || nis.isEmpty) return null;

    return Student(
      name:       prefs.getString(_keyName)       ?? '',
      nis:        nis,
      classMajor: prefs.getString(_keyClassMajor) ?? '',
    );
  }

  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  static Future<Student?> refreshProfile() async {
    final prefs    = await SharedPreferences.getInstance();
    final nis      = prefs.getString(_keyNis);
    final password = prefs.getString(_keyPassword);
    if (nis == null || nis.isEmpty || password == null) return null;

    try {
      final fresh = await ApiService.getStudentProfile(
        nis: nis,
        password: password,
      );
      await prefs.setString(_keyName,       fresh.name);
      await prefs.setString(_keyClassMajor, fresh.classMajor);
      return fresh;
    } catch (_) {
      return getSession();
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyNis);
    await prefs.remove(_keyClassMajor);
    await prefs.remove(_keyPassword);
  }

  static Future<bool> isLoggedIn() async {
    final student = await getSession();
    return student != null;
  }
}

