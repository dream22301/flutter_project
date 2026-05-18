import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'app_header.dart';

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    required this.body,
    this.header,
    this.subHeader,
  });

  final AppHeader? header;

  final Widget? subHeader;

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
