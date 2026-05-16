import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A red banner used to display API / network error messages.
/// Used across HomeScreen, JadwalScreen, and QuestionScreen.
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.dangerDark),
            ),
          ),
        ]),
      ),
    );
  }
}
