import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class BCLogo extends StatelessWidget {
  final bool isDark;
  final double? fontSize;

  const BCLogo({
    super.key,
    this.isDark = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final displayStyle = fontSize != null
        ? AppTypography.displayMD.copyWith(fontSize: fontSize)
        : AppTypography.displayMD;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Beyond',
          style: displayStyle.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.neon,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'C',
            style: displayStyle.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
