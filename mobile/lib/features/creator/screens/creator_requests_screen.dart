import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../shared/widgets/creator_design_system.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/bc_portal_top_bar.dart';

class CreatorRequestsScreen extends ConsumerWidget {
  const CreatorRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 3,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 3,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: () => ref.read(requestsProvider.notifier).refresh(),
          child: requestsAsync.when(
            loading: () => const Center(child: BCAppLoader()),
            error: (error, _) => BCErrorState(
              message: error.toString(),
              onRetry: () => ref.read(requestsProvider.notifier).refresh(),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return const BCEmptyState(
                  emoji: '??',
                  message: 'No requests yet. Brands will reach out soon.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.huge,
                ),
                itemCount: requests.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(request: request);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.request});

  final CollabRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLoading = ref.watch(creatorActionsProvider).isLoading;

    return GlassPanel(
      accentColor: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.brandInitial,
                  style: AppTypography.labelMD.copyWith(color: AppColors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.brandName, style: AppTypography.labelLG),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      timeago.format(request.receivedAt),
                      style: AppTypography.bodyXS,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              BCBadge(
                label: Formatters.currency(request.budget),
                variant: BCBadgeVariant.neon,
              ),
              BCBadge(
                label: _collabTypeLabel(request.collabType),
                variant: _collabTypeVariant(request.collabType),
              ),
              BCBadge(
                label: request.status,
                variant: BCBadgeVariant.outline,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _RequestButton(
                label: 'View Campaigns',
                filled: false,
                onTap: () => context.push(RouteNames.creatorCampaigns),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RequestButton(
                label: actionLoading ? 'Please wait...' : 'Accept',
                filled: true,
                onTap: actionLoading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(creatorActionsProvider.notifier)
                              .respondToRequest(
                                requestId: request.id,
                                action: 'accept',
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request accepted.')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
              ),
              const SizedBox(width: AppSpacing.sm),
              _RequestButton(
                label: 'Reject',
                filled: false,
                onTap: actionLoading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(creatorActionsProvider.notifier)
                              .respondToRequest(
                                requestId: request.id,
                                action: 'reject',
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request rejected.')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: filled ? AppColors.neon : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Text(label, style: AppTypography.labelSM),
        ),
      ),
    );
  }
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

BCBadgeVariant _collabTypeVariant(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return BCBadgeVariant.pink;
    case CampaignCollabType.barter:
      return BCBadgeVariant.blue;
    case CampaignCollabType.hybrid:
      return BCBadgeVariant.purple;
  }
}
