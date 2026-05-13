import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'agency_page_top_header.dart';

class AgencyPageLayout extends ConsumerWidget {
  final double collapseProgress;
  final double? scrollOffset;

  const AgencyPageLayout({
    super.key,
    required this.child,
    this.collapseProgress = 0.0,
    this.scrollOffset,
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
    final headerSlide = (scrollOffset ?? 0.0).clamp(0.0, sheetTop);
    final progress = (headerSlide / (headerHeight + headerGap)).clamp(0.0, 1.0);
    final collapsedTop = MediaQuery.of(context).padding.top + 8;
    final headerTop = lerpDouble(topInset, collapsedTop, progress)!;

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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: collapsedTop + 48 + 16,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightBg.withValues(alpha: progress * 0.95),
                border: progress > 0.5
                    ? const Border(
                        bottom: BorderSide(color: AppColors.lightBorder),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (showHeader)
          Positioned(
            top: headerTop,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: AgencyPageTopHeader(collapseProgress: progress),
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