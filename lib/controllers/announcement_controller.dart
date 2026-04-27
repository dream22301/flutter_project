import '../models/announcement.dart';
import '../services/api_service.dart';

/// Fetches and caches announcements from the Laravel API.
/// Analogous to Laravel's AnnouncementController.
class AnnouncementController {
  // Simple in-memory cache to avoid duplicate requests within the same session.
  static List<Announcement>? _cache;

  /// Returns announcements, using the in-memory cache when available.
  static Future<List<Announcement>> getAnnouncements({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await ApiService.getAnnouncements();
    return _cache!;
  }

  /// Clears the cache (call after logout).
  static void clearCache() => _cache = null;
}
