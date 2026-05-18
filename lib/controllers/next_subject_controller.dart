import '../models/next_subject.dart';
import '../services/api_service.dart';

class NextSubjectController {
  static NextSubject? _cache;

  static Future<NextSubject?> getNextSubject({
    required String nis,
    required String password,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _fetched) return _cache;

    _cache = await ApiService.getNextSubject(nis: nis, password: password);
    _fetched = true;
    return _cache;
  }

  static bool _fetched = false;

  static void clearCache() {
    _cache = null;
    _fetched = false;
  }
}
