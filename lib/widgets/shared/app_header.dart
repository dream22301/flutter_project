import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Shared page header — used by ALL screens for visual consistency.
/// Analogous to a Laravel Blade component (@component('header')).
///
/// Set [showBack] = true on detail/nested screens to show a back arrow
/// instead of the branded icon.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing = const [],
    this.showBack = false,
  });

  final IconData  icon;
  final String    title;
  final String?   subtitle;
  final List<Widget> trailing; // action buttons on the right
  final bool      showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading — back button or branded icon
          GestureDetector(
            onTap: showBack ? () => Navigator.maybePop(context) : null,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: showBack ? AppColors.primaryLight : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                showBack ? Icons.arrow_back_rounded : icon,
                color: showBack ? AppColors.primary : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title + optional subtitle
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: subtitle != null ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Trailing actions
          ...trailing,
        ],
      ),
    );
  }
}

/// Small icon-button helper used in [AppHeader.trailing].
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.bgColor   = AppColors.surface,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
