import '../models/next_subject.dart';
import '../services/api_service.dart';

/// Fetches and caches the student's next upcoming subject for today.
/// Analogous to Laravel's NextSubjectController.
class NextSubjectController {
  static NextSubject? _cache;

  /// Returns the next upcoming subject for today, or `null` when there are
  /// no more classes. Uses an in-memory cache; pass [forceRefresh] = true
  /// to bypass.
  static Future<NextSubject?> getNextSubject({
    required String nis,
    required String password,
    bool forceRefresh = false,
  }) async {
    // _cache == null means "not yet fetched"; we use a sentinel flag instead
    // so that a legitimate null (no more classes) is also cached correctly.
    if (!forceRefresh && _fetched) return _cache;

    _cache = await ApiService.getNextSubject(nis: nis, password: password);
    _fetched = true;
    return _cache;
  }

  // Whether we've fetched at least once this session.
  static bool _fetched = false;

  /// Clears the cache (call after logout or when refreshing data).
  static void clearCache() {
    _cache = null;
    _fetched = false;
  }
}
