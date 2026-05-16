import '../models/question_set.dart';
import '../services/api_service.dart';

/// Fetches question sets from the Laravel API.
/// Analogous to the web's QuestionController.
class QuestionController {
  // ── In-memory cache ────────────────────────────────────────────────────────
  static List<QuestionSet>? _listCache;
  static final Map<int, QuestionSetDetail> _detailCache = {};

  /// GET /api/mobile/questions
  /// Returns all question sets (title, key_code, question count).
  /// Uses an in-memory cache; pass [forceRefresh] = true to bypass.
  static Future<List<QuestionSet>> getQuestionSets({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _listCache != null) return _listCache!;
    _listCache = await ApiService.getQuestionSets();
    return _listCache!;
  }

  /// GET /api/mobile/questions/{id}
  /// Returns a [QuestionSetDetail] with all nested questions.
  /// Uses an in-memory cache per ID; pass [forceRefresh] = true to bypass.
  static Future<QuestionSetDetail> getQuestionSetDetail(
    int id, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _detailCache.containsKey(id)) {
      return _detailCache[id]!;
    }
    final detail = await ApiService.getQuestionSetDetail(id);
    _detailCache[id] = detail;
    return detail;
  }

  /// Clears all cached question data (call after logout).
  static void clearCache() {
    _listCache = null;
    _detailCache.clear();
  }
  /// GET /api/mobile/questions/key/{key_code}
  /// Finds a question set by its key code.
  static Future<QuestionSetDetail> getQuestionSetByKey(String keyCode) async {
    final detail = await ApiService.getQuestionSetByKey(keyCode);
    _detailCache[detail.id] = detail;
    return detail;
  }
}
