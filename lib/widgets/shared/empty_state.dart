import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A generic "no data" empty-state widget.
/// Used across HomeScreen, JadwalScreen, and QuestionScreen.
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
