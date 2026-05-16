import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/announcement_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/announcement.dart';
import '../widgets/home/announcement_card.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_banner.dart';
import '../widgets/shared/page_layout.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  List<Announcement> _announcements = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final student = await AuthController.getSession();
      final classMajor = student?.classMajor ?? '';
      
      final data = await AnnouncementController.getAnnouncements(
        classMajor,
        forceRefresh: forceRefresh,
      );
      
      if (mounted) {
        setState(() {
          _announcements = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat daftar pengumuman.';
          _loading = false;
        });
      }
    }
  }

  IconData _iconForPriority(int p) {
    switch (p) {
      case 3:  return Icons.warning_rounded; // Penting: aggressive red
      case 2:  return Icons.campaign_rounded; // Peringatan: yellow speaker
      case 1:  return Icons.campaign_rounded; // Info: blue speaker
      default: return Icons.chat_bubble_outline_rounded; // Normal: gray relaxing
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: AppHeader(
        icon: Icons.campaign_rounded,
        title: 'Semua Pengumuman',
        showBack: true,
        trailing: [
          HeaderAction(
            icon: Icons.refresh_rounded,
            onTap: () => _loadAnnouncements(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorBanner(message: _error!),
      );
    }
    
    if (_announcements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyState(message: 'Tidak ada pengumuman saat ini.'),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadAnnouncements(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final a = _announcements[index];
          final color = Color(a.color);
          
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AnnouncementCard(
              accentColor: color,
              iconBg: color.withValues(alpha: 0.10),
              icon: _iconForPriority(a.prioritas),
              iconColor: color,
              title: a.title,
              body: a.content,
              time: a.publishDate ?? '',
            ),
          );
        },
      ),
    );
  }
}
