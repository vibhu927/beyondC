import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'buttons/bc_back_button.dart';

class BCGlassHeaderBar extends StatelessWidget {
  const BCGlassHeaderBar({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppSpacing.radiusXL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.84),
                Colors.black.withValues(alpha: 0.66),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppSpacing.radiusXL),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              BCBackButton(
                onPressed: onBack,
                iconColor: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.22),
                borderColor: Colors.white.withValues(alpha: 0.25),
                buttonSize: 36,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.displaySM.copyWith(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              trailing ?? const SizedBox.square(dimension: 48),
            ],
          ),
        ),
      ),
    );
  }
}
