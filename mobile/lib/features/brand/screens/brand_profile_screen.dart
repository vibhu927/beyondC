import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class BrandProfileScreen extends ConsumerStatefulWidget {
  const BrandProfileScreen({super.key});

  @override
  ConsumerState<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends ConsumerState<BrandProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
        () => ref.read(brandProvider.notifier).fetchBrandHome());
  }

  Future<void> _logout() async {
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      context.go(RouteNames.login);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandProvider);
    final profile = state.brandProfile;

    if (profile == null && state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load brand profile')),
      );
    }

    final campaigns = state.campaigns.take(3).toList();

    return Scaffold(
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 3,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Brand Profile',
              style: AppTypography.displaySM.copyWith(color: AppColors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.pink, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profile.logoInitial,
                        style: AppTypography.displaySM
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.brandName,
                          style: AppTypography.labelLG
                              .copyWith(color: AppColors.white),
                        ),
                        if (profile.verified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.neon, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    BCBadge(
                      label: profile.category,
                      variant: BCBadgeVariant.pink,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Collabs',
                          value: '${profile.totalCollabs}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatCard(
                          label: 'Active Campaigns',
                          value: '${state.activeCampaignCount}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatCard(
                          label: 'Avg Rating',
                          value: profile.avgRating.toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BCCard(
                    shadow: AppShadows.pink,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Brand Info',
                            style: AppTypography.displaySM),
                        const SizedBox(height: AppSpacing.sm),
                        _infoRow('Brand Name', profile.brandName),
                        _infoRow('Category', profile.category),
                        _infoRow('Website', profile.website),
                        _infoRow('Description', profile.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!profile.verified)
                    BCCard(
                      backgroundColor: const Color(0xFFFFF7D6),
                      shadow: AppShadows.orange,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '⚠️ Verify your brand for a badge. Upload GST →',
                              style: AppTypography.bodySM,
                            ),
                          ),
                          BCPrimaryButton.neon(
                            label: 'Upload GST',
                            isFullWidth: false,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Verification flow coming soon.')),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    BCCard(
                      backgroundColor: const Color(0xFFE8FCEB),
                      child: const Text(
                        '✅ Verified Brand',
                        style: AppTypography.labelMD,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Past Campaigns',
                            style: AppTypography.displaySM),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(RouteNames.brandCampaigns),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.pink),
                        child: const Text('See all →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final campaign in campaigns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: BCCard(
                        backgroundColor: AppColors.surfaceAlt,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(campaign.title,
                                      style: AppTypography.labelMD),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${campaign.bidCount} collabs',
                                    style: AppTypography.bodyXS,
                                  ),
                                ],
                              ),
                            ),
                            BCBadge(
                              label: _statusLabel(campaign.status),
                              variant: _statusVariant(campaign.status),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  BCCard(
                    shadow: AppShadows.blue,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚡ Credits: ${state.creditBalance}',
                                style: AppTypography.displaySM,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        BCPrimaryButton.neon(
                          label: 'Buy Credits →',
                          isFullWidth: false,
                          onPressed: () =>
                              context.push(RouteNames.brandCredits),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => context.push(RouteNames.settings),
                          leading: const Text('⚙️'),
                          title: const Text('Settings',
                              style: AppTypography.labelMD),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: _logout,
                          leading: const Text('🚪'),
                          title: Text(
                            'Logout',
                            style: AppTypography.labelMD
                                .copyWith(color: AppColors.error),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: AppTypography.labelSM,
          children: [
            TextSpan(text: value, style: AppTypography.bodySM),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.pink,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(label, textAlign: TextAlign.center, style: AppTypography.bodyXS),
        ],
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
