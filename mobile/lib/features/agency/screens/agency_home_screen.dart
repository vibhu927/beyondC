import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencyHomeScreen extends ConsumerStatefulWidget {
  const AgencyHomeScreen({super.key});

  @override
  ConsumerState<AgencyHomeScreen> createState() => _AgencyHomeScreenState();
}

class _AgencyHomeScreenState extends ConsumerState<AgencyHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(agencyProfileProvider.future);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(agencyProfileProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final agencyState = ref.watch(agencyProfileProvider);

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(role: BCPortalRole.agency, currentIndex: 0),
      body: BCLoadingOverlay(
        isLoading: agencyState.isLoading,
        child: RefreshIndicator(
          color: AppColors.blue,
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GreetingSection(agencyState: agencyState.valueOrNull),
                    const SizedBox(height: AppSpacing.lg),
                    _QuickActions(),
                    const SizedBox(height: AppSpacing.lg),
                    _PendingActions(),
                    const SizedBox(height: AppSpacing.lg),
                    _PartneredCreatorsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _RecentActivitySection(),
                    const SizedBox(height: AppSpacing.huge),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({this.agencyState, super.key});
  final Map<String, dynamic>? agencyState;

  @override
  Widget build(BuildContext context) {
    final name = agencyState != null ? (agencyState!['agency_name'] ?? 'Agency') : 'Agency';
    final credits = agencyState != null ? (agencyState!['credit_balance']?.toString() ?? '0') : '0';
    final partners = agencyState != null ? (agencyState!['total_partnered_creators']?.toString() ?? '0') : '0';

    return BCCard(
      shadow: AppShadows.blue,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $name', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.xs),
                Row(children: [
                  BCBadge(label: '$credits credits', variant: BCBadgeVariant.blue),
                  const SizedBox(width: AppSpacing.sm),
                  BCBadge(label: '$partners partners', variant: BCBadgeVariant.outline),
                ]),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.business, size: 48, color: AppColors.blue),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - AppSpacing.md) / 2,
          child: _ActionCard(
            emoji: '🔍',
            title: 'Find Creators',
            subtitle: 'Browse and invite creators',
            shadow: AppShadows.blue,
            onTap: () => context.push(RouteNames.agencyCreators),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - AppSpacing.md) / 2,
          child: _ActionCard(
            emoji: '📣',
            title: 'Find Brands',
            subtitle: 'Pitch brands directly',
            shadow: AppShadows.blue,
            onTap: () => context.push(RouteNames.agencyDiscover),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - AppSpacing.md) / 2,
          child: _ActionCard(
            emoji: '✉️',
            title: 'Pitch a Brand',
            subtitle: 'Create a new pitch',
            shadow: AppShadows.blue,
            onTap: () => context.push(RouteNames.agencyPitches),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - AppSpacing.md) / 2,
          child: _ActionCard(
            emoji: '👥',
            title: 'Manage Roster',
            subtitle: 'Partnered creators',
            shadow: AppShadows.blue,
            onTap: () => context.push(RouteNames.agencyRoster),
          ),
        ),
      ],
    );
  }
}

class _PendingActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const BCCard(child: SizedBox(height: 72, child: Center(child: Text('Pending Actions placeholder'))));
  }
}

class _PartneredCreatorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Partnered Creators', style: AppTypography.displaySM)),
            TextButton(onPressed: () => context.push(RouteNames.agencyRoster), child: Text('See all →')),
          ],
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            itemBuilder: (_, i) => SizedBox(width: 200, child: BCCard(child: Center(child: Text('Creator ${i + 1}')))),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemCount: 5,
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Recent Activity', style: AppTypography.displaySM), const SizedBox(height: AppSpacing.md), const BCCard(child: SizedBox(height: 120, child: Center(child: Text('Activity feed placeholder'))))]);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.emoji, required this.title, required this.subtitle, required this.shadow, required this.onTap});

  final String emoji;
  final String title;
  final String subtitle;
  final List<BoxShadow> shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BCCard(shadow: shadow, onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emoji, style: const TextStyle(fontSize: 28)), const SizedBox(height: AppSpacing.md), Text(title, style: AppTypography.labelLG), const SizedBox(height: AppSpacing.xs), Text(subtitle, style: AppTypography.bodyXS)]));
  }
}
