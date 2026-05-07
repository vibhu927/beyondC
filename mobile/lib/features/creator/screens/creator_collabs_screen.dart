import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../shared/widgets/creator_design_system.dart';
import '../../chat/chat_screen.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/bc_portal_top_bar.dart';

class CreatorCollabsScreen extends ConsumerWidget {
  const CreatorCollabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabsAsync = ref.watch(creatorCollabsProvider);

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 2,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 2,
        child: RefreshIndicator(
          color: AppColors.neon,
          onRefresh: () => ref.read(creatorCollabsProvider.notifier).refresh(),
          child: collabsAsync.when(
            loading: () => const Center(child: BCAppLoader()),
            error: (error, _) => BCErrorState(
              message: error.toString(),
              onRetry: () => ref.read(creatorCollabsProvider.notifier).refresh(),
            ),
            data: (collabs) {
              if (collabs.isEmpty) {
                return const BCEmptyState(
                  emoji: '??',
                  message: 'No active collabs yet. Start bidding on campaigns.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.huge,
                ),
                itemCount: collabs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _CollabCard(collab: collabs[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CollabCard extends StatelessWidget {
  const _CollabCard({required this.collab});

  final Collab collab;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: AppColors.neon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${collab.brandCategory} collab',
                  style: AppTypography.labelLG,
                ),
              ),
              Text(
                Formatters.currency(collab.amount),
                style: AppTypography.displaySM,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              BCBadge(
                label: _statusPretty(collab.status),
                variant: _statusVariant(collab.status),
              ),
              BCBadge(
                label: _collabTypeLabel(collab.collabType),
                variant: BCBadgeVariant.outline,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Brief  ·  Draft  ·  Approved  ·  Posted',
            style: AppTypography.bodyXS,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(4, (index) {
              final step = index + 1;
              final isCurrent = collab.currentStep == step;
              final isDone = collab.currentStep > step;
              return Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.sm),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.neon
                        : isDone
                            ? AppColors.ink
                            : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: BCPrimaryButton.dark(
              label: 'Open Chat ?',
              isFullWidth: false,
              onPressed: () => openChatDrawer(context, collab.id),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusPretty(String status) {
  final label = status.toLowerCase().replaceAll('_', ' ');
  if (label.isEmpty) return 'Unknown';
  return '${label[0].toUpperCase()}${label.substring(1)}';
}

BCBadgeVariant _statusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return BCBadgeVariant.success;
    case 'in_progress':
      return BCBadgeVariant.blue;
    case 'completed':
      return BCBadgeVariant.purple;
    case 'rejected':
      return BCBadgeVariant.error;
    default:
      return BCBadgeVariant.outline;
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


