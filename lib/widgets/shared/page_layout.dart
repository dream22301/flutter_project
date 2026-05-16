import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'app_header.dart';

/// Master page scaffold — analogous to Laravel's layouts/app.blade.php.
///
/// Every screen should wrap its content with [PageLayout] instead of
/// building [Scaffold] + [SafeArea] from scratch. This guarantees:
///   • Consistent background colour across the app.
///   • The [AppHeader] is always at a fixed, identical Y-position.
///   • An optional [subHeader] slot (e.g. the day-picker in JadwalScreen).
///   • The [body] fills all remaining space.
///
/// Usage:
/// ```dart
/// PageLayout(
///   header: AppHeader(icon: Icons.home_rounded, title: 'Home'),
///   body: ListView(children: [...]),
/// )
/// ```
class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    required this.body,
    this.header,
    this.subHeader,
  });

  /// The [AppHeader] shown at the top (optional — pass null to hide).
  final AppHeader? header;

  /// An optional fixed widget rendered between the header and the body
  /// (e.g. day-picker tabs in JadwalScreen).
  final Widget? subHeader;

  /// The main scrollable / interactive content of the page.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null)
              // Subtle bottom shadow separates header from content
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: header!,
              ),
            ?subHeader,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
