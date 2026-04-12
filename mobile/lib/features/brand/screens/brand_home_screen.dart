import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../shared/widgets/home_carousel_strip.dart';

class BrandHomeScreen extends ConsumerStatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  ConsumerState<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends ConsumerState<BrandHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadInitialData);
    Future<void>.microtask(() {
      ref.read(brandRequestsProvider);
      ref.read(brandProfileProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await ref.read(brandProvider.notifier).fetchBrandHome(showLoader: true);
    unawaited(ref.read(notificationProvider.notifier).fetchNotifications());
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(brandProvider.notifier).refreshBrandHome(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final brandState = ref.watch(brandProvider);

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 0,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 0,
        child: BCLoadingOverlay(
          isLoading: brandState.isLoading,
          child: RefreshIndicator(
            color: AppColors.neon,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                    AppSpacing.screenPadding,
                    AppSpacing.huge,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (brandState.carouselItems.isNotEmpty) ...[
                        HomeCarouselStrip(
                          items: brandState.carouselItems,
                          height: 136,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _MiniStatPill(
                            emoji: '⚡',
                            label: '${brandState.creditBalance} credits',
                            backgroundColor: AppColors.blue,
                            textColor: AppColors.white,
                          ),
                          _MiniStatPill(
                            emoji: '📢',
                            label:
                                '${brandState.activeCampaignCount} campaigns',
                            backgroundColor: AppColors.ink,
                            textColor: AppColors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _ActionCard(
                                emoji: '📢',
                                title: 'Post Campaign',
                                subtitle: 'Let creators bid for you',
                                shadow: AppShadows.pink,
                                onTap: () =>
                                    context.push(RouteNames.createCampaign),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _ActionCard(
                                emoji: '🔍',
                                title: 'Find Creators',
                                subtitle: 'Browse and send requests',
                                shadow: AppShadows.neon,
                                onTap: () =>
                                    context.push(RouteNames.brandDiscover),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BCCard(
                        shadow: AppShadows.purple,
                        onTap: () => context.push(RouteNames.createEvent),
                        child: const Row(
                          children: [
                            Text('🎟️', style: TextStyle(fontSize: 30)),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Host an Event',
                                      style: AppTypography.labelLG),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Invite creators to your IRL event',
                                    style: AppTypography.bodyXS,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Symbols.arrow_forward_rounded,
                                color: AppColors.ink),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _SectionHeader(
                        title: 'Active Collabs',
                        actionLabel: 'Manage →',
                        onTap: () => context.push(RouteNames.brandCollabs),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (brandState.activeCollabs.isEmpty)
                        const _EmptyState(
                          emoji: '🤝',
                          message:
                              'No active collabs yet.\nAccept a bid or request to see live collaborations here.',
                        )
                      else
                        SizedBox(
                          height: 196,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final collab = brandState.activeCollabs[index];
                              return SizedBox(
                                width: 260,
                                child: BCCard(
                                  shadow: AppShadows.pink,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(collab.creatorName,
                                                style: AppTypography.labelLG),
                                          ),
                                          BCBadge(
                                            label: _collabStatusLabel(
                                                collab.status),
                                            variant: _collabStatusVariant(
                                                collab.status),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      BCBadge(
                                        label: collab.campaignTitle,
                                        variant: BCBadgeVariant.neon,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        _collabMeta(collab),
                                        style: AppTypography.bodySM
                                            .copyWith(color: AppColors.muted),
                                      ),
                                      const Spacer(),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: BCPrimaryButton.dark(
                                          label: 'Open Collabs →',
                                          onPressed: () => context
                                              .push(RouteNames.brandCollabs),
                                          isFullWidth: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.md),
                            itemCount: brandState.activeCollabs.length,
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.emoji,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.labelSM.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.shadow,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<BoxShadow> shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: shadow,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodyXS),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.displaySM)),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.pink,
              textStyle: AppTypography.labelSM,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.emoji,
    required this.message,
  });

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return 'Active';
    case CampaignStatus.paused:
      return 'Paused';
    case CampaignStatus.completed:
      return 'Completed';
  }
}

BCBadgeVariant _statusVariant(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.active:
      return BCBadgeVariant.neon;
    case CampaignStatus.paused:
      return BCBadgeVariant.warning;
    case CampaignStatus.completed:
      return BCBadgeVariant.blue;
  }
}

String _deadlineCopy(DateTime deadline) {
  final duration = deadline.difference(DateTime.now());
  if (duration.isNegative) {
    return 'Ended ${timeago.format(deadline)}';
  }
  if (duration.inDays >= 1) {
    return '${duration.inDays} days left';
  }
  if (duration.inHours >= 1) {
    return '${duration.inHours} hours left';
  }
  return '${duration.inMinutes.clamp(1, 59)} minutes left';
}

String _collabStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return 'In Progress';
    case 'active':
      return 'Active';
    default:
      return 'Live';
  }
}

BCBadgeVariant _collabStatusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return BCBadgeVariant.blue;
    case 'active':
      return BCBadgeVariant.neon;
    default:
      return BCBadgeVariant.warning;
  }
}

String _collabMeta(ActiveCollabSummary collab) {
  final amount = collab.agreedAmount;
  final startedAt = collab.startedAt;

  final amountCopy = amount != null ? 'Rs $amount' : 'Amount not set';
  final startedCopy = startedAt != null
      ? 'Started ${timeago.format(startedAt)}'
      : 'Start date pending';

  return '$amountCopy • $startedCopy';
}
