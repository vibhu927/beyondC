import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class CreatorDetailBottomSheet extends ConsumerWidget {
  const CreatorDetailBottomSheet({
    super.key,
    required this.creator,
  });

  final CreatorPreview creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avgPrice = creator.avgCollabPrice ?? creator.startingPrice;
    final stars = _starsForCreator(creator);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXL),
            ),
            border: Border(
              top: BorderSide(color: AppColors.ink, width: 2),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.huge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.neon, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        creator.initials,
                        style: AppTypography.labelLG.copyWith(color: AppColors.neon),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(creator.firstName, style: AppTypography.displaySM),
                          const SizedBox(height: AppSpacing.xs),
                          BCBadge(
                            label: creator.tier,
                            variant: _tierVariant(creator.tier),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                BCCard(
                  shadow: AppShadows.neon,
                  child: Row(
                    children: [
                      Expanded(
                        child: _stat('Follower Range', creator.followerRange),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _stat(
                          'Engagement',
                          '${creator.engagementRate.toStringAsFixed(1)}%',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _stat('Avg Price', _inr(avgPrice)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: creator.niches
                      .map(
                        (niche) => BCBadge(
                          label: niche,
                          variant: BCBadgeVariant.outline,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: creator.contentTypes
                      .map(
                        (type) => BCBadge(
                          label: type,
                          variant: BCBadgeVariant.blue,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Past Collabs: ${creator.pastCollabs ?? 0}  •  $stars',
                  style: AppTypography.labelMD.copyWith(
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                if (creator.portfolioLinks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: creator.portfolioLinks
                        .map(
                          (link) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              border: Border.all(color: AppColors.ink, width: 2),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              link,
                              style: AppTypography.labelSM,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Full name and handle revealed after match 🔒',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xl),
                BCPrimaryButton.dark(
                  label: 'Send Request →',
                  onPressed: () async {
                    final confirmed = await _showCreditConfirmDialog(
                      context,
                      title: 'Send request to ${creator.firstName}?',
                      subtitle: '1 credit will be deducted only if the creator accepts.',
                    );
                    if (!confirmed || !context.mounted) return;

                    final ok = await ref.read(brandProvider.notifier).sendDirectRequest(
                          creatorId: creator.id,
                          creatorName: creator.firstName,
                        );

                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not send request.')),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request sent to ${creator.firstName}.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyXS),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.labelSM),
      ],
    );
  }
}

Future<bool> _showCreditConfirmDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: BCCard(
          shadow: AppShadows.ink,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.ink, width: 2),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BCPrimaryButton.neon(
                      label: 'Confirm',
                      isFullWidth: true,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed ?? false;
}

String _inr(int value) => '₹${NumberFormat.decimalPattern('en_IN').format(value)}';

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

String _starsForCreator(CreatorPreview creator) {
  final rating = (3.8 + (creator.engagementRate / 10)).clamp(1.0, 5.0);
  final count = rating.round().clamp(1, 5);
  return List.filled(count, '★').join();
}
