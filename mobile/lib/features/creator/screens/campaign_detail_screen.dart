import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_error_state.dart';
import '../shared/widgets/creator_design_system.dart';
import '../widgets/bid_bottom_sheet.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  Future<void> _openBidSheet(Campaign campaign) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BidBottomSheet(campaign: campaign),
    );

    if (!mounted || submitted != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignDetailProvider(widget.id));
    final bids = ref.watch(myBidsProvider).valueOrNull ?? const <Bid>[];
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 40.0;
    const headerGap = 24.0;
    final contentTop = topInset + headerHeight + headerGap;

    if (campaignAsync.isLoading) {
      return const Scaffold(
        body: Center(child: BCAppLoader()),
      );
    }

    if (campaignAsync.hasError) {
      return Scaffold(
        body: BCErrorState(
          message: campaignAsync.error.toString(),
          onRetry: () => ref.invalidate(campaignDetailProvider(widget.id)),
        ),
      );
    }

    final campaign = campaignAsync.value;
    if (campaign == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Campaign not found',
            style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    final activeBid = bids
        .where(
            (bid) => bid.campaignId == campaign.id && bid.status != 'withdrawn')
        .cast<Bid?>()
        .firstOrNull;
    final hasBid = activeBid != null;
    final daysLeft = campaign.deadline.difference(DateTime.now()).inDays;
    final slotCount = campaign.slotsTotal <= 0 ? 1 : campaign.slotsTotal;
    final filledSlots = campaign.slotsFilled.clamp(0, slotCount);
    final requirementChips = _requirementChips(campaign);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightBg,
                    Color(0xFFD8E6C6),
                    Color(0xFFC4D4AE),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: -54,
            child: AmbientGlow(
              size: 164,
              color: AppColors.neon.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 164,
            left: -42,
            child: AmbientGlow(
              size: 126,
              color: AppColors.pink.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: topInset,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.creatorDark.withValues(alpha: 0.14),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.creatorDark,
                      size: 22,
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share link copied.')),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.creatorDark.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Icon(
                      Symbols.share_rounded,
                      color: AppColors.creatorDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: RefreshIndicator(
              color: AppColors.neon,
              onRefresh: () async {
                ref.invalidate(campaignDetailProvider(widget.id));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: contentTop),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.lightBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.creatorDark,
                          width: 2.2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.lg,
                        AppSpacing.screenPadding,
                        AppSpacing.xl + 84,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassPanel(
                            accentColor: AppColors.creatorDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: _avatarColor(campaign.brandInitial),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.creatorDark,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        campaign.brandInitial,
                                        style: AppTypography.labelLG
                                            .copyWith(color: AppColors.white),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Brand in ${campaign.brandCategory}',
                                            style: AppTypography.labelLG.copyWith(
                                              color: AppColors.creatorDark,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Row(
                                            children: [
                                              BCBadge(
                                                label: _collabLabel(campaign.collabType),
                                                variant: _collabVariant(campaign.collabType),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              BCBadge(
                                                label: _deadlineLabel(campaign.deadline),
                                                variant: BCBadgeVariant.neon,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  campaign.createdAt == null
                                      ? 'Recently posted'
                                      : 'Posted ${Formatters.timeAgo(campaign.createdAt!)}',
                                  style: AppTypography.bodyXS,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            '${Formatters.currencyFromINR(campaign.minBudget)}–${Formatters.currencyFromINR(campaign.maxBudget)}',
                            style: AppTypography.displayLG.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BCBadge(
                            label: _collabLabel(campaign.collabType),
                            variant: _collabVariant(campaign.collabType),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GlassPanel(
                            accentColor: AppColors.creatorDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Target Location',
                                  style: AppTypography.labelLG,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  campaign.targetCity != null
                                      ? '📍 ${campaign.targetCity}, ${campaign.targetState ?? ''}'
                                      : campaign.targetState != null
                                          ? '📍 ${campaign.targetState}'
                                          : '📍 Pan India',
                                  style: AppTypography.bodySM,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'This brand prefers creators from this location.',
                                  style: AppTypography.bodyXS.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (campaign.description.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              campaign.description,
                              style: AppTypography.bodySM,
                            ),
                          ],
                          if (campaign.collabType != CampaignCollabType.paid) ...[
                            const SizedBox(height: AppSpacing.md),
                            GlassPanel(
                              accentColor: AppColors.creatorDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Product details',
                                    style: AppTypography.labelLG,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Brand will send a curated product package for authentic usage-based content.',
                                    style: AppTypography.bodySM.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Estimated value: ${Formatters.currencyFromINR((campaign.minBudget + campaign.maxBudget) ~/ 2)}',
                                    style: AppTypography.labelSM,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Deliverables 📋',
                            style: AppTypography.displaySM.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: (campaign.deliverables.isEmpty
                                    ? const <String>['No deliverables specified']
                                    : campaign.deliverables)
                                .map(
                                  (item) => BCBadge(
                                    label: item,
                                    variant: BCBadgeVariant.neon,
                                  ),
                                )
                                .toList(),
                          ),
                          if (campaign.requirements.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              campaign.requirements,
                              style: AppTypography.bodySM.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Looking for',
                            style: AppTypography.displaySM.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: (requirementChips.isEmpty
                                    ? campaign.niche
                                    : requirementChips)
                                .map(
                                  (chip) => BCBadge(
                                    label: chip,
                                    variant: BCBadgeVariant.neon,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              BCBadge(
                                label: '${campaign.bidCount} creators have bid',
                                variant: BCBadgeVariant.neon,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              BCBadge(
                                label: '${daysLeft.clamp(0, 365)} days left',
                                variant: BCBadgeVariant.neon,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                border: Border.all(
                                  color: AppColors.creatorDark.withValues(alpha: 0.14),
                                  width: 1.5,
                                ),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: filledSlots / slotCount,
                                child: const ColoredBox(color: AppColors.neon),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$filledSlots of $slotCount slots filled',
                            style: AppTypography.bodyXS,
                          ),
                          const SizedBox(height: AppSpacing.xl + 84),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.creatorDark, width: 2.2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: hasBid
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        '✅ You\'ve already bid on this',
                        style: AppTypography.labelMD.copyWith(
                          color: AppColors.creatorDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await ref
                              .read(creatorActionsProvider.notifier)
                              .withdrawBid(activeBid.id);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not withdraw bid.')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creatorDark,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          'Withdraw Bid',
                          style: AppTypography.labelSM.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    label: 'Place Your Bid →',
                    accent: AppColors.creatorDark,
                    textColor: AppColors.neon,
                    onTap: () => _openBidSheet(campaign),
                  ),
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
  if (duration.isNegative) return 'Ended';
  if (duration.inDays > 0) return '${duration.inDays}d left';
  if (duration.inHours > 0) return '${duration.inHours}h left';
  return '${duration.inMinutes.clamp(1, 59)}m left';
}

List<String> _requirementChips(Campaign campaign) {
  final chips = <String>[];

  for (final niche in campaign.niche) {
    final text = niche.trim();
    if (text.isNotEmpty) chips.add(text);
  }

  final rawRequirements = campaign.requirements
      .split('|')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  for (final item in rawRequirements) {
    if (item.toLowerCase().startsWith('target tiers:')) {
      final value = item.substring('target tiers:'.length).trim();
      if (value.isNotEmpty) chips.add(value);
      continue;
    }

    if (item.toLowerCase().startsWith('target niches:')) {
      final value = item.substring('target niches:'.length).trim();
      if (value.isNotEmpty) chips.add(value);
      continue;
    }

    final match = RegExp(r'min\s+followers\s*:\s*(\d+)', caseSensitive: false)
        .firstMatch(item);
    if (match != null) {
      chips.add('Min ${match.group(1)} followers');
    }
  }

  final seen = <String>{};
  return chips.where((item) => seen.add(item.toLowerCase())).toList();
}

Color _avatarColor(String initial) {
  const palette = [
    AppColors.pink,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange,
  ];
  return palette[initial.codeUnitAt(0) % palette.length];
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.52,
              spreadRadius: size * 0.18,
            ),
          ],
        ),
      ),
    );
  }
}