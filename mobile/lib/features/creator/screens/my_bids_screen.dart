import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';

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

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 2,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 2,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: _refresh,
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

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.huge,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text('My Bids', style: AppTypography.displayMD),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Track every pitch, follow matches, and withdraw pending bids anytime.',
                        style: AppTypography.bodySM.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: 86,
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatPill(
                                label: 'All',
                                value: bids.length.toString(),
                                variant: BCBadgeVariant.dark,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatPill(
                                label: 'Active',
                                value: activeCount.toString(),
                                variant: BCBadgeVariant.neon,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatPill(
                                label: 'Matched',
                                value: matchedCount.toString(),
                                variant: BCBadgeVariant.success,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatPill(
                                label: 'Closed',
                                value: closedCount.toString(),
                                variant: BCBadgeVariant.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('All', _BidFilter.all),
                            const SizedBox(width: AppSpacing.sm),
                            _filterChip('Active', _BidFilter.active),
                            const SizedBox(width: AppSpacing.sm),
                            _filterChip('Matched', _BidFilter.matched),
                            const SizedBox(width: AppSpacing.sm),
                            _filterChip('Closed', _BidFilter.closed),
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
                                      RouteNames.campaignDetail.replaceFirst(
                                        ':id',
                                        bid.campaignId,
                                      ),
                                    );
                                  },
                                  onWithdraw: _canWithdraw(bid)
                                      ? () async {
                                          try {
                                            await ref
                                                .read(creatorActionsProvider
                                                    .notifier)
                                                .withdrawBid(bid.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Bid withdrawn.'),
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
                    ]),
                  ),
                ),
              ],
            );
          },
          ),
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

  Widget _filterChip(String label, _BidFilter filter) {
    final isActive = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: AppShadows.softTight(context),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: isActive ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.variant,
  });

  final String label;
  final String value;
  final BCBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.blue,
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
              child: BCBadge(label: label, variant: variant),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: AppTypography.displaySM),
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

    return BCCard(
      shadow: AppShadows.neon,
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
                      style: AppTypography.labelLG,
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
                BCBadge(
                  label:
                      '${Formatters.currencyFromINR(campaign.minBudget)} - ${Formatters.currencyFromINR(campaign.maxBudget)}',
                  variant: BCBadgeVariant.outline,
                ),
              if (campaign != null) const SizedBox(width: AppSpacing.sm),
              if (createdAt != null)
                BCBadge(
                  label: Formatters.timeAgo(createdAt),
                  variant: BCBadgeVariant.blue,
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
              _ActionButton(
                label: 'View Campaign',
                filled: false,
                onTap: onViewCampaign,
              ),
              if (onWithdraw != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _ActionButton(
                  label: isActionRunning ? 'Please wait...' : 'Withdraw',
                  filled: true,
                  onTap: isActionRunning ? null : onWithdraw,
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
    final variant = switch (normalized) {
      'pending' => BCBadgeVariant.warning,
      'accepted' => BCBadgeVariant.success,
      'in_progress' => BCBadgeVariant.blue,
      'completed' => BCBadgeVariant.purple,
      'rejected' => BCBadgeVariant.error,
      'withdrawn' => BCBadgeVariant.dark,
      _ => BCBadgeVariant.outline,
    };

    final label = normalized.replaceAll('_', ' ');
    final pretty = label.isEmpty
        ? 'Unknown'
        : '${label[0].toUpperCase()}${label.substring(1)}';

    return BCBadge(label: pretty, variant: variant);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: filled ? AppColors.neon : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: AppShadows.softTight(context),
          ),
          child: Text(label, style: AppTypography.labelSM),
        ),
      ),
    );
  }
}

class _MyBidsLoadingView extends StatelessWidget {
  const _MyBidsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.neon),
    );
  }
}
