import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/agency_page_layout.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_action_button.dart';

class AgencyPartneredScreen extends ConsumerStatefulWidget {
  const AgencyPartneredScreen({super.key});

  @override
  ConsumerState<AgencyPartneredScreen> createState() => _AgencyPartneredScreenState();
}

class _AgencyPartneredScreenState extends ConsumerState<AgencyPartneredScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(agencyRosterProvider.notifier).refresh();
    });
  }

  Future<void> _refresh() async {
    await ref.read(agencyRosterProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    final navClearance = MediaQuery.of(context).padding.bottom + 104;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap + 16;

    final surface = theme == Brightness.dark ? AppColors.darkSurface : AppColors.white;
    final muted = theme == Brightness.dark ? AppColors.darkMuted : AppColors.gray;
    final text = theme == Brightness.dark ? AppColors.darkText : AppColors.black;
    final outline = theme == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder;

    final rosterState = ref.watch(agencyRosterProvider);
    final roster = rosterState.valueOrNull ?? [];
    final rosterCount = roster.length;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(role: BCPortalRole.agency, currentIndex: 3),
      body: AgencyPageLayout(
          child: BCPageSwipeArea(
            role: BCPortalRole.agency,
            currentIndex: 3,
            child: BCLoadingOverlay(
              isLoading: rosterState.isLoading,
              child: RefreshIndicator(
                color: AppColors.agencyPrimary,
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(top: sheetTop),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          border: Border(top: BorderSide(color: AppColors.agencyDark, width: 2.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 30, AppSpacing.screenPadding, AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Partnered', style: AppTypography.displaySM.copyWith(
                                    color: AppColors.agencyDark, fontWeight: FontWeight.w900,
                                  )),
                                  const Spacer(),
                                  BCBadge(
                                    label: '$rosterCount creators',
                                    variant: BCBadgeVariant.outline,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.agencyPrimary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.agencyPrimary.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Symbols.groups_rounded, color: AppColors.agencyDark, size: 18),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Your Roster', style: AppTypography.labelMD.copyWith(color: AppColors.agencyDark)),
                                          Text('Pitch them to brands or manage partnerships', style: AppTypography.bodyXS.copyWith(color: muted)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => context.push(RouteNames.agencyDiscover),
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.agencyDark,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Symbols.add_rounded, color: AppColors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (roster.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyPartneredState(
                          muted: muted,
                          surfaceColor: surface,
                          outlineColor: outline,
                          textColor: text,
                          onAction: () => context.push(RouteNames.agencyDiscover),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, 0,
                          AppSpacing.screenPadding, AppSpacing.huge + navClearance,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final creator = roster[index];
                              return _PartneredCard(
                                creator: creator,
                                onTap: () => _showCreatorActions(context, creator),
                              );
                            },
                            childCount: roster.length,
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

  void _showCreatorActions(BuildContext context, Map<String, dynamic> creator) {
    final firstName = creator['first_name'] ?? creator['profile']?['first_name'] ?? 'Creator';
    final avatarUrl = creator['avatar_url'] ?? creator['profile']?['avatar_url'];
    final niche = creator['niche'];
    final followers = _formatFollowers(creator['followers_count']);
    final status = creator['status'] ?? 'accepted';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.agencyDark.withValues(alpha: 0.2),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person, color: AppColors.agencyDark) : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(firstName, style: AppTypography.displaySM.copyWith(color: AppColors.white)),
                      if (niche != null)
                        Text(
                          niche is List ? (niche).join(', ') : niche.toString(),
                          style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                        ),
                    ],
                  ),
                ),
                if (followers.isNotEmpty)
                  BCBadge(label: followers, variant: BCBadgeVariant.outline),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: status == 'accepted'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: status == 'accepted'
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'accepted' ? Symbols.check_circle_rounded : Symbols.pending_rounded,
                    color: status == 'accepted' ? AppColors.success : AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    status == 'accepted' ? 'Partnered with your agency' : 'Pending confirmation',
                    style: AppTypography.labelSM.copyWith(
                      color: status == 'accepted' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CreatorActionRow(
              icon: Symbols.send_rounded,
              label: 'Pitch for a Brand',
              subtitle: 'Suggest this creator to brands',
              onTap: () {
                Navigator.pop(ctx);
                context.push(RouteNames.agencyPitchBrand);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _CreatorActionRow(
              icon: Symbols.person_rounded,
              label: 'View Profile',
              subtitle: 'See creator details and stats',
              onTap: () {
                Navigator.pop(ctx);
                context.push(RouteNames.partnerProfile, extra: creator);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _CreatorActionRow(
              icon: Symbols.remove_circle_rounded,
              label: 'Remove from Roster',
              subtitle: 'Stop representing this creator',
              isDestructive: true,
              onTap: () {
                Navigator.pop(ctx);
                _confirmRemove(context, creator);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Center(
                child: Text('Cancel', style: AppTypography.labelMD.copyWith(color: AppColors.muted)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, Map<String, dynamic> creator) {
    final firstName = creator['first_name'] ?? creator['profile']?['first_name'] ?? 'Creator';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove $firstName?', style: AppTypography.displaySM.copyWith(color: AppColors.white)),
        content: Text(
          'This creator will be removed from your roster. You can re-pitch them anytime.',
          style: AppTypography.bodySM.copyWith(color: AppColors.muted),
        ),
        actions: [
          BCActionButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
          const SizedBox(width: AppSpacing.sm),
          BCActionButton(
            label: 'Remove',
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$firstName removed from roster')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatFollowers(dynamic count) {
    if (count == null) return '';
    try {
      final c = count is int ? count : int.parse(count.toString());
      if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
      if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
      return c.toString();
    } catch (_) {
      return '';
    }
  }
}

class _PartneredCard extends StatelessWidget {
  const _PartneredCard({required this.creator, required this.onTap});

  final Map<String, dynamic> creator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final profile = creator['profile'];
    final firstName = creator['first_name'] ?? profile?['first_name'] ?? 'Creator';
    final avatarUrl = creator['avatar_url'] ?? profile?['avatar_url'];
    final niche = creator['niche'];
    final followers = _formatFollowers(creator['followers_count']);
    final tier = creator['tier'];
    final totalCollabs = creator['total_collabs'];
    final acceptedAt = creator['accepted_at'];
    final status = creator['status'] ?? 'accepted';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BCCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.agencyDark.withValues(alpha: 0.15),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person, color: AppColors.agencyDark) : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(firstName, style: AppTypography.labelLG.copyWith(color: text)),
                      if (niche != null)
                        Text(
                          niche is List ? (niche).join(', ') : niche.toString(),
                          style: AppTypography.bodyXS.copyWith(color: muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (followers.isNotEmpty)
                      BCBadge(label: followers, variant: BCBadgeVariant.outline),
                    if (tier != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: BCBadge(label: tier.toString().toUpperCase(), variant: _getTierVariant(tier.toString())),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (totalCollabs != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.handshake_rounded, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('$totalCollabs collabs', style: AppTypography.labelXS.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (acceptedAt != null) ...[
                  const Icon(Symbols.calendar_today_rounded, size: 12, color: AppColors.gray),
                  const SizedBox(width: 4),
                  Text('Since ${_formatDate(acceptedAt)}', style: AppTypography.labelXS.copyWith(color: muted)),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: status == 'accepted' ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: AppTypography.labelXS.copyWith(
                      color: status == 'accepted' ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFollowers(dynamic count) {
    if (count == null) return '';
    try {
      final c = count is int ? count : int.parse(count.toString());
      if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
      if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
      return c.toString();
    } catch (_) {
      return '';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date.toString());
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  BCBadgeVariant _getTierVariant(String tier) {
    return switch (tier.toLowerCase()) {
      'mega' => BCBadgeVariant.pink,
      'macro' => BCBadgeVariant.orange,
      'mid' => BCBadgeVariant.blue,
      'micro' => BCBadgeVariant.purple,
      _ => BCBadgeVariant.outline,
    };
  }
}

class _CreatorActionRow extends StatelessWidget {
  const _CreatorActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.agencyPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.agencyPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMD.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.white,
                    ),
                  ),
                  Text(subtitle, style: AppTypography.labelXS.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              Symbols.arrow_forward_rounded,
              color: isDestructive ? AppColors.error : AppColors.muted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPartneredState extends StatelessWidget {
  const _EmptyPartneredState({
    required this.muted,
    required this.surfaceColor,
    required this.outlineColor,
    required this.textColor,
    required this.onAction,
  });

  final Color muted;
  final Color surfaceColor;
  final Color outlineColor;
  final Color textColor;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.screenPadding),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: outlineColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.group_add_rounded, size: 56, color: AppColors.agencyDark.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('No roster yet', style: AppTypography.labelLG.copyWith(color: textColor, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pitch creators to add them to your roster',
              style: AppTypography.bodySM.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            UnconstrainedBox(
              child: BCActionButton(label: 'Discover Creators', onPressed: onAction),
            ),
          ],
        ),
      ),
    );
  }
}