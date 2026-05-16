import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/student_schedule.dart';

/// Detailed schedule card used in the JadwalScreen timeline list.
/// Visually differs based on whether the class is ongoing, past, or upcoming.
class EntryCard extends StatelessWidget {
  final StudentSchedule entry;
  final bool ongoing;
  final bool past;

  const EntryCard({
    super.key,
    required this.entry,
    required this.ongoing,
    required this.past,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg       = past ? AppColors.surfaceAlt : AppColors.surface;
    final Color borderColor  = ongoing ? AppColors.primary : Colors.transparent;
    final Color subjectColor = past ? AppColors.textLight : AppColors.textDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: ongoing ? 1.5 : 0),
        boxShadow: ongoing
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Time column
        SizedBox(
          width: 70,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              entry.startDisplay,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ongoing ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.endDisplay,
              style: TextStyle(
                fontSize: 12,
                color: past ? const Color(0xFFCCCCCC) : AppColors.textMuted,
              ),
            ),
          ]),
        ),
        // Vertical divider
        Container(
          width: 1.5,
          height: 44,
          margin: const EdgeInsets.only(right: 12),
          color: ongoing ? AppColors.primary.withOpacity(0.30) : AppColors.divider,
        ),
        // Subject info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              entry.subject,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: subjectColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(children: [
              Icon(
                Icons.room_outlined,
                size: 12,
                color: past ? const Color(0xFFCCCCCC) : AppColors.textMuted,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  entry.room,
                  style: TextStyle(
                    fontSize: 12,
                    color: past ? const Color(0xFFCCCCCC) : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ]),
        ),
        // Status badge / icon
        const SizedBox(width: 8),
        if (ongoing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ongoing',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.successDark,
              ),
            ),
          )
        else if (past)
          const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFFCCCCCC))
        else
          const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFDDDDDD)),
      ]),
    );
  }
}
