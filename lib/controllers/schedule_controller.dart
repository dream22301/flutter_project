import '../models/student_schedule.dart';
import '../services/api_service.dart';

/// Fetches student schedules from the Laravel API and groups them by day.
/// Analogous to Laravel's StudentScheduleController.
class ScheduleController {
  static Map<String, List<StudentSchedule>>? _cache;

  /// Returns schedules grouped by day name (e.g. 'Senin', 'Selasa', …).
  /// Uses an in-memory cache; pass [forceRefresh] = true to bypass.
  static Future<Map<String, List<StudentSchedule>>> getSchedulesByDay({
    required String nis,
    required String password,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) return _cache!;

    final result = await ApiService.getStudentSchedule(
      nis: nis,
      password: password,
    );

    final schedules = result['schedules'] as List<StudentSchedule>;

    // Group by day name
    final Map<String, List<StudentSchedule>> grouped = {};
    for (final s in schedules) {
      grouped.putIfAbsent(s.day, () => []).add(s);
    }

    // Sort each day's entries by period_start
    for (final list in grouped.values) {
      list.sort((a, b) => a.periodStart.compareTo(b.periodStart));
    }

    _cache = grouped;
    return _cache!;
  }

  /// Clears the cache (call after logout).
  static void clearCache() => _cache = null;
}
