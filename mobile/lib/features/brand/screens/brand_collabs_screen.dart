import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/brand_page_top_header.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

final _brandActiveCollabsProvider = FutureProvider<List<ActiveCollabSummary>>(
  (ref) => ref.read(brandRepositoryProvider).getActiveCollabs(),
);

final _brandCompletedCollabsProvider =
    FutureProvider<List<ActiveCollabSummary>>(
  (ref) => ref.read(brandRepositoryProvider).getCompletedCollabs(),
);

class BrandCollabsScreen extends ConsumerWidget {
  const BrandCollabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(_brandActiveCollabsProvider);
    final completedAsync = ref.watch(_brandCompletedCollabsProvider);

    Future<void> refresh() async {
      ref.invalidate(_brandActiveCollabsProvider);
      ref.invalidate(_brandCompletedCollabsProvider);
      await Future.wait([
        ref.read(_brandActiveCollabsProvider.future),
        ref.read(_brandCompletedCollabsProvider.future),
      ]);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: const BCBottomNav(
          role: BCPortalRole.brand,
          currentIndex: 1,
        ),
        body: BCPageSwipeArea(
          role: BCPortalRole.brand,
          currentIndex: 1,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.lightBg),
                ),
              ),
              Positioned(
                top: -46,
                right: -32,
                child: _GlowOrb(
                  size: 136,
                  color: AppColors.brandPrimary.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                top: 220,
                left: -44,
                child: _GlowOrb(
                  size: 112,
                  color: AppColors.brandDark.withValues(alpha: 0.08),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      MediaQuery.of(context).padding.top + 14,
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                    ),
                    child: const BrandPageTopHeader(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.brandDark.withValues(alpha: 0.14),
                        ),
                      ),
                      child: const TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: EdgeInsets.all(4),
                        indicator: BoxDecoration(
                          color: AppColors.brandDark,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        labelColor: AppColors.white,
                        unselectedLabelColor: AppColors.brandDark,
                        tabs: [
                          Tab(text: 'Active'),
                          Tab(text: 'Completed'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.brandPrimary,
                      onRefresh: refresh,
                      child: TabBarView(
                        children: [
                          _CollabsList(
                            asyncValue: activeAsync,
                            emptyMessage:
                                'No active collabs yet. Accept a bid or request to start one.',
                          ),
                          _CollabsList(
                            asyncValue: completedAsync,
                            emptyMessage: 'No completed collabs yet.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollabsList extends StatelessWidget {
  const _CollabsList({
    required this.asyncValue,
    required this.emptyMessage,
  });

  final AsyncValue<List<ActiveCollabSummary>> asyncValue;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => BCErrorState(message: error.toString()),
      data: (collabs) {
        if (collabs.isEmpty) {
          return BCEmptyState(emoji: '🤝', message: emptyMessage);
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            AppSpacing.huge,
          ),
          itemCount: collabs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _CollabCard(collab: collabs[index]),
        );
      },
    );
  }
}

class _CollabCard extends StatelessWidget {
  const _CollabCard({required this.collab});

  final ActiveCollabSummary collab;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.neon,
      borderColor: AppColors.lightBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(collab.creatorName, style: AppTypography.labelLG),
              ),
              BCBadge(
                label: _statusLabel(collab.status),
                variant: _statusVariant(collab.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          BCBadge(label: collab.campaignTitle, variant: BCBadgeVariant.neon),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _meta(collab),
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: BCPrimaryButton.dark(
              label: 'Open Details ->',
              isFullWidth: false,
              onPressed: () =>
                  context.push(RouteNames.collabDetail.replaceFirst(':id', collab.id)),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return 'In Progress';
    case 'completed':
      return 'Completed';
    case 'active':
      return 'Active';
    default:
      return 'Live';
  }
}

BCBadgeVariant _statusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return BCBadgeVariant.blue;
    case 'completed':
      return BCBadgeVariant.purple;
    case 'active':
      return BCBadgeVariant.neon;
    default:
      return BCBadgeVariant.outline;
  }
}

String _meta(ActiveCollabSummary collab) {
  final amountCopy = collab.agreedAmount != null
      ? Formatters.currencyFromINR(collab.agreedAmount!)
      : 'Amount not set';
  final startedCopy = collab.startedAt != null
      ? 'Started ${Formatters.date(collab.startedAt!)}'
      : 'Start date pending';
  return '$amountCopy | $startedCopy';
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
            ),
          ],
        ),
      ),
    );
  }
}

