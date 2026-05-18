import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
