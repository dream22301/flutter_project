import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Live digital clock card shown at the top of HomeScreen.
class TimeCard extends StatefulWidget {
  const TimeCard({super.key});

  @override
  State<TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  String _getCurrentPeriod() {
    final now = _now;
    final d = now.weekday; // 1=Senin, 2=Selasa, ..., 5=Jumat
    final nMin = now.hour * 60 + now.minute; // Ubah waktu sekarang ke format menit total

    // Fungsi kecil untuk mengecek apakah waktu saat ini berada di antara start & end
    bool isBetween(String start, String end) {
      final s = start.split(':');
      final e = end.split(':');
      final sMin = int.parse(s[0]) * 60 + int.parse(s[1]);
      final eMin = int.parse(e[0]) * 60 + int.parse(e[1]);
      return nMin >= sMin && nMin < eMin;
    }

    if (d == 1) { // Senin
      if (isBetween("08:00", "08:40")) return "JAM PELAJARAN KE 1";
      if (isBetween("08:40", "09:20")) return "JAM PELAJARAN KE 2";
      if (isBetween("09:20", "10:00")) return "JAM PELAJARAN KE 3";
      if (isBetween("10:00", "10:15")) return "WAKTU ISTIRAHAT";
      if (isBetween("10:15", "10:55")) return "JAM PELAJARAN KE 4";
      if (isBetween("10:55", "11:35")) return "JAM PELAJARAN KE 5";
      if (isBetween("11:35", "12:15")) return "JAM PELAJARAN KE 6";
      if (isBetween("12:15", "13:00")) return "WAKTU ISHOMA";
      if (isBetween("13:00", "13:55")) return "JAM PELAJARAN KE 7";
      if (isBetween("13:55", "14:35")) return "JAM PELAJARAN KE 8";
      if (isBetween("14:35", "15:15")) return "JAM PELAJARAN KE 9";
    } else if (d == 5) { // Jumat
      if (isBetween("08:00", "08:40")) return "JAM PELAJARAN KE 1";
      if (isBetween("08:40", "09:20")) return "JAM PELAJARAN KE 2";
      if (isBetween("09:20", "10:00")) return "JAM PELAJARAN KE 3";
      if (isBetween("10:00", "10:40")) return "JAM PELAJARAN KE 4";
      if (isBetween("10:40", "12:20")) return "WAKTU ISHOMA";
      if (isBetween("12:20", "13:15")) return "JAM PELAJARAN KE 5";
      if (isBetween("13:15", "13:55")) return "JAM PELAJARAN KE 6";
      if (isBetween("13:55", "14:35")) return "JAM PELAJARAN KE 7";
      if (isBetween("14:35", "15:15")) return "JAM PELAJARAN KE 8";
    } else if (d >= 2 && d <= 4) { // Selasa, Rabu, Kamis
      if (isBetween("07:00", "07:40")) return "JAM PELAJARAN KE 1";
      if (isBetween("07:40", "08:20")) return "JAM PELAJARAN KE 2";
      if (isBetween("08:20", "09:00")) return "JAM PELAJARAN KE 3";
      if (isBetween("09:00", "09:40")) return "JAM PELAJARAN KE 4";
      if (isBetween("09:40", "09:55")) return "WAKTU ISTIRAHAT";
      if (isBetween("09:55", "10:35")) return "JAM PELAJARAN KE 5";
      if (isBetween("10:35", "11:15")) return "JAM PELAJARAN KE 6";
      if (isBetween("11:15", "11:55")) return "JAM PELAJARAN KE 7";
      if (isBetween("11:55", "12:35")) return "WAKTU ISHOMA";
      if (isBetween("12:35", "13:30")) return "JAM PELAJARAN KE 8";
      if (isBetween("13:30", "14:10")) return "JAM PELAJARAN KE 9";
      if (isBetween("14:10", "14:50")) return "JAM PELAJARAN KE 10";
      if (isBetween("14:50", "15:30")) return "JAM PELAJARAN KE 11";
    }

    return "DILUAR JAM PELAJARAN";
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_twoDigit(_now.hour)}:${_twoDigit(_now.minute)}:${_twoDigit(_now.second)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Jam: $timeStr',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(
          _getCurrentPeriod(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1.0,
          ),
        ),
      ]),
    );
  }
}
