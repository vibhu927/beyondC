import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/creator_page_top_header.dart';
import '../shared/widgets/creator_design_system.dart';

enum _BidFilter { all, active, matched, closed }

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen> {
  _BidFilter _activeFilter = _BidFilter.all;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(creatorCampaignsProvider);
      ref.read(creatorProfileProvider);
    });
  }

  Future<void> _refresh() async {
    await ref.read(myBidsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final bidsAsync = ref.watch(myBidsProvider);
    final actionState = ref.watch(creatorActionsProvider);
    final isActionRunning = actionState.isLoading;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 2,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 2,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.lightBg,
                      Color(0xFFE1EBCF),
                            Color(0xFFD2DEBF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 28,
              right: -54,
              child: AmbientGlow(
                size: 164,
                color: AppColors.neon.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              top: 164,
              left: -42,
              child: AmbientGlow(
                size: 126,
                color: AppColors.pink.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: topInset,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              child: const CreatorPageTopHeader(),
            ),
            Positioned.fill(
              child: bidsAsync.when(
                loading: () => const _MyBidsLoadingView(),
                error: (error, _) => BCErrorState(
                  message: error.toString(),
                  onRetry: _refresh,
                ),
                data: (bids) {
                  final filtered = _applyFilter(bids, _activeFilter);
                  final activeCount = bids.where(_isActiveBid).length;
                  final matchedCount = bids.where(_isMatchedBid).length;
                  final closedCount = bids.where(_isClosedBid).length;

                  return RefreshIndicator(
                    color: AppColors.neon,
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        0,
                        sheetTop,
                        0,
                        0,
                      ),
                      children: [
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
                                 Text('My Bids',  
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.creatorDark,
                                  fontWeight: FontWeight.w900,
                                 ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Track every submitted bid and manage status quickly.',
                                  style: AppTypography.bodySM.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                SizedBox(
                                  height: 104,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _QuickActionTile(
                                          icon: Symbols.dashboard_rounded,
                                          label: 'All',
                                          isSelected: _activeFilter == _BidFilter.all,
                                          onTap: () => setState(() => _activeFilter = _BidFilter.all),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: _QuickActionTile(
                                          icon: Symbols.pending_rounded,
                                          label: 'Active',
                                          isSelected: _activeFilter == _BidFilter.active,
                                          onTap: () => setState(() => _activeFilter = _BidFilter.active),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: _QuickActionTile(
                                          icon: Symbols.check_circle_rounded,
                                          label: 'Matched',
                                          isSelected: _activeFilter == _BidFilter.matched,
                                          onTap: () => setState(() => _activeFilter = _BidFilter.matched),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: _QuickActionTile(
                                          icon: Symbols.cancel_rounded,
                                          label: 'Closed',
                                          isSelected: _activeFilter == _BidFilter.closed,
                                          onTap: () => setState(() => _activeFilter = _BidFilter.closed),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (filtered.isEmpty)
                                  const BCEmptyState(
                                    emoji: '🧾',
                                    message: 'No bids found for this filter.',
                                  )
                                else
                                  Column(
                                    children: [
                                      for (final bid in filtered)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: _BidCard(
                                            bid: bid,
                                            isActionRunning: isActionRunning,
                                            onViewCampaign: () {
                                              context.push(
                                                RouteNames.campaignDetail
                                                    .replaceFirst(':id', bid.campaignId),
                                              );
                                            },
                                            onWithdraw: _canWithdraw(bid)
                                                ? () async {
                                                    try {
                                                      await ref
                                                          .read(
                                                            creatorActionsProvider
                                                                .notifier,
                                                          )
                                                          .withdrawBid(bid.id);
                                                      if (!context.mounted) return;
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content:
                                                              Text('Bid withdrawn.'),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      if (!context.mounted) return;
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(e.toString()),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Bid> _applyFilter(List<Bid> bids, _BidFilter filter) {
    switch (filter) {
      case _BidFilter.all:
        return bids;
      case _BidFilter.active:
        return bids.where(_isActiveBid).toList();
      case _BidFilter.matched:
        return bids.where(_isMatchedBid).toList();
      case _BidFilter.closed:
        return bids.where(_isClosedBid).toList();
    }
  }

  bool _isActiveBid(Bid bid) {
    final status = bid.status.toLowerCase();
    return status == 'pending';
  }

  bool _isMatchedBid(Bid bid) {
    final status = bid.status.toLowerCase();
    return status == 'accepted' ||
        status == 'in_progress' ||
        status == 'completed';
  }

  bool _isClosedBid(Bid bid) {
    final status = bid.status.toLowerCase();
    return status == 'withdrawn' || status == 'rejected';
  }

  bool _canWithdraw(Bid bid) {
    return bid.status.toLowerCase() == 'pending';
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.creatorDark
              : AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.creatorDark
                : AppColors.creatorDark.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.neon : AppColors.creatorDark,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelXS.copyWith(
                color: isSelected ? AppColors.neon : AppColors.creatorDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: AppColors.creatorDark,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: InlineTonePill(
                label: label,
                accent: AppColors.creatorDark,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTypography.displaySM.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  const _BidCard({
    required this.bid,
    required this.isActionRunning,
    required this.onViewCampaign,
    this.onWithdraw,
  });

  final Bid bid;
  final bool isActionRunning;
  final VoidCallback onViewCampaign;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final campaign = bid.campaign;
    final createdAt = bid.createdAt;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.creatorDark.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign?.title ?? 'Campaign',
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      campaign?.brandCategory ?? 'General',
                      style: AppTypography.bodySM.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: bid.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (campaign != null)
                InlineTonePill(
                  label:
                      '${Formatters.currencyFromINR(campaign.minBudget)} - ${Formatters.currencyFromINR(campaign.maxBudget)}',
                  accent: AppColors.creatorDark,
                ),
              if (campaign != null) const SizedBox(width: AppSpacing.sm),
              if (createdAt != null)
                InlineTonePill(
                  label: Formatters.timeAgo(createdAt),
                  accent: AppColors.creatorDark,
                ),
            ],
          ),
          if ((bid.message ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              bid.message!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySM,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  GestureDetector(
                    onTap: onViewCampaign,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creatorDark,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: AppColors.creatorDark.withValues(alpha: 0.55),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.creatorDark.withValues(alpha: 0.2),
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'View Campaign',
                        style: AppTypography.labelSM.copyWith(
                          color: AppColors.neon,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (onWithdraw != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: isActionRunning ? null : onWithdraw,
                      child: Opacity(
                        opacity: isActionRunning ? 0.5 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.creatorDark,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                            border: Border.all(
                              color:
                                  AppColors.creatorDark.withValues(alpha: 0.55),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.creatorDark.withValues(alpha: 0.2),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            isActionRunning ? 'Please wait...' : 'Withdraw',
                            style: AppTypography.labelSM.copyWith(
                              color: AppColors.neon,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final label = normalized.replaceAll('_', ' ');
    final pretty = label.isEmpty
        ? 'Unknown'
        : '${label[0].toUpperCase()}${label.substring(1)}';

    final isAccepted = normalized == 'accepted';

    if (isAccepted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.creatorDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: AppColors.creatorDark.withValues(alpha: 0.55),
            width: 1.0,
          ),
        ),
        child: Text(
          pretty,
          style: AppTypography.labelXS.copyWith(
            color: AppColors.neon,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return InlineTonePill(
      label: pretty,
      accent: AppColors.creatorDark,
    );
  }
}

class _MyBidsLoadingView extends StatelessWidget {
  const _MyBidsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: BCAppLoader());
  }
}

Color _statusAccent(String status) {
  return AppColors.creatorDark;
}
