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
import '../../../widgets/agency_page_layout.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_action_button.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class AgencyDiscoverScreen extends ConsumerStatefulWidget {
  const AgencyDiscoverScreen({super.key});

  @override
  ConsumerState<AgencyDiscoverScreen> createState() => _AgencyDiscoverScreenState();
}

class _AgencyDiscoverScreenState extends ConsumerState<AgencyDiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future<void>.microtask(() {
      ref.read(agencyProfileProvider);
      ref.read(agencyDiscoveryProvider);
      ref.read(agencyBrandsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final outline = theme == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(role: BCPortalRole.agency, currentIndex: 1),
body: AgencyPageLayout(
          child: BCPageSwipeArea(
            role: BCPortalRole.agency,
            currentIndex: 1,
            child: Container(
              margin: EdgeInsets.only(top: sheetTop),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(color: AppColors.agencyDark, width: 2.2)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding, 30,
                      AppSpacing.screenPadding, 0,
                    ),
                    child: Row(
                      children: [
                        Text('Discover', style: AppTypography.displaySM.copyWith(
                          color: AppColors.agencyDark, fontWeight: FontWeight.w900,
                        )),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _showFilterSheet(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.agencyPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.14)),
                            ),
                            child: const Icon(Symbols.tune_rounded, color: AppColors.agencyDark, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DefaultTabController(
                    length: 2,
                    child: Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _DiscoverCreatorsTab(onShowAll: () => context.push(RouteNames.agencyDiscoverCreators)),
                          _DiscoverBrandsTab(onShowAll: () => context.push(RouteNames.agencyDiscoverBrands)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedTier;
  String? _selectedPlatform;

  final List<String> _tiers = ['nano', 'micro', 'mid', 'macro', 'mega'];
  final List<String> _platforms = ['instagram', 'youtube', 'twitter', 'tiktok'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filters', style: AppTypography.displaySM.copyWith(color: AppColors.white)),
              const Spacer(),
              BCActionButton(
                label: 'Clear',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Tier', style: AppTypography.labelLG.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _tiers.map((tier) => _FilterChip(
              label: tier.toUpperCase(),
              isSelected: _selectedTier == tier,
              onTap: () => setState(() => _selectedTier = _selectedTier == tier ? null : tier),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Platform', style: AppTypography.labelLG.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _platforms.map((platform) => _FilterChip(
              label: platform[0].toUpperCase() + platform.substring(1),
              isSelected: _selectedPlatform == platform,
              onTap: () => setState(() => _selectedPlatform = _selectedPlatform == platform ? null : platform),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          BCPrimaryButton.dark(
            label: 'Apply Filters',
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
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

class _DiscoverCreatorsTab extends ConsumerWidget {
  const _DiscoverCreatorsTab({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryState = ref.watch(agencyDiscoveryProvider);
    final creators = discoveryState.valueOrNull?.creators ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    return BCLoadingOverlay(
      isLoading: discoveryState.isLoading,
      child: RefreshIndicator(
        color: AppColors.agencyPrimary,
        onRefresh: () => ref.read(agencyDiscoveryProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 0,
            AppSpacing.screenPadding, AppSpacing.huge,
          ),
          children: [
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text('Available Creators', style: AppTypography.labelLG.copyWith(color: text)),
                ),
                GestureDetector(
                  onTap: onShowAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: outline),
                    ),
                    child: Text('See All', style: AppTypography.labelSM.copyWith(
                      color: AppColors.agencyDark, fontWeight: FontWeight.w800,
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (creators.isEmpty)
              _EmptyState(
                icon: Symbols.person_search_rounded,
                title: 'No creators found',
                subtitle: 'Check back later for new creators',
                mutedColor: muted,
                surfaceColor: surface,
                outlineColor: outline,
                textColor: text,
              )
            else
              ...creators.take(5).map((creator) => _CreatorCard(
                creator: creator,
                onTap: () => _showCreatorActions(context, ref, creator),
              )),
          ],
        ),
      ),
    );
  }

  void _showCreatorActions(BuildContext context, WidgetRef ref, Map<String, dynamic> creator) {
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
          const SizedBox(height: AppSpacing.xl),
          if (creator['bio'] != null) ...[
            Text(creator['bio'].toString().length > 100
                ? '${creator['bio'].toString().substring(0, 100)}...'
                : creator['bio'].toString(),
                style: AppTypography.bodySM.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
            const SizedBox(height: AppSpacing.md),
          ],
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

class _DiscoverBrandsTab extends ConsumerWidget {
  const _DiscoverBrandsTab({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsState = ref.watch(agencyBrandsProvider);
    final brands = brandsState.valueOrNull?.brands ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    return BCLoadingOverlay(
      isLoading: brandsState.isLoading,
      child: RefreshIndicator(
        color: AppColors.agencyPrimary,
        onRefresh: () => ref.read(agencyBrandsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, AppSpacing.md,
            AppSpacing.screenPadding, AppSpacing.huge,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Active Brands', style: AppTypography.labelLG.copyWith(color: text)),
                ),
                GestureDetector(
                  onTap: onShowAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: outline),
                    ),
                    child: Text('See All', style: AppTypography.labelSM.copyWith(
                      color: AppColors.agencyDark, fontWeight: FontWeight.w800,
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (brands.isEmpty)
              _EmptyState(
                icon: Symbols.storefront_rounded,
                title: 'No brands found',
                subtitle: 'Check back later for new brands to pitch',
                mutedColor: muted,
                surfaceColor: surface,
                outlineColor: outline,
                textColor: text,
              )
            else
              ...brands.take(5).map((brand) => _BrandCard(
                brand: brand,
                onTap: () => _showBrandActions(context, ref, brand),
              )),
          ],
        ),
      ),
    );
  }

  void _showBrandActions(BuildContext context, WidgetRef ref, Map<String, dynamic> brand) {
    final creditBalance = ref.read(agencyProfileProvider).valueOrNull?['credit_balance'] ?? 0;
    final roster = ref.read(agencyRosterProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BrandActionSheet(brand: brand, creditBalance: creditBalance, hasRoster: roster.isNotEmpty),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand, required this.onTap});

  final Map<String, dynamic> brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final brandName = brand['brand_name'] ?? 'Brand';
    final logoUrl = brand['logo_url'];
    final category = brand['brand_category'];
    final tagline = brand['brand_tagline'];
    final activeCampaigns = brand['active_campaigns'] ?? 0;
    final size = brand['size'];
    final location = [brand['city'], brand['state']].where((e) => e != null).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: outline),
            boxShadow: AppShadows.soft(context),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.pink.withValues(alpha: 0.15),
                    backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                    child: logoUrl == null ? const Icon(Icons.store, color: AppColors.pink) : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(brandName, style: AppTypography.labelLG.copyWith(color: text)),
                        if (category != null)
                          Text(category, style: AppTypography.bodyXS.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (activeCampaigns > 0)
                    BCBadge(label: '$activeCampaigns active', variant: BCBadgeVariant.pink),
                ],
              ),
              if (tagline != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(tagline, style: AppTypography.bodyXS.copyWith(color: muted), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (size != null) ...[
                    BCBadge(label: size.toString().toUpperCase(), variant: BCBadgeVariant.outline),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (location.isNotEmpty) ...[
                    Icon(Symbols.location_on_rounded, size: 12, color: muted),
                    const SizedBox(width: 2),
                    Text(location, style: AppTypography.labelXS.copyWith(color: muted)),
                  ],
                  const Spacer(),
                  const Icon(Symbols.arrow_forward_rounded, color: AppColors.agencyDark, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandActionSheet extends StatelessWidget {
  const _BrandActionSheet({required this.brand, required this.creditBalance, required this.hasRoster});

  final Map<String, dynamic> brand;
  final int creditBalance;
  final bool hasRoster;

  @override
  Widget build(BuildContext context) {
    final brandName = brand['brand_name'] ?? 'Brand';
    final logoUrl = brand['logo_url'];
    final category = brand['brand_category'];
    final tagline = brand['brand_tagline'];

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
                backgroundColor: AppColors.pink.withValues(alpha: 0.2),
                backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                child: logoUrl == null ? const Icon(Icons.store, color: AppColors.pink) : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brandName, style: AppTypography.displaySM.copyWith(color: AppColors.white)),
                    if (category != null)
                      Text(category, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          if (tagline != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(tagline, style: AppTypography.bodySM.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
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
          if (!hasRoster)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.info_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Add creators to your roster first, then pitch them to this brand.',
                      style: AppTypography.labelSM.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          if (!hasRoster) const SizedBox(height: AppSpacing.md),
          BCPrimaryButton.dark(
            label: hasRoster ? 'Pitch with Creator' : 'Discover Creators',
            isFullWidth: true,
            onPressed: hasRoster && creditBalance > 0
                ? () {
                    Navigator.pop(context);
                    context.push(RouteNames.agencyPitchBrand, extra: brand);
                  }
                : () {
                    Navigator.pop(context);
                    context.push(RouteNames.agencyDiscover);
                  },
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
}

class _CreatorCard extends StatelessWidget {
  const _CreatorCard({required this.creator, required this.onTap});

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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: outline),
            boxShadow: AppShadows.soft(context),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
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
                          child: BCBadge(
                            label: tier.toString().toUpperCase(),
                            variant: _getTierVariant(tier.toString()),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (platforms != null && platforms.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: platforms.map<Widget>((p) => _PlatformChip(platform: p.toString())).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Symbols.arrow_forward_rounded, color: AppColors.agencyDark, size: 16),
                  const SizedBox(width: 4),
                  Text('Pitch', style: AppTypography.labelSM.copyWith(color: AppColors.agencyDark, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
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
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mutedColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color mutedColor;
  final Color surfaceColor;
  final Color outlineColor;
  final Color textColor;

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
          Icon(icon, size: 48, color: AppColors.agencyDark.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.labelLG.copyWith(color: textColor, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodySM.copyWith(color: mutedColor)),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface : AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
