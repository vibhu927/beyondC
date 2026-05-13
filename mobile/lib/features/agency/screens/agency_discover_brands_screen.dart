import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class AgencyDiscoverBrandsScreen extends ConsumerStatefulWidget {
  const AgencyDiscoverBrandsScreen({super.key});

  @override
  ConsumerState<AgencyDiscoverBrandsScreen> createState() => _AgencyDiscoverBrandsScreenState();
}

class _AgencyDiscoverBrandsScreenState extends ConsumerState<AgencyDiscoverBrandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Discover Brands', style: AppTypography.displaySM.copyWith(
          color: AppColors.agencyDark, fontWeight: FontWeight.w900,
        )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 0,
              AppSpacing.screenPadding, AppSpacing.md,
            ),
            child: _SearchBar(
              controller: _searchController,
              hint: 'Search brands...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0,
                AppSpacing.screenPadding, AppSpacing.huge,
              ),
              children: [
                Row(
                  children: [
                    Text('Active Brands', style: AppTypography.labelLG.copyWith(color: text)),
                    const Spacer(),
                    const BCBadge(label: 'Coming Soon', variant: BCBadgeVariant.warning),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _BrandDiscoveryCard(
                  title: 'Find Brands for Your Roster',
                  subtitle: 'Browse brands actively looking for creators. Pitch them with your partnered creators.',
                  icon: Symbols.storefront_rounded,
                  badge: 'New',
                  onTap: () {
                    _showBrandDiscoverySheet(context);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('How it works', style: AppTypography.labelMD.copyWith(color: text)),
                const SizedBox(height: AppSpacing.md),
                _HowItWorksStep(
                  number: 1,
                  title: 'Browse Brands',
                  description: 'Explore brands that match your creators\' niches and audience.',
                  muted: muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                _HowItWorksStep(
                  number: 2,
                  title: 'Select a Creator',
                  description: 'Choose from your roster the best fit for the brand\'s campaign.',
                  muted: muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                _HowItWorksStep(
                  number: 3,
                  title: 'Send a Pitch',
                  description: 'Craft a personalized pitch. Costs 1 credit per pitch.',
                  muted: muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBrandDiscoverySheet(BuildContext context) {
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
                const Icon(Symbols.auto_awesome_rounded, color: AppColors.agencyPrimary, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text('Brand Discovery', style: AppTypography.displaySM.copyWith(color: AppColors.white)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Brand discovery will be available once brands start joining the platform. '
              'You\'ll be notified when brands are looking for creators from your niche.',
              style: AppTypography.bodySM.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: AppSpacing.xl),
            BCPrimaryButton.dark(
              label: 'Got It',
              isFullWidth: true,
              onPressed: () => Navigator.pop(ctx),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.hint, required this.onChanged});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

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

class _BrandDiscoveryCard extends StatelessWidget {
  const _BrandDiscoveryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

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
              AppColors.agencyPrimary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.agencyDark.withValues(alpha: 0.2), width: 1.2),
          boxShadow: [BoxShadow(color: AppColors.agencyDark.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.agencyPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: AppColors.agencyDark, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge, style: AppTypography.labelXS.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.labelLG.copyWith(color: AppColors.agencyDark, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.agencyDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Browse', style: AppTypography.labelSM.copyWith(color: AppColors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      const Icon(Symbols.arrow_forward_rounded, color: AppColors.white, size: 14),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Symbols.arrow_forward_rounded, color: AppColors.agencyDark, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({required this.number, required this.title, required this.description, required this.muted});

  final int number;
  final String title;
  final String description;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;

    return BCCard(
      backgroundColor: surface,
      borderColor: outline,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.agencyPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: AppTypography.labelMD.copyWith(color: AppColors.agencyDark, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMD.copyWith(color: text)),
                Text(description, style: AppTypography.bodyXS.copyWith(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
