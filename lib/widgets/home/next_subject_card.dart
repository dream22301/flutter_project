import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/next_subject.dart';

/// Gradient card showing the next upcoming subject for the student.
class NextSubjectCard extends StatelessWidget {
  final NextSubject ns;
  const NextSubjectCard({super.key, required this.ns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryAlt, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.next_plan_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MATA PELAJARAN SELANJUTNYA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ns.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
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
            ],
          ),
        ),
      ]),
    );
  }
}
