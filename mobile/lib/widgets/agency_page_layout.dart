import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'agency_page_top_header.dart';

class AgencyPageLayout extends ConsumerWidget {
  const AgencyPageLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.showHeader = true,
  });

  final Widget child;
  final int currentIndex;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).brightness;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap + 16;

    final bg = theme == Brightness.dark ? AppColors.darkBg : AppColors.lightBg;

    return Stack(
      children: [
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: bg))),
        Positioned(
          top: -46,
          right: -32,
          child: _GlowOrb(
            size: 136,
            color: AppColors.agencyPrimary.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          top: 220,
          left: -44,
          child: _GlowOrb(
            size: 112,
            color: AppColors.agencyDark.withValues(
              alpha: theme == Brightness.dark ? 0.14 : 0.08,
            ),
          ),
        ),
        Positioned(
          top: topInset - 20,
          right: -60,
          child: _AmbientGlow(
            size: 180,
            color: AppColors.agencyPrimary.withValues(alpha: 0.15),
          ),
        ),
        if (showHeader)
          Positioned(
            top: topInset,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: const AgencyPageTopHeader(),
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: size * 0.55, spreadRadius: size * 0.04)],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}