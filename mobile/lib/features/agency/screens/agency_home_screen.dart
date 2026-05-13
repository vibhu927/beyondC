import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/agency_page_layout.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_action_button.dart';

class AgencyHomeScreen extends ConsumerStatefulWidget {
  const AgencyHomeScreen({super.key});

  @override
  ConsumerState<AgencyHomeScreen> createState() => _AgencyHomeScreenState();
}

class _AgencyHomeScreenState extends ConsumerState<AgencyHomeScreen> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    Future<void>.microtask(_loadInitialData);
    Future<void>.microtask(() {
      ref.read(agencyProfileProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    unawaited(ref.read(agencyProfileProvider.future));
    unawaited(ref.read(notificationProvider.notifier).fetchNotifications());
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(agencyProfileProvider.notifier).refresh(),
      ref.read(notificationProvider.notifier).refreshNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyProfileProvider);
    final theme = Theme.of(context).brightness;
    final navClearance = MediaQuery.of(context).padding.bottom + 104;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap + 16;

    final surface = theme == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final text = theme == Brightness.dark ? AppColors.darkText : AppColors.black;
    final muted = theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;
    final outline = theme == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final creditBalance = state.valueOrNull?['credit_balance'] ?? 0;
    final partneredCount = state.valueOrNull?['total_partnered_creators'] ?? 0;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.agency,
        currentIndex: 0,
      ),
      body: AgencyPageLayout(
        scrollOffset: _scrollOffset,
        child: BCPageSwipeArea(
          role: BCPortalRole.agency,
          currentIndex: 0,
          child: BCLoadingOverlay(
            isLoading: state.isLoading,
            child: RefreshIndicator(
              color: AppColors.agencyPrimary,
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(0, sheetTop, 0, 0),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: const Border(
                        top: BorderSide(
                          color: AppColors.agencyDark,
                          width: 2.2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.lg,
                        AppSpacing.screenPadding,
                        AppSpacing.huge + navClearance,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MetricRow(
                            left: _MetricData(
                              label: 'Credits',
                              value: '$creditBalance',
                              icon: Icons.account_balance_wallet_rounded,
                            ),
                            right: _MetricData(
                              label: 'Creators',
                              value: '$partneredCount',
                              icon: Icons.groups_rounded,
                            ),
                            mutedColor: muted,
                            surfaceColor: surface,
                            outlineColor: outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _NeonFeatureCard(
                            title: 'Discover Creators',
                            subtitle: 'Find the best creators for your brand campaigns.',
                            metricLabel: '$partneredCount partnered',
                            ctaLabel: 'Explore',
                            onTap: () => context.push(RouteNames.agencyDiscover),
                            textColor: theme == Brightness.dark
                                ? AppColors.darkText
                                : AppColors.agencyDark,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SectionHeader(
                            title: 'Quick Actions',
                            actionLabel: 'See all',
                            onTap: () => context.push(RouteNames.agencyDiscover),
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
                            title: 'Recent Pitches',
                            actionLabel: 'Manage',
                            onTap: () => context.push(RouteNames.agencyPitches),
                            mutedColor: muted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _RecentPitchesPreview(
                            onViewAll: () => context.push(RouteNames.agencyPitches),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_QuickAction> _quickActions(BuildContext context) {
    return [
      _QuickAction(
        icon: Symbols.search_rounded,
        label: 'Discover',
        color: AppColors.agencyPrimary,
        onTap: () => context.push(RouteNames.agencyDiscover),
      ),
      _QuickAction(
        icon: Symbols.send_rounded,
        label: 'Pitch',
        color: AppColors.agencyDark,
        onTap: () => context.push(RouteNames.agencyPitchCreator),
      ),
      _QuickAction(
        icon: Symbols.groups_rounded,
        label: 'Roster',
        color: AppColors.success,
        onTap: () => context.push(RouteNames.agencyPartnered),
      ),
      _QuickAction(
        icon: Symbols.analytics_rounded,
        label: 'Analytics',
        color: AppColors.warning,
        onTap: () {},
      ),
    ];
  }
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
            data: left,
            mutedColor: mutedColor,
            surfaceColor: surfaceColor,
            outlineColor: outlineColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            data: right,
            mutedColor: mutedColor,
            surfaceColor: surfaceColor,
            outlineColor: outlineColor,
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.data,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
  });

  final _MetricData data;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outlineColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.agencyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: AppColors.agencyDark, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label, style: AppTypography.bodyXS.copyWith(color: mutedColor)),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: AppTypography.labelLG.copyWith(
                    color: AppColors.agencyDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
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
              AppColors.agencyPrimary.withValues(alpha: 0.12),
              AppColors.agencyPrimary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.agencyPrimary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLG.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXS.copyWith(
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.agencyDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      metricLabel,
                      style: AppTypography.labelXS.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.agencyDark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.agencyDark.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: 22,
              ),
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
        Text(
          title,
          style: AppTypography.labelLG.copyWith(
            color: AppColors.agencyDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.agencyPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.action,
    required this.textColor,
    required this.mutedColor,
  });

  final _QuickAction action;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: action.color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              action.label,
              style: AppTypography.labelSM.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPitchesPreview extends ConsumerWidget {
  const _RecentPitchesPreview({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchesState = ref.watch(agencyPitchesProvider);
    final pitches = pitchesState.valueOrNull ?? [];
    final recentPitches = pitches.take(2).toList();
    final theme = Theme.of(context).brightness;
    final surface = theme == Brightness.dark ? AppColors.darkSurface : AppColors.white;
    final outline = theme == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;

    if (recentPitches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outline),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Symbols.send_rounded, size: 40, color: muted),
              const SizedBox(height: AppSpacing.sm),
              Text('No pitches yet', style: AppTypography.labelSM.copyWith(color: muted)),
              const SizedBox(height: AppSpacing.md),
              UnconstrainedBox(
                child: BCActionButton(
                  label: 'Send First Pitch',
                  onPressed: onViewAll,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...recentPitches.map((pitch) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: outline),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.agencyPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Symbols.send_rounded, color: AppColors.agencyPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pitch['title'] ?? pitch['creator_name'] ?? 'Pitch',
                      style: AppTypography.labelSM.copyWith(
                        color: AppColors.agencyDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      pitch['status']?.toString().toUpperCase() ?? 'PENDING',
                      style: AppTypography.labelXS.copyWith(
                        color: _getStatusColor(pitch['status']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(pitch['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pitch['status']?.toString().toUpperCase() ?? 'PENDING',
                  style: AppTypography.labelXS.copyWith(
                    color: _getStatusColor(pitch['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: AppSpacing.md),
        UnconstrainedBox(
          child: BCActionButton(
            label: 'View All Pitches',
            onPressed: onViewAll,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'accepted':
      case 'approved':
        return AppColors.success;
      case 'rejected':
      case 'declined':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}