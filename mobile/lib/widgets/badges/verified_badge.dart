import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    this.size = 18,
    this.role = 'creator',
  });

  final double size;
  final String role;

  Color get _color => role == 'brand' ? AppColors.pink : AppColors.neon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check_rounded,
        size: size * 0.6,
        color: role == 'brand' ? AppColors.white : AppColors.ink,
      ),
    );
  }
}
