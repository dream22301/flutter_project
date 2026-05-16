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
        const Text(
          'JAM PELAJARAN BERJALAN',
          style: TextStyle(
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
