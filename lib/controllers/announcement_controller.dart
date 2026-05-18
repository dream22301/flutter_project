import '../models/announcement.dart';
import '../services/api_service.dart';

class AnnouncementController {
  static List<Announcement>? _cache;

  static Future<List<Announcement>> getAnnouncements(String classMajor, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await ApiService.getAnnouncements(classMajor);
    return _cache!;
  }

  static void clearCache() => _cache = null;
}
