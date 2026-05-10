import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/agency_page_top_header.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class AgencyDiscoverCreatorsScreen extends ConsumerStatefulWidget {
  const AgencyDiscoverCreatorsScreen({super.key});

  @override
  ConsumerState<AgencyDiscoverCreatorsScreen> createState() => _AgencyDiscoverCreatorsScreenState();
}

class _AgencyDiscoverCreatorsScreenState extends ConsumerState<AgencyDiscoverCreatorsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedTier;
  String? _selectedPlatform;
  String? _selectedNiche;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more if available
    }
  }

  void _applyFilters() {
    Navigator.pop(context);
    ref.read(agencyDiscoveryProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(agencyDiscoveryProvider);
    final creators = discoveryState.valueOrNull?.creators ?? [];
    final hasMore = discoveryState.valueOrNull?.hasMore ?? false;
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
        title: Text('Discover Creators', style: AppTypography.displaySM.copyWith(
          color: AppColors.agencyDark, fontWeight: FontWeight.w900,
        )),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.agencyPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.14)),
              ),
              child: const Icon(Symbols.tune_rounded, color: AppColors.agencyDark, size: 20),
            ),
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BCLoadingOverlay(
        isLoading: discoveryState.isLoading && creators.isEmpty,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0,
                AppSpacing.screenPadding, AppSpacing.md,
              ),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                hint: 'Search creators...',
              ),
            ),
            if (_selectedTier != null || _selectedPlatform != null || _selectedNiche != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedTier != null)
                        _ActiveFilterChip(
                          label: 'Tier: ${_selectedTier!.toUpperCase()}',
                          onRemove: () => setState(() => _selectedTier = null),
                        ),
                      if (_selectedPlatform != null) ...[
                        if (_selectedTier != null) const SizedBox(width: AppSpacing.xs),
                        _ActiveFilterChip(
                          label: _selectedPlatform!,
                          onRemove: () => setState(() => _selectedPlatform = null),
                        ),
                      ],
                      if (_selectedNiche != null) ...[
                        if (_selectedTier != null || _selectedPlatform != null) const SizedBox(width: AppSpacing.xs),
                        _ActiveFilterChip(
                          label: _selectedNiche!,
                          onRemove: () => setState(() => _selectedNiche = null),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.agencyPrimary,
                onRefresh: () => ref.read(agencyDiscoveryProvider.notifier).refresh(),
                child: creators.isEmpty
                    ? _EmptyState(mutedColor: muted, surfaceColor: surface, outlineColor: outline, textColor: text)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, 0,
                          AppSpacing.screenPadding, AppSpacing.huge,
                        ),
                        itemCount: creators.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == creators.length) {
                            return const Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Center(child: CircularProgressIndicator(color: AppColors.agencyPrimary)),
                            );
                          }
                          final creator = creators[index];
                          return _CreatorListCard(
                            creator: creator,
                            onTap: () => _showCreatorActions(context, creator),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _FullFilterSheet(
        selectedTier: _selectedTier,
        selectedPlatform: _selectedPlatform,
        selectedNiche: _selectedNiche,
        onApply: (tier, platform, niche) {
          setState(() {
            _selectedTier = tier;
            _selectedPlatform = platform;
            _selectedNiche = niche;
          });
          Navigator.pop(ctx);
          ref.read(agencyDiscoveryProvider.notifier).refresh();
        },
      ),
    );
  }

  void _showCreatorActions(BuildContext context, Map<String, dynamic> creator) {
    final creditBalance = ref.read(agencyProfileProvider).valueOrNull?['credit_balance'] ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CreatorActionSheet(creator: creator, creditBalance: creditBalance),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged, required this.hint});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.14)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodySM,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodySM.copyWith(color: AppColors.muted),
          prefixIcon: const Icon(Symbols.search_rounded, color: AppColors.muted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.agencyPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.agencyPrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.labelXS.copyWith(color: AppColors.agencyDark, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Symbols.close_rounded, color: AppColors.agencyDark, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FullFilterSheet extends StatefulWidget {
  const _FullFilterSheet({
    required this.selectedTier,
    required this.selectedPlatform,
    required this.selectedNiche,
    required this.onApply,
  });

  final String? selectedTier;
  final String? selectedPlatform;
  final String? selectedNiche;
  final void Function(String? tier, String? platform, String? niche) onApply;

  @override
  State<_FullFilterSheet> createState() => _FullFilterSheetState();
}

class _FullFilterSheetState extends State<_FullFilterSheet> {
  String? _tier;
  String? _platform;
  String? _niche;

  final List<String> _tiers = ['nano', 'micro', 'mid', 'macro', 'mega'];
  final List<String> _platforms = ['instagram', 'youtube', 'twitter', 'tiktok'];
  final List<String> _niches = ['Fashion', 'Food', 'Fitness', 'Travel', 'Tech', 'Beauty', 'Lifestyle', 'Gaming'];

  @override
  void initState() {
    super.initState();
    _tier = widget.selectedTier;
    _platform = widget.selectedPlatform;
    _niche = widget.selectedNiche;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filter Creators', style: AppTypography.displaySM.copyWith(color: AppColors.white)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _tier = null;
                    _platform = null;
                    _niche = null;
                  }),
                  child: Text('Reset', style: AppTypography.labelMD.copyWith(color: AppColors.agencyPrimary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Text('Tier', style: AppTypography.labelLG.copyWith(color: AppColors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _tiers.map((t) => _FilterChip(
                      label: t.toUpperCase(),
                      isSelected: _tier == t,
                      onTap: () => setState(() => _tier = _tier == t ? null : t),
                    )).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Platform', style: AppTypography.labelLG.copyWith(color: AppColors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _platforms.map((p) => _FilterChip(
                      label: p[0].toUpperCase() + p.substring(1),
                      isSelected: _platform == p,
                      onTap: () => setState(() => _platform = _platform == p ? null : p),
                    )).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Niche', style: AppTypography.labelLG.copyWith(color: AppColors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _niches.map((n) => _FilterChip(
                      label: n,
                      isSelected: _niche == n,
                      onTap: () => setState(() => _niche = _niche == n ? null : n),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BCPrimaryButton.dark(
              label: 'Apply Filters',
              isFullWidth: true,
              onPressed: () => widget.onApply(_tier, _platform, _niche),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agencyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.agencyPrimary : AppColors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(label, style: AppTypography.labelSM.copyWith(
          color: isSelected ? AppColors.ink : AppColors.white,
          fontWeight: FontWeight.w700,
        )),
      ),
    );
  }
}

class _CreatorListCard extends StatelessWidget {
  const _CreatorListCard({required this.creator, required this.onTap});

  final Map<String, dynamic> creator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final firstName = creator['first_name'] ?? 'Creator';
    final avatarUrl = creator['avatar_url'];
    final niche = creator['niche'];
    final followers = _formatFollowers(creator['followers_count']);
    final tier = creator['tier'];
    final platforms = creator['platforms'] as List?;
    final bio = creator['bio'];
    final state = creator['state'];
    final city = creator['city'];

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
                  radius: 28,
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
            if (bio != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                bio.toString().length > 80 ? '${bio.toString().substring(0, 80)}...' : bio.toString(),
                style: AppTypography.bodyXS.copyWith(color: muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (platforms != null && platforms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: 4,
                children: platforms.map<Widget>((p) => _PlatformChip(platform: p.toString())).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (state != null || city != null) ...[
                  Icon(Symbols.location_on_rounded, color: muted, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    [state, city].where((e) => e != null).join(', '),
                    style: AppTypography.labelXS.copyWith(color: muted),
                  ),
                  const Spacer(),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.agencyDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pitch', style: AppTypography.labelSM.copyWith(color: AppColors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      const Icon(Symbols.send_rounded, color: AppColors.white, size: 14),
                    ],
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

class _CreatorActionSheet extends StatelessWidget {
  const _CreatorActionSheet({required this.creator, required this.creditBalance});

  final Map<String, dynamic> creator;
  final int creditBalance;

  @override
  Widget build(BuildContext context) {
    final firstName = creator['first_name'] ?? 'Creator';
    final niche = creator['niche'];
    final followers = _formatFollowers(creator['followers_count']);
    final avatarUrl = creator['avatar_url'];
    final bio = creator['bio'];

    return Padding(
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
                        niche is List ? (niche as List).join(', ') : niche.toString(),
                        style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              if (followers.isNotEmpty)
                BCBadge(label: followers, variant: BCBadgeVariant.outline),
            ],
          ),
          if (bio != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(bio.toString(), style: AppTypography.bodySM.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
          ],
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.agencyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Symbols.credit_card_rounded, color: AppColors.agencyPrimary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pitching costs 1 credit. You have $creditBalance credits.',
                    style: AppTypography.labelSM.copyWith(color: AppColors.agencyPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BCPrimaryButton.dark(
            label: 'Pitch Creator',
            isFullWidth: true,
            onPressed: creditBalance > 0
                ? () {
                    Navigator.pop(context);
                    context.push(RouteNames.agencyPitchCreator, extra: creator);
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Text('Cancel', style: AppTypography.labelMD.copyWith(color: AppColors.muted)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
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

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.agencyDark.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.12)),
      ),
      child: Text(
        platform[0].toUpperCase() + platform.substring(1),
        style: AppTypography.labelXS.copyWith(color: AppColors.agencyDark),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.textColor,
  });

  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
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
            Icon(Symbols.person_search_rounded, size: 56, color: AppColors.agencyDark.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('No creators found', style: AppTypography.labelLG.copyWith(color: textColor, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text('Try adjusting your filters or search', style: AppTypography.bodySM.copyWith(color: mutedColor)),
          ],
        ),
      ),
    );
  }
}
