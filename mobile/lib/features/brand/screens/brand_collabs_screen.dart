import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/brand_models.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

final _brandActiveCollabsProvider =
    FutureProvider<List<ActiveCollabSummary>>((ref) {
  return ref.read(brandRepositoryProvider).getActiveCollabs();
});

final _brandCompletedCollabsProvider =
    FutureProvider<List<ActiveCollabSummary>>((ref) {
  return ref.read(brandRepositoryProvider).getCompletedCollabs();
});

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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Brand Collabs', style: AppTypography.displaySM),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.neon,
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
          return BCEmptyState(
            emoji: '🤝',
            message: emptyMessage,
          );
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
          itemBuilder: (context, index) {
            final collab = collabs[index];
            return _CollabCard(collab: collab);
          },
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
      shadow: AppShadows.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  collab.creatorName,
                  style: AppTypography.labelLG,
                ),
              ),
              BCBadge(
                label: _statusLabel(collab.status),
                variant: _statusVariant(collab.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          BCBadge(
            label: collab.campaignTitle,
            variant: BCBadgeVariant.neon,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _meta(collab),
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: BCPrimaryButton.dark(
              label: 'Open Details →',
              isFullWidth: false,
              onPressed: () => context.push(
                RouteNames.collabDetail.replaceFirst(':id', collab.id),
              ),
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
  final amount = collab.agreedAmount;
  final startedAt = collab.startedAt;

  final amountCopy =
      amount != null ? Formatters.currencyFromINR(amount) : 'Amount not set';
  final startedCopy = startedAt != null
      ? 'Started ${Formatters.date(startedAt)}'
      : 'Start date pending';

  return '$amountCopy • $startedCopy';
}
