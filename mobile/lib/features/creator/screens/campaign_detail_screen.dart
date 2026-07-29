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
            (bid) => bid.campaignId == campaign.id && bid.status != 'withdrawn' && bid.status != 'completed' && bid.status != 'rejected')
        .cast<Bid?>()
        .firstOrNull;
    final hasBid = activeBid != null;
    final daysLeft = campaign.deadline.difference(DateTime.now()).inDays;
    final slotCount = campaign.slotsTotal <= 0 ? 1 : campaign.slotsTotal;
    final filledSlots = campaign.slotsFilled.clamp(0, slotCount);

    return Scaffold(
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
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Brand row ──
                          _BrandHeader(campaign: campaign),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Campaign Title ──
                          Text(
                            campaign.title,
                            style: AppTypography.displayLG.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // ── Badges row: collab type + deadline ──
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              BCBadge(
                                label: _collabLabel(campaign.collabType),
                                variant: _collabVariant(campaign.collabType),
                              ),
                              BCBadge(
                                label: _deadlineLabel(campaign.deadline),
                                variant: daysLeft <= 3
                                    ? BCBadgeVariant.error
                                    : BCBadgeVariant.neon,
                              ),
                              BCBadge(
                                label: '${campaign.bidCount} bids',
                                variant: BCBadgeVariant.purple,
                              ),
                            ],
                          ),

                          // ── Description ──
                          if (campaign.description.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionHeader(label: 'About this campaign'),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              campaign.description,
                              style: AppTypography.bodySM.copyWith(
                                color: AppColors.muted,
                                height: 1.5,
                              ),
                            ),
                          ],

                          // ── Budget ──
                          const SizedBox(height: AppSpacing.xl),
                          GlassPanel(
                            accentColor: AppColors.success,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget',
                                  style: AppTypography.labelLG.copyWith(
                                    color: AppColors.creatorDark,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _budgetText(campaign),
                                  style: AppTypography.displaySM.copyWith(
                                    color: AppColors.creatorDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Deliverables ──
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionHeader(label: 'Deliverables'),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: (campaign.deliverables.isEmpty
                                    ? const <String>['Not specified']
                                    : campaign.deliverables)
                                .map(
                                  (item) => BCBadge(
                                    label: item,
                                    variant: BCBadgeVariant.neon,
                                  ),
                                )
                                .toList(),
                          ),

                          // ── Niche / Looking for ──
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionHeader(label: 'Looking for'),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final niche in campaign.niche)
                                BCBadge(
                                  label: niche,
                                  variant: BCBadgeVariant.purple,
                                ),
                              ..._requirementChips(campaign).map(
                                (chip) => BCBadge(
                                  label: chip,
                                  variant: BCBadgeVariant.blue,
                                ),
                              ),
                            ],
                          ),

                          // ── Target Location ──
                          const SizedBox(height: AppSpacing.xl),
                          GlassPanel(
                            accentColor: AppColors.pink,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.pink,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target Location',
                                        style: AppTypography.labelLG.copyWith(
                                          color: AppColors.creatorDark,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        _locationFull(campaign),
                                        style: AppTypography.bodySM.copyWith(
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Slots ──
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionHeader(label: 'Slots'),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                border: Border.all(
                                  color: AppColors.creatorDark
                                      .withValues(alpha: 0.14),
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
                            style: AppTypography.bodyXS.copyWith(
                              color: AppColors.muted,
                            ),
                          ),

                          // ── Requirements (if any) ──
                          if (campaign.requirements.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionHeader(label: 'Requirements'),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              campaign.requirements,
                              style: AppTypography.bodySM.copyWith(
                                color: AppColors.muted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Back + Share ──
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
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          0,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.creatorDark, width: 2.2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: hasBid
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        'You\'ve already bid on this',
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
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: AppColors.lightDivider,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Withdraw',
                          style: AppTypography.labelSM.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => _openBidSheet(campaign),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.creatorDark,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.creatorDark.withValues(alpha: 0.2),
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Place Your Bid',
                      style: AppTypography.labelMD.copyWith(
                        color: AppColors.neon,
                        fontWeight: FontWeight.w900,
                      ),
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}

// ── Brand Header ──────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
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
            style:
                AppTypography.labelLG.copyWith(color: AppColors.white),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.brandCategory,
                style: AppTypography.labelLG.copyWith(
                  color: AppColors.creatorDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                campaign.createdAt == null
                    ? 'Recently posted'
                    : 'Posted ${Formatters.timeAgo(campaign.createdAt!)}',
                style: AppTypography.bodyXS.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelLG.copyWith(
        color: AppColors.creatorDark,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────

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

String _budgetText(Campaign campaign) {
  if (campaign.minBudget == 0 && campaign.maxBudget == 0) {
    return 'Product only (no cash)';
  }
  return '${Formatters.currencyFromINR(campaign.minBudget)} – ${Formatters.currencyFromINR(campaign.maxBudget)}';
}

String _locationFull(Campaign campaign) {
  if (campaign.targetCity != null && campaign.targetState != null) {
    return '${campaign.targetCity}, ${campaign.targetState}';
  }
  if (campaign.targetState != null) return campaign.targetState!;
  return 'Pan India — no location preference';
}

List<String> _requirementChips(Campaign campaign) {
  final chips = <String>[];

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
