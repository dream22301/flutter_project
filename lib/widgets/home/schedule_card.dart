import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A compact schedule row card shown on the HomeScreen dashboard.
/// Shows start/end time, subject name, room, and an "Ongoing" badge.
class ScheduleCard extends StatelessWidget {
  final String timeStart;
  final String timeEnd;
  final String subject;
  final String detail;
  final bool isOngoing;

  const ScheduleCard({
    super.key,
    required this.timeStart,
    required this.timeEnd,
    required this.subject,
    required this.detail,
    this.isOngoing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        SizedBox(
          width: 52,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              timeStart,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              timeEnd,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ]),
        ),
        Column(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOngoing ? AppColors.primary : const Color(0xFFDDDDDD),
            ),
          ),
          Container(
            width: 2,
            height: 24,
            color: isOngoing
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.divider,
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ]),
        ),
        if (isOngoing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ongoing',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.successDark,
              ),
            ),
          ),
      ]),
    );
  }
}
