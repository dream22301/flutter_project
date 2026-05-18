import '../models/question_set.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class QuestionController {
  // ── In-memory cache ────────────────────────────────────────────────────────
  static List<QuestionSet>? _listCache;
  static final Map<int, QuestionSetDetail> _detailCache = {};

  /// GET /api/mobile/questions
  static Future<List<QuestionSet>> getQuestionSets({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _listCache != null) return _listCache!;
    _listCache = await ApiService.getQuestionSets();
    return _listCache!;
  }

  /// GET /api/mobile/questions/{id}
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
  static Future<QuestionSetDetail> getQuestionSetByKey(String keyCode) async {
    final student = await AuthController.getSession();
    final password = await AuthController.getSavedPassword();
    if (student == null || password == null) {
      throw const ApiException(message: 'Sesi kedaluwarsa. Silakan login kembali.', statusCode: 401);
    }
    
    final detail = await ApiService.getQuestionSetByKey(keyCode, student.nis, password);
    _detailCache[detail.id] = detail;
    return detail;
  }

  /// POST /api/mobile/questions/{id}/score
  static Future<void> submitScore({
    required int questionSetId,
    required String nis,
    required String password,
    required double score,
  }) async {
    return ApiService.submitScore(
      questionSetId: questionSetId,
      nis: nis,
      password: password,
      score: score,
    );
  }
}
