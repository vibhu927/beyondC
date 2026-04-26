import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../shared/widgets/home_content_sheet.dart';
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
    final navClearance = MediaQuery.of(context).padding.bottom + 84;

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
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE1E8F4),
                      Color(0xFFE9EFF8),
                      Color(0xFFF5F7FB),
                    ],
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
            Positioned.fill(
              child: HomeContentSheet(
                backgroundColor: const Color(0xFFE7EDF7),
                borderColor: Colors.transparent,
                borderRadius: BorderRadius.zero,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                ),
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
                        padding: EdgeInsets.only(bottom: navClearance),
                        children: [
                          const Text('My Bids', style: AppTypography.displaySM),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Track every submitted bid and manage status quickly.',
                            style: AppTypography.bodySM.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 86,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatPill(
                                    label: 'All',
                                    value: bids.length.toString(),
                                    accent: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _StatPill(
                                    label: 'Active',
                                    value: activeCount.toString(),
                                    accent: AppColors.neon,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _StatPill(
                                    label: 'Matched',
                                    value: matchedCount.toString(),
                                    accent: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _StatPill(
                                    label: 'Closed',
                                    value: closedCount.toString(),
                                    accent: AppColors.purple,
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
                    );
                  },
                ),
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
          color: isActive
              ? AppColors.ink.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: uniformBorder(
            isActive ? AppColors.ink : AppColors.blue,
            width: 1.1,
          ),
          boxShadow: neoShadows(
            isActive ? AppColors.ink : AppColors.blue,
            alpha: 0.12,
            offset: 2.5,
            blurRadius: 10,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: isActive ? AppColors.neon : AppColors.ink,
            fontWeight: FontWeight.w800,
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
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: accent,
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
                accent: accent,
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

    return GlassPanel(
      accentColor: _statusAccent(bid.status),
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
                  accent: AppColors.blue,
                ),
              if (campaign != null) const SizedBox(width: AppSpacing.sm),
              if (createdAt != null)
                InlineTonePill(
                  label: Formatters.timeAgo(createdAt),
                  accent: AppColors.pink,
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
              GlassButton(
                label: 'View Campaign',
                accent: AppColors.ink,
                onTap: onViewCampaign,
              ),
              if (onWithdraw != null) ...[
                const SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: isActionRunning ? 'Please wait...' : 'Withdraw',
                  accent: AppColors.neon,
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
    final label = normalized.replaceAll('_', ' ');
    final pretty = label.isEmpty
        ? 'Unknown'
        : '${label[0].toUpperCase()}${label.substring(1)}';

    return InlineTonePill(
      label: pretty,
      accent: _statusAccent(status),
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
  switch (status.toLowerCase()) {
    case 'pending':
      return AppColors.orange;
    case 'accepted':
      return AppColors.success;
    case 'in_progress':
      return AppColors.blue;
    case 'completed':
      return AppColors.purple;
    case 'rejected':
      return AppColors.error;
    case 'withdrawn':
      return AppColors.ink;
    default:
      return AppColors.blue;
  }
}
