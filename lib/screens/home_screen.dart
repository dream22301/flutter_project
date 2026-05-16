import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/announcement_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/next_subject_controller.dart';
import '../controllers/schedule_controller.dart';
import '../models/announcement.dart';
import '../models/next_subject.dart';
import '../models/student.dart';
import '../models/student_schedule.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../widgets/home/announcement_card.dart';
import '../widgets/home/next_subject_card.dart';
import '../widgets/home/schedule_card.dart';
import '../widgets/home/schedule_header.dart';
import '../widgets/home/section_header.dart';
import '../widgets/home/student_card.dart';
import '../widgets/home/time_card.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_banner.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN  — state management + layout only
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  Student?              _student;
  List<Announcement>    _announcements    = [];
  List<StudentSchedule> _todaySchedules   = [];
  NextSubject?          _nextSubject;
  bool   _loadingAnnouncements = true;
  bool   _loadingSchedule      = true;
  bool   _loadingNextSubject   = true;
  String? _announcementError;
  String? _scheduleError;
  String? _nextSubjectError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _student = await AuthController.getSession();
    if (!mounted) return;
    await Future.wait([
      _loadAnnouncements(),
      _loadTodaySchedule(),
      _loadNextSubject(),
    ]);
  }

  Future<void> _loadAnnouncements() async {
    try {
      final data = await AnnouncementController.getAnnouncements();
      if (mounted) setState(() { _announcements = data; _loadingAnnouncements = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _announcementError = e.message; _loadingAnnouncements = false; });
    } catch (_) {
      if (mounted) setState(() { _announcementError = 'Gagal memuat pengumuman.'; _loadingAnnouncements = false; });
    }
  }

  Future<void> _loadTodaySchedule() async {
    final password = await AuthController.getSavedPassword();
    final nis      = _student?.nis ?? '';
    if (nis.isEmpty || password == null) {
      if (mounted) setState(() => _loadingSchedule = false);
      return;
    }
    try {
      final grouped = await ScheduleController.getSchedulesByDay(nis: nis, password: password);
      final todayKey = _todayDayName();
      if (mounted) setState(() { _todaySchedules = grouped[todayKey] ?? []; _loadingSchedule = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _scheduleError = e.message; _loadingSchedule = false; });
    } catch (_) {
      if (mounted) setState(() { _scheduleError = 'Gagal memuat jadwal.'; _loadingSchedule = false; });
    }
  }

  Future<void> _loadNextSubject() async {
    final nis      = _student?.nis ?? '';
    final password = await AuthController.getSavedPassword();
    if (nis.isEmpty || password == null) {
      if (mounted) setState(() => _loadingNextSubject = false);
      return;
    }
    try {
      final ns = await NextSubjectController.getNextSubject(nis: nis, password: password);
      if (mounted) setState(() { _nextSubject = ns; _loadingNextSubject = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _nextSubjectError = e.message; _loadingNextSubject = false; });
    } catch (_) {
      if (mounted) setState(() { _nextSubjectError = 'Gagal memuat mata pelajaran.'; _loadingNextSubject = false; });
    }
  }

  String _todayDayName() {
    const names = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at", 'Sabtu', 'Minggu'];
    return names[DateTime.now().weekday - 1];
  }

  Future<void> _logout() async {
    await AuthController.logout();
    AnnouncementController.clearCache();
    ScheduleController.clearCache();
    NextSubjectController.clearCache();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _onRefresh() async {
    AnnouncementController.clearCache();
    ScheduleController.clearCache();
    NextSubjectController.clearCache();
    setState(() {
      _loadingAnnouncements = true;
      _loadingSchedule      = true;
      _loadingNextSubject   = true;
      _announcementError    = null;
      _scheduleError        = null;
      _nextSubjectError     = null;
    });
    await _loadData();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: const TimeCard(),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: StudentCard(student: _student),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildNextSubjectSection(),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: SectionHeader(title: 'Pengumuman', action: 'Lihat Semua', onAction: () {}),
              )),
              SliverToBoxAdapter(child: _buildAnnouncementsSection()),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: const ScheduleHeader(),
              )),
              SliverToBoxAdapter(child: _buildScheduleSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Text(
          'EduCanvas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.3),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _logout,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
          ),
        ),
      ]),
    );
  }

  // ── Next Subject Section ──────────────────────────────────────────────────
  Widget _buildNextSubjectSection() {
    if (_loadingNextSubject) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_nextSubjectError != null) return const SizedBox.shrink();
    if (_nextSubject == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: const Row(children: [
          Icon(Icons.event_available_rounded, color: AppColors.success, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tidak ada lagi kelas hari ini 🎉',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
            ),
          ),
        ]),
      );
    }
    return NextSubjectCard(ns: _nextSubject!);
  }

  // ── Announcements Section ─────────────────────────────────────────────────
  Widget _buildAnnouncementsSection() {
    if (_loadingAnnouncements) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_announcementError != null) return ErrorBanner(message: _announcementError!);
    if (_announcements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: EmptyState(message: 'Tidak ada pengumuman saat ini.'),
      );
    }
    return Column(
      children: _announcements.take(3).map((a) {
        final color = Color(a.color);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: AnnouncementCard(
            accentColor: color,
            iconBg:      color.withOpacity(0.10),
            icon:        _iconForPriority(a.prioritas),
            iconColor:   color,
            title:       a.title,
            body:        a.content,
            time:        a.publishDate ?? '',
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForPriority(int p) {
    switch (p) {
      case 3:  return Icons.warning_amber_rounded;
      case 2:  return Icons.info_outline_rounded;
      default: return Icons.campaign_rounded;
    }
  }

  // ── Schedule Section ──────────────────────────────────────────────────────
  Widget _buildScheduleSection() {
    if (_loadingSchedule) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_scheduleError != null) return ErrorBanner(message: _scheduleError!);
    if (_todaySchedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: EmptyState(message: 'Tidak ada jadwal hari ini.'),
      );
    }
    return Column(
      children: _todaySchedules.take(3).map((s) {
        final now       = DateTime.now();
        final isOngoing = () {
          final st = s.startTime;
          final et = s.endTime;
          if (st == null || et == null) return false;
          final sp = st.split(':');
          final ep = et.split(':');
          if (sp.length < 2 || ep.length < 2) return false;
          final startMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
          final endMin   = int.parse(ep[0]) * 60 + int.parse(ep[1]);
          final nowMin   = now.hour * 60 + now.minute;
          return nowMin >= startMin && nowMin < endMin;
        }();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ScheduleCard(
            timeStart: s.startDisplay,
            timeEnd:   s.endDisplay,
            subject:   s.subject,
            detail:    s.room,
            isOngoing: isOngoing,
          ),
        );
      }).toList(),
    );
  }
}
