import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/cards/bc_card.dart';

class CreatorProfileScreen extends ConsumerStatefulWidget {
  const CreatorProfileScreen({super.key});

  @override
  ConsumerState<CreatorProfileScreen> createState() =>
      _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends ConsumerState<CreatorProfileScreen> {
  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorProfileProvider.notifier).refresh(),
      ref.read(creatorCollabsProvider.notifier).refresh(),
      ref.read(walletProvider.notifier).refresh(),
    ]);
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
    final profileAsync = ref.watch(creatorProfileProvider);
    final collabsAsync = ref.watch(creatorCollabsProvider);
    final walletAsync = ref.watch(walletProvider);

    if (profileAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }

    if (profileAsync.hasError) {
      return Scaffold(
        body: BCErrorState(
          message: profileAsync.error.toString(),
          onRetry: _refresh,
        ),
      );
    }

    final profile = profileAsync.value;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load profile')),
      );
    }

    final pastCollabs =
        collabsAsync.valueOrNull?.take(3).toList() ?? const <Collab>[];
    final walletBalance =
        walletAsync.valueOrNull?.balance ?? profile.walletBalancePaise;

    return Scaffold(
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 3,
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Profile',
                style: AppTypography.displaySM.copyWith(color: AppColors.white),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.neon,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _avatarInitials(profile.fullName),
                                style: AppTypography.labelLG
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              profile.fullName,
                              style: AppTypography.labelLG
                                  .copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            BCBadge(
                              label: profile.tier,
                              variant: BCBadgeVariant.neon,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.lg,
                        top: AppSpacing.lg,
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit profile coming soon.'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.white,
                          ),
                        ),
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
                            value: Formatters.followerCount(profile.followers),
                            label: 'Followers',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            value:
                                '${profile.engagementRate.toStringAsFixed(1)}%',
                            label: 'Engagement',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            value: Formatters.currency(profile.avgCollabPaise),
                            label: 'Avg Collab',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text('About', style: AppTypography.displaySM),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.bio,
                      style:
                          AppTypography.bodySM.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: profile.niches
                          .map(
                            (niche) => BCBadge(
                              label: niche,
                              variant: BCBadgeVariant.outline,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Platforms & Handles',
                      style: AppTypography.displaySM,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PlatformTile(
                      title: 'Instagram',
                      connected: profile.instagramConnected,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PlatformTile(
                      title: 'YouTube',
                      connected: profile.youtubeConnected,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text('Content Types', style: AppTypography.displaySM),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: profile.contentTypes
                          .map((contentType) => BCBadge(
                                label: contentType,
                                variant: BCBadgeVariant.outline,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BCCard(
                      shadow: AppShadows.neon,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting at ${Formatters.currency(profile.startingPricePaise)}/collab',
                            style: AppTypography.displaySM,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Pricing editor coming soon.'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.pink,
                              ),
                              child: const Text('Edit pricing →'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Past Collabs (${collabsAsync.valueOrNull?.length ?? 0})',
                            style: AppTypography.displaySM,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Showing latest 3 for now.'),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.pink,
                          ),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    if (collabsAsync.isLoading)
                      const _PastCollabsShimmerList()
                    else if (collabsAsync.hasError)
                      BCErrorState(
                        message: collabsAsync.error.toString(),
                        onRetry: () => ref.invalidate(creatorCollabsProvider),
                      )
                    else
                      Column(
                        children: pastCollabs
                            .map(
                              (collab) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: BCCard(
                                  backgroundColor: AppColors.surfaceAlt,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${collab.brandCategory} • ${_collabTypeLabel(collab.collabType)}',
                                              style: AppTypography.labelMD,
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.xs),
                                            Text(
                                              '⭐' *
                                                  ((collab.rating ?? 4)
                                                      .clamp(1, 5)),
                                              style: AppTypography.bodySM,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        Formatters.currency(collab.amount),
                                        style: AppTypography.labelLG,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    BCCard(
                      shadow: AppShadows.neon,
                      onTap: () => context.push(RouteNames.creatorWallet),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💰 Wallet Balance',
                                  style: AppTypography.labelMD,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  Formatters.currency(walletBalance),
                                  style: AppTypography.displaySM
                                      .copyWith(color: AppColors.neon),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.creatorWallet),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSM),
                                border:
                                    Border.all(color: AppColors.ink, width: 2),
                              ),
                              child: Text(
                                'Top Up →',
                                style: AppTypography.labelSM
                                    .copyWith(color: AppColors.neon),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BCCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => context.push(RouteNames.settings),
                            leading: const Text('⚙️'),
                            title: const Text(
                              'Settings',
                              style: AppTypography.labelMD,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                          const Divider(color: AppColors.divider, height: 1),
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.neon,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyXS,
          ),
        ],
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.title,
    required this.connected,
  });

  final String title;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.labelMD),
          ),
          Text(
            connected ? '✅ Connected' : 'Not connected',
            style: AppTypography.labelSM.copyWith(
              color: connected ? AppColors.success : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PastCollabsShimmerList extends StatelessWidget {
  const _PastCollabsShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightDivider,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt,
            child: BCCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          height: 14,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 70,
                          height: 12,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 64, height: 16, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _avatarInitials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'C';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _collabTypeLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}
