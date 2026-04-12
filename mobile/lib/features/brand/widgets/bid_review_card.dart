import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class BidReviewCard extends StatelessWidget {
  const BidReviewCard({
    super.key,
    required this.bid,
    required this.shadow,
    required this.onAccept,
    required this.onPass,
    this.displayName,
    this.avatarUrl,
    this.onReadMore,
    this.onAvatarTap,
    this.footer,
  });

  final CampaignBid bid;
  final List<BoxShadow> shadow;
  final VoidCallback? onAccept;
  final VoidCallback? onPass;
  final String? displayName;
  final String? avatarUrl;
  final VoidCallback? onReadMore;
  final VoidCallback? onAvatarTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = (avatarUrl ?? '').trim().isNotEmpty
        ? avatarUrl!.trim()
        : (bid.creatorAvatarUrl ?? '').trim();
    final fallbackTitle = bid.isUnlocked
        ? '${bid.creatorFullName} ${bid.creatorHandle}'.trim()
        : bid.creatorFirstName;
    final titleText = (displayName ?? '').trim().isNotEmpty
        ? displayName!.trim()
        : fallbackTitle;
    final niches = bid.niches.where((item) => item.trim().isNotEmpty).toList();

    return BCCard(
      shadow: shadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: resolvedAvatarUrl.isNotEmpty
                      ? Image.network(
                          resolvedAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            bid.creatorInitials,
                            style: AppTypography.labelSM
                                .copyWith(color: AppColors.neon),
                          ),
                        )
                      : Text(
                          bid.creatorInitials,
                          style: AppTypography.labelSM
                              .copyWith(color: AppColors.neon),
                        ),
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
                            titleText,
                            style: AppTypography.labelLG,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (bid.isUnlocked)
                          const BCBadge(
                            label: 'Unlocked',
                            variant: BCBadgeVariant.neon,
                            prefixEmoji: '🔓',
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    BCBadge(
                      label: bid.tier,
                      variant: _tierVariant(bid.tier),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _pill(_compactFollowers(bid.followersCount), AppColors.neon,
                  AppColors.ink),
              if (niches.isNotEmpty)
                _pill(niches[0], AppColors.pink, AppColors.white),
              if (niches.length > 1)
                _pill(niches[1], AppColors.blue, AppColors.white),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(_inr(bid.amount), style: AppTypography.displaySM),
              const SizedBox(width: AppSpacing.sm),
              BCBadge(
                label: _collabLabel(bid.collabType),
                variant: _collabVariant(bid.collabType),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            bid.deliverables,
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          if ((bid.pitch ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '"${bid.pitch!.trim()}"',
              style: AppTypography.bodySM.copyWith(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onReadMore != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onReadMore,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.pink,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Read more'),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (footer != null)
            footer!
          else
            Row(
              children: [
                Expanded(
                  child: BCPrimaryButton.pink(
                    label: 'Pass',
                    onPressed: bid.isAccepted ? null : onPass,
                    isFullWidth: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: BCPrimaryButton.neon(
                    label: 'Accept',
                    onPressed: bid.isAccepted ? null : onAccept,
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _pill(String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        value,
        style: AppTypography.labelXS.copyWith(color: textColor),
      ),
    );
  }
}

String _compactFollowers(int followers) {
  if (followers >= 1000000) {
    final value = followers / 1000000;
    final str =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '${str}m';
  }
  if (followers >= 1000) {
    final value = followers / 1000;
    final str =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '${str}k';
  }
  return followers.toString();
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

BCBadgeVariant _tierVariant(String tier) {
  switch (tier.toLowerCase()) {
    case 'nano':
      return BCBadgeVariant.neon;
    case 'micro':
      return BCBadgeVariant.blue;
    case 'mid':
      return BCBadgeVariant.purple;
    case 'macro':
      return BCBadgeVariant.pink;
    default:
      return BCBadgeVariant.outline;
  }
}

String _inr(int value) =>
    '₹${NumberFormat.decimalPattern('en_IN').format(value)}';
