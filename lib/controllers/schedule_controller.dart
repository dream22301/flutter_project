import '../models/student_schedule.dart';
import '../services/api_service.dart';

class ScheduleController {
  static Map<String, List<StudentSchedule>>? _cache;

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

    // Sort Asc
    for (final list in grouped.values) {
      list.sort((a, b) => a.periodStart.compareTo(b.periodStart));
    }

    _cache = grouped;
    return _cache!;
  }

  static void clearCache() => _cache = null;
}
