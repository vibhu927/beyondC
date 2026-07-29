import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/analytics_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(brandAnalyticsProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.lightBg),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      MediaQuery.of(context).padding.top + 14,
                      AppSpacing.screenPadding,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.brandDark.withValues(alpha: 0.14),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.brandDark,
                              size: 22,
                            ),
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Analytics',
                          style: AppTypography.displaySM.copyWith(
                            color: AppColors.brandDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: analyticsAsync.when(
                      loading: () => const Center(child: BCAppLoader()),
                      error: (error, _) => BCErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(brandAnalyticsProvider),
                      ),
                      data: (analytics) {
                        return RefreshIndicator(
                          onRefresh: () => ref.refresh(brandAnalyticsProvider.future),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              AppSpacing.md,
                              AppSpacing.screenPadding,
                              AppSpacing.huge,
                            ),
                            children: [
                              _SummaryCards(
                                totalCampaigns: analytics.totalCampaigns,
                                activeCampaigns: analytics.activeCampaigns,
                                completedCollabs: analytics.completedCollabs,
                                totalSpent: analytics.totalSpentPaise,
                                avgRating: analytics.avgRating,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'Campaigns',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.brandDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (analytics.campaigns.isEmpty)
                                _EmptyCampaigns()
                              else
                                ...analytics.campaigns.map(
                                  (campaign) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _CampaignCard(campaign: campaign),
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
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCollabs,
    required this.totalSpent,
    required this.avgRating,
  });

  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCollabs;
  final int totalSpent;
  final double avgRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.lightBorder),
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
          Text(
            'Overview',
            style: AppTypography.labelLG.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Campaigns',
                  value: '$totalCampaigns',
                  icon: Symbols.campaign_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: '$activeCampaigns',
                  icon: Symbols.play_circle_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Completed',
                  value: '$completedCollabs',
                  icon: Symbols.check_circle_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Spent',
                  value: Formatters.currencyFromINR(totalSpent),
                  icon: Symbols.payments_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Avg Rating',
                  value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '-',
                  icon: Symbols.star_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandDark.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.brandDark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.brandDark.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.labelLG.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign});

  final dynamic campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: AppTypography.labelLG.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: campaign.status == 'active'
                      ? AppColors.brandPrimary
                      : AppColors.brandDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  campaign.status.toUpperCase(),
                  style: AppTypography.labelXS.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniStat(label: 'Collabs', value: '${campaign.collabsCount}'),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(label: 'Submissions', value: '${campaign.totalSubmissions}'),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(
                label: 'Completion',
                value: '${campaign.completionRate}%',
              ),
            ],
          ),
          if (campaign.collabsCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: campaign.completionRate / 100,
                minHeight: 6,
                backgroundColor: AppColors.brandDark.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  campaign.completionRate >= 80
                      ? AppColors.success
                      : campaign.completionRate >= 50
                          ? AppColors.brandPrimary
                          : AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.labelMD.copyWith(
            color: AppColors.brandDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _EmptyCampaigns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Center(
        child: Text(
          'No campaigns yet.\nCreate your first campaign to see analytics.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
        ),
      ),
    );
  }
}
