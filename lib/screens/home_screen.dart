import 'dart:async';
import 'package:flutter/material.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN  — fetches real data from the Laravel API
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primary = Color(0xFF4C4DDC);
  static const _bg      = Color(0xFFF2F3F8);

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
    // Load session first
    _student = await AuthController.getSession();
    if (!mounted) return;

    // Load announcements and schedule in parallel
    await Future.wait([_loadAnnouncements(), _loadTodaySchedule(), _loadNextSubject()]);
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
      final grouped = await ScheduleController.getSchedulesByDay(
        nis: nis,
        password: password,
      );
      // Get today's Indonesian day name
      final todayKey = _todayDayName();
      final today    = grouped[todayKey] ?? [];
      if (mounted) setState(() { _todaySchedules = today; _loadingSchedule = false; });
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
      final ns = await NextSubjectController.getNextSubject(
        nis: nis, password: password,
      );
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: () async {
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
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _TimeCard(),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _buildStudentCard(),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildNextSubjectSection(),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(title: 'Pengumuman', action: 'Lihat Semua', onAction: () {}),
              )),
              SliverToBoxAdapter(child: _buildAnnouncementsSection()),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: _ScheduleHeader(),
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
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'EduCanvas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _primary, letterSpacing: -0.3),
          ),
          const Spacer(),
          // Logout button
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student Card ──────────────────────────────────────────────────────────
  Widget _buildStudentCard() {
    final name       = _student?.name       ?? '—';
    final classMajor = _student?.shortClassMajor ?? '—';
    final nis        = _student?.nis        ?? '—';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, size: 40, color: _primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        const Text('MURID AKTIF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22C55E), letterSpacing: 0.8)),
                      ]),
                      const SizedBox(height: 4),
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      Text(classMajor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primary)),
                      const SizedBox(height: 10),
                      const Text('NOMOR INDUK SISWA', style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                      Text(nis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('SCHOOL CAMPUS', style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  SizedBox(height: 2),
                  Text('SMK Negeri 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                ])),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFF0F0FF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.apartment_rounded, color: _primary, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Next Subject Section ──────────────────────────────────────────────────
  Widget _buildNextSubjectSection() {
    if (_loadingNextSubject) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_nextSubjectError != null) {
      return const SizedBox.shrink(); // silent fail — don't block the home screen
    }
    if (_nextSubject == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(children: [
          const Icon(Icons.event_available_rounded, color: Color(0xFF22C55E), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tidak ada lagi kelas hari ini 🎉',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
            ),
          ),
        ]),
      );
    }
    return _NextSubjectCard(ns: _nextSubject!);
  }

  // ── Announcements Section ─────────────────────────────────────────────────
  Widget _buildAnnouncementsSection() {
    if (_loadingAnnouncements) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_announcementError != null) {
      return _ErrorBanner(message: _announcementError!);
    }
    if (_announcements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _EmptyState(message: 'Tidak ada pengumuman saat ini.'),
      );
    }
    return Column(
      children: _announcements.take(3).map((a) {
        final color = Color(a.color);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _AnnouncementCard(
            accentColor: color,
            iconBg: color.withOpacity(0.10),
            icon: _iconForPriority(a.prioritas),
            iconColor: color,
            title: a.title,
            body: a.content,
            time: a.publishDate ?? '',
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForPriority(int p) {
    switch (p) {
      case 3: return Icons.warning_amber_rounded;
      case 2: return Icons.info_outline_rounded;
      case 1: return Icons.campaign_rounded;
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
    if (_scheduleError != null) {
      return _ErrorBanner(message: _scheduleError!);
    }
    if (_todaySchedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _EmptyState(message: 'Tidak ada jadwal hari ini.'),
      );
    }
    return Column(
      children: _todaySchedules.take(3).map((s) {
        final now         = DateTime.now();
        final startParts  = s.periodStart.split(':');
        final endParts    = s.periodEnd.split(':');
        final startMin    = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMin      = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        final nowMin      = now.hour * 60 + now.minute;
        final isOngoing   = nowMin >= startMin && nowMin < endMin;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _ScheduleCard(
            timeStart: s.periodStart,
            timeEnd:   s.periodEnd,
            subject:   s.subject,
            detail:    '${s.room}',
            isOngoing: isOngoing,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE CLOCK CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TimeCard extends StatefulWidget {
  @override
  State<_TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<_TimeCard> {
  static const _primary = Color(0xFF4C4DDC);
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_twoDigit(_now.hour)}:${_twoDigit(_now.minute)}:${_twoDigit(_now.second)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFEEEEFF), borderRadius: BorderRadius.circular(50)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time_rounded, size: 18, color: _primary),
            const SizedBox(width: 6),
            Text('Jam: $timeStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primary, letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('JAM PELAJARAN BERJALAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF888888), letterSpacing: 1.0)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
      const Spacer(),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4C4DDC))),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final Color accentColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;

  const _AnnouncementCard({
    required this.accentColor, required this.iconBg, required this.icon,
    required this.iconColor,   required this.title,  required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 12, color: Color(0xFF777777), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500)),
                ],
              ]),
            ),
          ),
          const SizedBox(width: 12),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    const days   = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday-1]}, ${now.day} ${months[now.month-1]}';
    return Row(children: [
      const Text('Jadwal Hari ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
      const Spacer(),
      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF888888)),
      const SizedBox(width: 4),
      Text(dateStr, style: const TextStyle(fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final String timeStart;
  final String timeEnd;
  final String subject;
  final String detail;
  final bool isOngoing;

  const _ScheduleCard({
    required this.timeStart, required this.timeEnd,
    required this.subject,   required this.detail,
    this.isOngoing = false,
  });

  static const _primary = Color(0xFF4C4DDC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        SizedBox(width: 52, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(timeStart, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          Text(timeEnd,   style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
        ])),
        Column(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: isOngoing ? _primary : const Color(0xFFDDDDDD))),
          Container(width: 2, height: 24, color: isOngoing ? _primary.withOpacity(0.2) : const Color(0xFFEEEEEE)),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(detail,  style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
        ])),
        if (isOngoing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
            child: const Text('Ongoing', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)))),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF888888)))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEXT SUBJECT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NextSubjectCard extends StatelessWidget {
  final NextSubject ns;
  const _NextSubjectCard({required this.ns});

  static const _primary = Color(0xFF4C4DDC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5EE8), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.next_plan_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'MATA PELAJARAN SELANJUTNYA',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            Text(
              ns.subject,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.room_outlined, size: 12, color: Colors.white70),
              const SizedBox(width: 3),
              Text(ns.room, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 10),
              const Icon(Icons.access_time_rounded, size: 12, color: Colors.white70),
              const SizedBox(width: 3),
              Text(ns.timeRange, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
