import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/schedule_controller.dart';
import '../models/student_schedule.dart';
import '../services/api_service.dart';
import '../widgets/jadwal/entry_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JADWAL SCREEN  — state management + layout only
// ─────────────────────────────────────────────────────────────────────────────

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  static const _days     = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
  static const _daysFull = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at"];

  late int _selectedDay;

  // ── API state ─────────────────────────────────────────────────────────────
  Map<String, List<StudentSchedule>> _grouped = {};
  bool    _loading = true;
  String? _error;
  String  _classMajor = '';

  @override
  void initState() {
    super.initState();
    final todayWeekday = DateTime.now().weekday;
    _selectedDay = (todayWeekday >= 1 && todayWeekday <= 5) ? todayWeekday - 1 : 0;
    _loadSchedule();
  }

  Future<void> _loadSchedule({bool forceRefresh = false}) async {
    setState(() { _loading = true; _error = null; });

    final student  = await AuthController.getSession();
    final password = await AuthController.getSavedPassword();

    if (student == null || password == null) {
      if (mounted) setState(() { _error = 'Sesi tidak ditemukan. Silakan login ulang.'; _loading = false; });
      return;
    }

    _classMajor = student.shortClassMajor;

    try {
      final grouped = await ScheduleController.getSchedulesByDay(
        nis: student.nis,
        password: password,
        forceRefresh: forceRefresh,
      );
      if (mounted) setState(() { _grouped = grouped; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Tidak dapat terhubung ke server.'; _loading = false; });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<StudentSchedule> get _selectedEntries => _grouped[_daysFull[_selectedDay]] ?? [];

  bool _isOngoing(StudentSchedule s) {
    final now = DateTime.now();
    if (_selectedDay != now.weekday - 1) return false;
    final st = s.startTime; final et = s.endTime;
    if (st == null || et == null) return false;
    final sp = st.split(':'); final ep = et.split(':');
    if (sp.length < 2 || ep.length < 2) return false;
    final startMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
    final endMin   = int.parse(ep[0]) * 60 + int.parse(ep[1]);
    final nowMin   = now.hour * 60 + now.minute;
    return nowMin >= startMin && nowMin < endMin;
  }

  bool _isPast(StudentSchedule s) {
    final now = DateTime.now();
    if (_selectedDay != now.weekday - 1) return false;
    final et = s.endTime;
    if (et == null) return false;
    final ep = et.split(':');
    if (ep.length < 2) return false;
    final endMin = int.parse(ep[0]) * 60 + int.parse(ep[1]);
    return now.hour * 60 + now.minute >= endMin;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildDayPicker(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final now = DateTime.now();
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    final dateLabel = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Jadwal Pelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.3)),
            Text(dateLabel, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(width: 8),
        if (_classMajor.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _classMajor,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _loadSchedule(forceRefresh: true),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
          ),
        ),
      ]),
    );
  }

  // ── Day Picker ─────────────────────────────────────────────────────────────
  Widget _buildDayPicker() {
    final todayIdx = DateTime.now().weekday - 1;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_days.length, (i) {
          final isSelected = i == _selectedDay;
          final isToday    = i == todayIdx;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(
                  _days[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? (isSelected ? Colors.white.withOpacity(0.8) : AppColors.primary)
                        : Colors.transparent,
                  ),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.primary.withOpacity(0.18)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadSchedule(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
        ),
      );
    }
    final entries = _selectedEntries;
    if (entries.isEmpty) return _buildEmpty();
    return _buildScheduleList(entries);
  }

  // ── Schedule Timeline List ─────────────────────────────────────────────────
  Widget _buildScheduleList(List<StudentSchedule> entries) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildDayHeader(entries.length);
        final entry   = entries[index - 1];
        final ongoing = _isOngoing(entry);
        final past    = _isPast(entry);
        return _buildTimelineRow(entry, ongoing, past, index - 1, entries.length);
      },
    );
  }

  Widget _buildDayHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_daysFull[_selectedDay], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text('$count mata pelajaran', style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _buildTimelineRow(StudentSchedule entry, bool ongoing, bool past, int idx, int total) {
    final isLast    = idx == total - 1;
    final dotColor  = ongoing ? AppColors.primary : (past ? const Color(0xFFCCCCCC) : const Color(0xFFDDDDDD));
    final lineColor = ongoing ? AppColors.primary.withOpacity(0.20) : AppColors.divider;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            Container(
              width: 12, height: 12,
              margin: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: ongoing
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 6, spreadRadius: 1)]
                    : [],
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: lineColor, borderRadius: BorderRadius.circular(1)),
                ),
              ),
            if (isLast) const SizedBox(height: 8),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EntryCard(entry: entry, ongoing: ongoing, past: past),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.weekend_rounded, size: 72, color: AppColors.primary.withOpacity(0.18)),
        const SizedBox(height: 16),
        const Text('Tidak ada jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 6),
        const Text(
          'Hari ini tidak ada mata pelajaran.\nNikmati waktu istirahat kamu! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
      ]),
    );
  }
}
