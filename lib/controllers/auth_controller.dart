import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../services/api_service.dart';

/// Handles student authentication and persistent session storage.
/// Analogous to Laravel's AuthController.
class AuthController {
  static const _keyName       = 'student_name';
  static const _keyNis        = 'student_nis';
  static const _keyClassMajor = 'student_class_major';
  static const _keyPassword   = 'student_password'; // kept for re-auth on schedule fetch

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Authenticates via the API and persists the session locally.
  /// Returns the authenticated [Student] on success.
  /// Throws [ApiException] on failure.
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

  /// Returns the persisted [Student] if a session exists, or `null`.
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

  /// Returns the saved password for re-authenticating schedule requests.
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  /// Fetches a fresh [Student] profile from the server and updates the
  /// local session. Silently does nothing if there is no saved session.
  /// Returns the refreshed [Student] on success, or `null` on any error.
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
      // Update stored name / class_major in case the admin changed them
      await prefs.setString(_keyName,       fresh.name);
      await prefs.setString(_keyClassMajor, fresh.classMajor);
      return fresh;
    } catch (_) {
      // Non-fatal: return the cached session instead
      return getSession();
    }
  }

  /// Clears the session (logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyNis);
    await prefs.remove(_keyClassMajor);
    await prefs.remove(_keyPassword);
  }

  /// Returns `true` when a session is already saved.
  static Future<bool> isLoggedIn() async {
    final student = await getSession();
    return student != null;
  }
}

