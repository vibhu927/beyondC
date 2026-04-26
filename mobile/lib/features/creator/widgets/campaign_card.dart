import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../widgets/cards/bc_card.dart';
import '../shared/widgets/creator_design_system.dart';

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
      child: GestureDetector(
        onTap: onTap,
        child: GlassPanel(
          accentColor: _collabAccent(campaign.collabType),
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
                      border: Border.all(color: AppColors.ink, width: 1.4),
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
                          style: AppTypography.labelMD.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InlineTonePill(
                          label: _deadlineLabel(campaign.deadline),
                          accent: AppColors.ink,
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
                      '${Formatters.currencyFromINR(campaign.minBudget)}–${Formatters.currencyFromINR(campaign.maxBudget)}',
                      style: AppTypography.displaySM.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InlineTonePill(
                    label: _collabLabel(campaign.collabType),
                    accent: _collabAccent(campaign.collabType),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final deliverable in visibleDeliverables)
                    InlineTonePill(
                      label: deliverable,
                      accent: AppColors.blue,
                    ),
                  if (extraCount > 0)
                    InlineTonePill(
                      label: '+$extraCount more',
                      accent: AppColors.purple,
                    ),
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
                  InlineTonePill(
                    label: campaign.targetCity != null
                        ? '📍 ${campaign.targetCity}'
                        : campaign.targetState != null
                            ? '📍 ${campaign.targetState}'
                            : '🌏 Pan India',
                    accent: AppColors.orange,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GlassButton(
                    label: 'Bid Now',
                    accent: AppColors.neon,
                    onTap: onTap,
                  ),
                ],
              ),
            ],
          ),
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

Color _collabAccent(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return AppColors.pink;
    case CampaignCollabType.barter:
      return AppColors.blue;
    case CampaignCollabType.hybrid:
      return AppColors.purple;
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
