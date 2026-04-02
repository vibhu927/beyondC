import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({
    super.key,
    required this.creator,
    this.onTap,
    this.onSendRequest,
  });

  final CreatorPreview creator;
  final VoidCallback? onTap;
  final VoidCallback? onSendRequest;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.neon,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor(creator.initials),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  creator.initials,
                  style: AppTypography.labelMD.copyWith(color: AppColors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            creator.firstName,
                            style: AppTypography.labelLG,
                          ),
                        ),
                        BCBadge(
                          label: creator.instagramVerified
                              ? '🔵 Verified'
                              : '⚠️ Unverified',
                          variant: creator.instagramVerified
                              ? BCBadgeVariant.blue
                              : BCBadgeVariant.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        BCBadge(
                          label: creator.tier,
                          variant: _tierVariant(creator.tier),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: creator.niches
                          .take(2)
                          .map((niche) => BCBadge(
                              label: niche, variant: BCBadgeVariant.outline))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Text(
                          creator.followerRange,
                          style: AppTypography.labelSM,
                        ),
                        Text(
                          '${creator.engagementRate.toStringAsFixed(1)}% engagement',
                          style: AppTypography.bodySM,
                        ),
                        Text(
                          'from ${_rupees(creator.startingPrice)}',
                          style: AppTypography.bodySM,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '1 credit on acceptance',
                  style: AppTypography.bodyXS,
                ),
              ),
              GestureDetector(
                onTap: onSendRequest ?? onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Text(
                    'Send Request →',
                    style:
                        AppTypography.labelSM.copyWith(color: AppColors.neon),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreatorCardSkeleton extends StatelessWidget {
  const CreatorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightDivider,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceAlt
          : AppColors.lightSurfaceAlt,
      child: BCCard(
        shadow: AppShadows.neon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: AppColors.white, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 18, width: 120, color: AppColors.white),
                      const SizedBox(height: AppSpacing.sm),
                      Container(height: 26, width: 150, color: AppColors.white),
                      const SizedBox(height: AppSpacing.md),
                      Container(height: 14, width: 190, color: AppColors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(height: 12, width: 54, color: AppColors.white),
                const Spacer(),
                Container(height: 34, width: 118, color: AppColors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

BCBadgeVariant _tierVariant(String tier) {
  switch (tier.toLowerCase()) {
    case 'mid':
      return BCBadgeVariant.blue;
    case 'macro':
      return BCBadgeVariant.purple;
    case 'nano':
    case 'micro':
      return BCBadgeVariant.neon;
    default:
      return BCBadgeVariant.outline;
  }
}

String _rupees(int value) =>
    '₹${NumberFormat.decimalPattern('en_IN').format(value)}';

Color _avatarColor(String initials) {
  const palette = [
    AppColors.blue,
    AppColors.pink,
    AppColors.purple,
    AppColors.orange
  ];
  return palette[initials.codeUnitAt(0) % palette.length];
}
