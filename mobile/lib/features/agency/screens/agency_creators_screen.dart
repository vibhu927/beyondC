import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_action_button.dart';

class AgencyCreatorsScreen extends ConsumerStatefulWidget {
  const AgencyCreatorsScreen({super.key});

  @override
  ConsumerState<AgencyCreatorsScreen> createState() => _AgencyCreatorsScreenState();
}

class _AgencyCreatorsScreenState extends ConsumerState<AgencyCreatorsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(agencyRosterProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rosterState = ref.watch(agencyRosterProvider);
    final roster = rosterState.valueOrNull ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.agencyDark),
          onPressed: () => context.pop(),
        ),
        title: Text('My Creators', style: AppTypography.displaySM.copyWith(
          color: AppColors.agencyDark, fontWeight: FontWeight.w900,
        )),
      ),
      body: BCLoadingOverlay(
        isLoading: rosterState.isLoading,
        child: RefreshIndicator(
          color: AppColors.agencyPrimary,
          onRefresh: () => ref.read(agencyRosterProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Partnered', style: AppTypography.labelLG.copyWith(color: text)),
                  ),
                  BCActionButton(
                    label: 'Invite',
                    onPressed: () => context.push(RouteNames.agencyDiscover),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (roster.isEmpty)
                _EmptyCreatorsState(
                  muted: muted,
                  surface: surface,
                  outline: outline,
                  text: text,
                  onDiscover: () => context.push(RouteNames.agencyDiscover),
                )
              else
                ...roster.map((creator) => _CreatorListItem(
                  creator: creator,
                  onPitch: () => context.push(RouteNames.agencyPitches),
                  onView: () => context.push(RouteNames.partnerProfile, extra: creator),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatorListItem extends StatelessWidget {
  const _CreatorListItem({required this.creator, required this.onPitch, required this.onView});

  final Map<String, dynamic> creator;
  final VoidCallback onPitch;
  final VoidCallback onView;

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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BCCard(
        backgroundColor: surface,
        borderColor: outline,
        onTap: onView,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
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
                      niche is List ? (niche as List).join(', ') : niche.toString(),
                      style: AppTypography.bodyXS.copyWith(color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (tier != null) ...[
                        BCBadge(label: tier.toString().toUpperCase(), variant: BCBadgeVariant.outline),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      if (followers.isNotEmpty)
                        Text(followers, style: AppTypography.labelXS.copyWith(color: muted)),
                    ],
                  ),
                ],
              ),
            ),
            BCActionButton(
              label: 'Pitch',
              onPressed: onPitch,
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
}

class _EmptyCreatorsState extends StatelessWidget {
  const _EmptyCreatorsState({
    required this.muted,
    required this.surface,
    required this.outline,
    required this.text,
    required this.onDiscover,
  });

  final Color muted;
  final Color surface;
  final Color outline;
  final Color text;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
      ),
      child: Column(
        children: [
          Icon(Symbols.group_add_rounded, size: 48, color: AppColors.agencyDark.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.md),
          Text('No creators yet', style: AppTypography.labelLG.copyWith(color: text, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          Text('Invite creators to build your roster', style: AppTypography.bodyXS.copyWith(color: muted)),
          const SizedBox(height: AppSpacing.lg),
          BCActionButton(label: 'Discover Creators', onPressed: onDiscover),
        ],
      ),
    );
  }
}
