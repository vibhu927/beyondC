import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.width = 280,
  });

  final Campaign campaign;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final visibleDeliverables = campaign.deliverables.take(2).toList();
    final extraCount =
        campaign.deliverables.length - visibleDeliverables.length;

    return SizedBox(
      width: width,
      child: BCCard(
        onTap: onTap,
        shadow: AppShadows.pink,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _avatarColor(campaign.brandInitial),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    campaign.brandInitial,
                    style:
                        AppTypography.labelMD.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand in ${campaign.brandCategory}',
                        style: AppTypography.labelMD,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      BCBadge(
                        label: _deadlineLabel(campaign.deadline),
                        variant: BCBadgeVariant.outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${Formatters.currency(campaign.minBudget)}–${Formatters.currency(campaign.maxBudget)}',
                    style: AppTypography.displaySM,
                  ),
                ),
                BCBadge(
                  label: _collabLabel(campaign.collabType),
                  variant: _collabVariant(campaign.collabType),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final deliverable in visibleDeliverables)
                  BCBadge(label: deliverable, variant: BCBadgeVariant.outline),
                if (extraCount > 0)
                  BCBadge(
                      label: '+$extraCount more',
                      variant: BCBadgeVariant.outline),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${campaign.bidCount} bids so far',
                    style: AppTypography.bodyXS,
                  ),
                ),
                _SmallNeoButton(label: 'Bid Now →', onTap: onTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignCardSkeleton extends StatelessWidget {
  const CampaignCardSkeleton({
    super.key,
    this.width = 280,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightDivider,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceAlt
          : AppColors.lightSurfaceAlt,
      child: SizedBox(
        width: width,
        child: BCCard(
          shadow: AppShadows.pink,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: AppColors.white, shape: BoxShape.circle)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 14, width: 140, color: AppColors.white),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                            height: 24, width: 90, color: AppColors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(height: 26, width: 170, color: AppColors.white),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  Container(height: 28, width: 72, color: AppColors.white),
                  Container(height: 28, width: 92, color: AppColors.white),
                  Container(height: 28, width: 68, color: AppColors.white),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(height: 12, width: 70, color: AppColors.white),
                  const Spacer(),
                  Container(height: 34, width: 92, color: AppColors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallNeoButton extends StatelessWidget {
  const _SmallNeoButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.neon,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(label, style: AppTypography.labelSM),
      ),
    );
  }
}

String _collabLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

BCBadgeVariant _collabVariant(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return BCBadgeVariant.pink;
    case CampaignCollabType.barter:
      return BCBadgeVariant.blue;
    case CampaignCollabType.hybrid:
      return BCBadgeVariant.purple;
  }
}

String _deadlineLabel(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  if (duration.isNegative) {
    return 'Ended ${DateFormat('d MMM').format(deadline)}';
  }
  if (duration.inDays >= 1) return '${duration.inDays}d left';
  if (duration.inHours >= 1) return '${duration.inHours}h left';
  return '${duration.inMinutes.clamp(1, 59)}m left';
}

Color _avatarColor(String initial) {
  const palette = [
    AppColors.pink,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange
  ];
  return palette[initial.codeUnitAt(0) % palette.length];
}
