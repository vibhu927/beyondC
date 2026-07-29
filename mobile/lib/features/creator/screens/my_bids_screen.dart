import 'dart:ui';

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

enum _BidFilter { all, active, matched, completed }

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen> {
  _BidFilter _activeFilter = _BidFilter.all;
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    Future<void>.microtask(() {
      ref.read(creatorCampaignsProvider);
      ref.read(creatorProfileProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(myBidsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final bidsAsync = ref.watch(myBidsProvider);
    final completedCollabsAsync = ref.watch(creatorCompletedCollabsProvider);
    final actionState = ref.watch(creatorActionsProvider);
    final isActionRunning = actionState.isLoading;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap;
    final headerSlide = _scrollOffset.clamp(0.0, sheetTop);
    final collapseProgress = (headerSlide / (headerHeight + headerGap)).clamp(0.0, 1.0);
    final collapsedTop = MediaQuery.of(context).padding.top + 8;
    final headerTop = lerpDouble(topInset, collapsedTop, collapseProgress)!;

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
            Positioned.fill(
              child: bidsAsync.when(
                loading: () => const _MyBidsLoadingView(),
                error: (error, _) => BCErrorState(
                  message: error.toString(),
                  onRetry: _refresh,
                ),
                data: (bids) {
                  final filtered = _applyFilter(bids, _activeFilter);


                  return RefreshIndicator(
                    color: AppColors.neon,
                    onRefresh: _refresh,
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: sheetTop),
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - sheetTop,
                          ),
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
                              mainAxisSize: MainAxisSize.min,
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
                                          icon: Symbols.check_circle_rounded,
                                          label: 'Completed',
                                          isSelected: _activeFilter == _BidFilter.completed,
                                          onTap: () => setState(() => _activeFilter = _BidFilter.completed),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Builder(
                                  builder: (context) {
                                    final completedCollabs = completedCollabsAsync.valueOrNull ?? [];
                                    final isEmpty = filtered.isEmpty && completedCollabs.isEmpty;
                                    
                                    if (isEmpty) {
                                      return const BCEmptyState(
                                        emoji: '🧾',
                                        message: 'No bids found for this filter.',
                                      );
                                    }
                                    
                                    return Column(
                                      children: [
                                        if (_activeFilter == _BidFilter.all || _activeFilter == _BidFilter.completed)
                                          ...completedCollabs.map((collab) => Padding(
                                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                            child: _BidCard(
                                              bid: Bid(
                                                id: collab.id,
                                                campaignId: collab.id,
                                                status: collab.status,
                                                createdAt: collab.createdAt,
                                                message: collab.collabType.name,
                                                campaign: Campaign(
                                                  id: collab.id,
                                                  title: '${collab.brandCategory} Campaign',
                                                  brandCategory: collab.brandCategory,
                                                  minBudget: collab.agreedAmountPaise,
                                                  maxBudget: collab.agreedAmountPaise,
                                                  deadline: collab.completedAt ?? DateTime.now(),
                                                ),
                                              ),
                                              isActionRunning: isActionRunning,
                                              onViewCampaign: () {
                                                context.push('/creator/collabs/${collab.id}');
                                              },
                                            ),
                                          )),
                                        ...filtered.map((bid) => Padding(
                                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                                        )),
                                      ],
                                    );
                                  },
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: collapsedTop + 48 + 16,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightBg.withValues(alpha: collapseProgress * 0.95),
                    border: collapseProgress > 0.5
                        ? const Border(
                            bottom: BorderSide(color: AppColors.lightBorder),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Positioned(
              top: headerTop,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              child: CreatorPageTopHeader(collapseProgress: collapseProgress),
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
      case _BidFilter.completed:
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
          // Header: Title + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign?.title ?? 'Campaign',
                  style: AppTypography.labelLG.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: bid.status),
            ],
          ),

          const SizedBox(height: 4),

          // Category
          Text(
            campaign?.brandCategory ?? 'General',
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Budget (primary) + Time (secondary)
          Row(
            children: [
              if (campaign != null)
                Text(
                  '${Formatters.currencyFromINR(campaign.minBudget)} – ${Formatters.currencyFromINR(campaign.maxBudget)}',
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              if (campaign != null && createdAt != null) ...[
                const SizedBox(width: AppSpacing.sm),
                const SizedBox(
                  width: 3,
                  height: 3,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (createdAt != null)
                Text(
                  Formatters.timeAgo(createdAt),
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),

          // Bid message (if any)
          if ((bid.message ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              bid.message!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySM.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Buttons
          Row(
            children: [
              GestureDetector(
                onTap: onViewCampaign,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
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
                        horizontal: 28,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: AppColors.lightDivider,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isActionRunning ? 'Please wait...' : 'Withdraw',
                        style: AppTypography.labelSM.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
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

    final color = _statusColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        pretty,
        style: AppTypography.labelXS.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'in_progress':
        return AppColors.success;
      case 'completed':
        return AppColors.blue;
      case 'rejected':
      case 'withdrawn':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}

class _MyBidsLoadingView extends StatelessWidget {
  const _MyBidsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: BCAppLoader());
  }
}


