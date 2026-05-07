import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/brand_page_top_header.dart';

class BrandHomeScreen extends ConsumerStatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  ConsumerState<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends ConsumerState<BrandHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadInitialData);
    Future<void>.microtask(() {
      ref.read(brandRequestsProvider);
      ref.read(brandProfileProvider);
    });
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
    final state = ref.watch(brandProvider);
    final theme = Theme.of(context).brightness;
    final navClearance = MediaQuery.of(context).padding.bottom + 104;

    final bg = theme == Brightness.dark ? AppColors.darkBg : AppColors.lightBg;
    final surface = theme == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final outline = theme == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.lightBorder;
    final text = theme == Brightness.dark ? AppColors.darkText : AppColors.black;
    final muted = theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 0,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 0,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: bg),
              ),
            ),
            Positioned(
              top: -46,
              right: -32,
              child: _GlowOrb(
                size: 136,
                color: AppColors.brandPrimary.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              top: 220,
              left: -44,
              child: _GlowOrb(
                size: 112,
                color: AppColors.brandDark.withValues(
                  alpha: theme == Brightness.dark ? 0.14 : 0.08,
                ),
              ),
            ),
            BCLoadingOverlay(
              isLoading: state.isLoading,
              child: RefreshIndicator(
                color: AppColors.brandPrimary,
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    MediaQuery.of(context).padding.top + 14,
                    AppSpacing.screenPadding,
                    navClearance,
                  ),
                  children: [
                    const BrandPageTopHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    _MetricRow(
                      left: _MetricData(
                        label: 'Current credits',
                        value: Formatters.currencyFromINR(state.creditBalance),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      right: _MetricData(
                        label: 'Current collabs',
                        value: '${state.activeCollabs.length}',
                        icon: Icons.handshake_rounded,
                      ),
                      mutedColor: muted,
                      surfaceColor: surface,
                      outlineColor: outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _NeonFeatureCard(
                      title: 'Post a campaign',
                      subtitle:
                          'Reach creators with a clean, high-conversion brief.',
                      metricLabel: '${state.activeCampaignCount} active now',
                      ctaLabel: 'Create brief',
                      onTap: () => context.push(RouteNames.createCampaign),
                      textColor: theme == Brightness.dark
                          ? AppColors.darkText
                          : AppColors.brandDark,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Quick Actions',
                      actionLabel: 'See all',
                      onTap: () => context.push(RouteNames.brandDiscover),
                      mutedColor: muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: _quickActions(context).length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final action = _quickActions(context)[index];
                          return _QuickActionChip(
                            action: action,
                            textColor: text,
                            mutedColor: muted,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Latest Campaigns',
                      actionLabel: 'Manage',
                      onTap: () => context.push(RouteNames.brandCampaigns),
                      mutedColor: muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (state.campaigns.isEmpty)
                      _EmptyBlock(
                        title: 'No campaigns yet',
                        subtitle:
                            'Post your first brief to start building a creator pipeline.',
                        textColor: text,
                        mutedColor: muted,
                        surfaceColor: surface,
                        outlineColor: outline,
                      )
                    else
                      SizedBox(
                        height: 188,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: state.campaigns.take(5).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final campaign = state.campaigns[index];
                            return _CampaignCard(
                              campaign: campaign,
                              textColor: text,
                              mutedColor: muted,
                              surfaceColor: surface,
                              outlineColor: outline,
                              onTap: () => context.push(
                                RouteNames.campaignBids.replaceFirst(
                                  ':id',
                                  campaign.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Active Collabs',
                      actionLabel: 'View',
                      onTap: () => context.push(RouteNames.brandCollabs),
                      mutedColor: muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (state.activeCollabs.isEmpty)
                      _EmptyBlock(
                        title: 'No active collabs yet',
                        subtitle:
                            'Accepted bids and live collaborations will appear here.',
                        textColor: text,
                        mutedColor: muted,
                        surfaceColor: surface,
                        outlineColor: outline,
                      )
                    else
                      Column(
                        children: state.activeCollabs.take(3).map((collab) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CollabCard(
                              collab: collab,
                              textColor: text,
                              mutedColor: muted,
                              surfaceColor: surface,
                              outlineColor: outline,
                              onTap: () => context.push(RouteNames.brandCollabs),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_QuickActionData> _quickActions(BuildContext context) {
    return [
      _QuickActionData(
        icon: Symbols.campaign_rounded,
        label: 'Post',
        hint: 'Campaign',
        onTap: () => context.push(RouteNames.createCampaign),
      ),
      _QuickActionData(
        icon: Symbols.search_rounded,
        label: 'Find',
        hint: 'Creators',
        onTap: () => context.push(RouteNames.brandDiscover),
      ),
      _QuickActionData(
        icon: Symbols.inbox_rounded,
        label: 'Inbox',
        hint: 'Requests',
        onTap: () => context.push(RouteNames.brandRequests),
      ),
      _QuickActionData(
        icon: Icons.calendar_month_rounded,
        label: 'Events',
        hint: 'Plans',
        onTap: () => context.push(RouteNames.brandEvents),
      ),
    ];
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.brandName,
    required this.brandCategory,
    required this.avatarLabel,
    required this.notificationsCount,
    required this.mutedColor,
  });

  final String brandName;
  final String brandCategory;
  final String avatarLabel;
  final int notificationsCount;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.brandDark.withValues(alpha: 0.16),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            avatarLabel,
            style: AppTypography.labelLG.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: AppTypography.bodySM.copyWith(color: mutedColor),
              ),
              const SizedBox(height: 2),
              Text(
                brandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                brandCategory,
                style: AppTypography.bodyXS.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandDark.withValues(alpha: 0.14),
                ),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Symbols.notifications_rounded,
                  size: 22,
                ),
                color: AppColors.brandDark,
                splashRadius: 22,
                tooltip: 'Notifications',
              ),
            ),
            if (notificationsCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.left,
    required this.right,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  final _MetricData left;
  final _MetricData right;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
      return Row(
      children: [
        Expanded(
          child: _MetricCard(
            metric: left,
            mutedColor: mutedColor,
            surfaceColor: surfaceColor,
            outlineColor: outlineColor,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            metric: right,
            mutedColor: mutedColor,
            surfaceColor: surfaceColor,
            outlineColor: outlineColor,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  final _MetricData metric;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineColor),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandDark.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              metric.icon,
              color: AppColors.brandDark,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            metric.label,
            style: AppTypography.bodyXS.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displaySM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonFeatureCard extends StatelessWidget {
  const _NeonFeatureCard({
    required this.title,
    required this.subtitle,
    required this.metricLabel,
    required this.ctaLabel,
    required this.onTap,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final String metricLabel;
  final String ctaLabel;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.brandPrimary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.brandDark.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandDark.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lightBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandDark.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Icon(
                    Symbols.auto_awesome_rounded,
                    color: AppColors.brandDark,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  metricLabel,
                  style: AppTypography.labelSM.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTypography.displaySM.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodySM.copyWith(
                color: textColor.withValues(alpha: 0.84),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ctaLabel,
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Symbols.arrow_forward_rounded,
                  color: AppColors.brandDark,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.action,
    required this.textColor,
    required this.mutedColor,
  });

  final _QuickActionData action;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandDark.withValues(alpha: 0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 0,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Icon(
                action.icon,
                color: AppColors.brandDark,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSM.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              action.hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyXS.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
    required this.mutedColor,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.displaySM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.brandDark.withValues(alpha: 0.14),
            ),
          ),
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandDark,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              actionLabel,
              style: AppTypography.labelSM.copyWith(
                color: AppColors.brandDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.onTap,
  });

  final Campaign campaign;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deliverables = campaign.deliverables.take(2).join(' / ');
    final location = campaign.targetCity ??
        campaign.targetState ??
        'Pan India';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 288,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: outlineColor),
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
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.lightBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandDark.withValues(alpha: 0.14),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      campaign.brandInitial,
                      style: AppTypography.labelMD.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLG.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location,
                          style: AppTypography.bodyXS.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                Formatters.currencyFromINR(campaign.minBudget),
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deliverables.isEmpty
                    ? 'Deliverables discussed after approval'
                    : deliverables,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyXS.copyWith(color: mutedColor),
              ),
              const Spacer(),
              Row(
                children: [
                  _StatusPill(
                    label: _statusLabel(campaign.status),
                    isActive: campaign.status == CampaignStatus.active,
                  ),
                  const Spacer(),
                  Text(
                    '${campaign.bidCount} bids',
                    style: AppTypography.bodyXS.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? null
            : AppColors.brandDark.withValues(alpha: 0.08),
        gradient: isActive ? AppColors.brandPrimaryGlassGradient : null,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.brandPrimaryGlassBorder
              : AppColors.brandDark.withValues(alpha: 0.16),
        ),
        boxShadow: isActive
            ? [
                const BoxShadow(
                  color: AppColors.brandPrimaryGlassShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CollabCard extends StatelessWidget {
  const _CollabCard({
    required this.collab,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.onTap,
  });

  final ActiveCollabSummary collab;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: outlineColor),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                collab.creatorName.isEmpty
                    ? 'C'
                    : collab.creatorName.substring(0, 1).toUpperCase(),
                style: AppTypography.labelLG.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collab.creatorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLG.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    collab.campaignTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyXS.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusPill(
                  label: _collabLabel(collab.status),
                  isActive: collab.status.toLowerCase() == 'active',
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  collab.agreedAmount == null
                      ? 'Amount pending'
                      : Formatters.currencyFromINR(collab.agreedAmount!),
                  style: AppTypography.bodyXS.copyWith(color: mutedColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  final String title;
  final String subtitle;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineColor),
      ),
      child: Column(
        children: [
          Icon(
            Symbols.pause_circle_rounded,
            size: 40,
            color: AppColors.brandDark.withValues(alpha: 0.8),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.labelLG.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodySM.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
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

String _collabLabel(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return 'In progress';
    case 'active':
      return 'Active';
    default:
      return 'Live';
  }
}

