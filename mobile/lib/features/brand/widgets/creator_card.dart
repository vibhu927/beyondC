import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: (creator.avatarUrl ?? '').trim().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            creator.avatarUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              creator.initials,
                              style: AppTypography.labelMD
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        )
                      : Text(
                          creator.initials,
                          style: AppTypography.labelMD
                              .copyWith(color: AppColors.white),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLG.copyWith(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _StatusPill(
                            label: creator.instagramVerified
                                ? 'Verified'
                                : 'Unverified',
                            tone: creator.instagramVerified
                                ? AppColors.brandPrimary
                                : AppColors.brandDark.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _StatusPill(
                            label: creator.tier,
                            tone: AppColors.brandDark.withValues(alpha: 0.08),
                          ),
                          ...creator.niches.take(2).map(
                                (niche) => _StatusPill(
                                  label: niche,
                                  tone:
                                      AppColors.brandDark.withValues(alpha: 0.08),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((creator.state ?? '').trim().isNotEmpty ||
                (creator.city ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Symbols.location_on_rounded,
                    size: 14,
                    color: AppColors.brandDark.withValues(alpha: 0.72),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      (creator.city ?? '').trim().isNotEmpty
                          ? '${creator.city}, ${creator.state ?? ''}'
                          : (creator.state ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                Text(
                  '${_followersExact(creator.followersCount)} followers',
                  style: AppTypography.bodySM.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${creator.engagementRate.toStringAsFixed(1)}% engagement',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                Text(
                  'from ${Formatters.currency(creator.startingPrice)}',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: onSendRequest ?? onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandDark,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        'Send Request',
                        style: AppTypography.labelSM.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 18, width: 120, color: AppColors.white),
                      const SizedBox(height: AppSpacing.sm),
                      Container(height: 24, width: 170, color: AppColors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(height: 14, width: 220, color: AppColors.white),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(height: 12, width: 74, color: AppColors.white),
                const Spacer(),
                Container(height: 34, width: 126, color: AppColors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _followersExact(int count) =>
    Formatters.followerCount(count).toLowerCase();

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _avatarColor(String initials) {
  const palette = [
    AppColors.blue,
    AppColors.pink,
    AppColors.purple,
    AppColors.orange,
  ];
  return palette[initials.codeUnitAt(0) % palette.length];
}
