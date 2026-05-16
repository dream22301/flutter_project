import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A titled section header row with an optional action link.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      const Spacer(),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
    ]);
  }
}
