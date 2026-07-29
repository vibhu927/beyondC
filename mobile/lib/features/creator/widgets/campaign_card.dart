import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';

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
    final deadlineText = _deadlineLabel(campaign.deadline);
    final isUrgent = _isUrgent(campaign.deadline);

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.lightDivider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Title + Deadline ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isUrgent ? AppColors.error : AppColors.muted)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      deadlineText,
                      style: AppTypography.labelXS.copyWith(
                        color: isUrgent ? AppColors.error : AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ── Brand category ──
              Text(
                campaign.brandCategory,
                style: AppTypography.bodyXS.copyWith(
                  color: AppColors.muted,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Budget + Collab type ──
              Row(
                children: [
                  Text(
                    _budgetShort(campaign),
                    style: AppTypography.labelMD.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _collabAccent(campaign.collabType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _collabLabel(campaign.collabType),
                      style: AppTypography.labelXS.copyWith(
                        color: _collabAccent(campaign.collabType),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Deliverables ──
              if (campaign.deliverables.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  campaign.deliverables.take(2).join(' · ') +
                      (campaign.deliverables.length > 2
                          ? ' +${campaign.deliverables.length - 2}'
                          : ''),
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const Spacer(),

              // ── Footer: Location + Bids + Bid button ──
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      _locationText(campaign),
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${campaign.bidCount} bids',
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creatorDark,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.creatorDark.withValues(alpha: 0.2),
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'Bid',
                        style: AppTypography.labelSM.copyWith(
                          color: AppColors.neon,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.lightDivider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 160, color: AppColors.white),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 10, width: 80, color: AppColors.white),
              const SizedBox(height: AppSpacing.md),
              Container(height: 14, width: 120, color: AppColors.white),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 10, width: 100, color: AppColors.white),
              const Spacer(),
              Row(
                children: [
                  Container(height: 10, width: 60, color: AppColors.white),
                  const Spacer(),
                  Container(
                      height: 34, width: 60, color: AppColors.white),
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
  if (duration.isNegative) return 'Ended';
  if (duration.inDays >= 1) return '${duration.inDays}d left';
  if (duration.inHours >= 1) return '${duration.inHours}h left';
  return '${duration.inMinutes.clamp(1, 59)}m left';
}

bool _isUrgent(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  return !duration.isNegative && duration.inHours < 24;
}

String _budgetShort(Campaign campaign) {
  if (campaign.minBudget == 0 && campaign.maxBudget == 0) return 'Product only';
  return '${Formatters.currencyFromINR(campaign.minBudget)} – ${Formatters.currencyFromINR(campaign.maxBudget)}';
}

String _locationText(Campaign campaign) {
  if (campaign.targetCity != null) return campaign.targetCity!;
  if (campaign.targetState != null) return campaign.targetState!;
  return 'Pan India';
}
