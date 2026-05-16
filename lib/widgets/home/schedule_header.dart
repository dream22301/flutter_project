import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Header row for the schedule section showing the current date.
class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    const days   = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Row(children: [
      const Text(
        'Jadwal Hari ini',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      const Spacer(),
      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        dateStr,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    ]);
  }
}
