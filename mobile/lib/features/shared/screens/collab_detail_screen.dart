import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../chat/chat_screen.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class CollabDetailScreen extends ConsumerWidget {
  const CollabDetailScreen({super.key, required this.collabId});

  final String collabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabAsync = ref.watch(collabProvider(collabId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Collab Details', style: AppTypography.displaySM),
      ),
      body: collabAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
        error: (error, _) => BCErrorState(
          message: error.toString(),
          onRetry: () => ref.read(collabProvider(collabId).notifier).refresh(),
        ),
        data: (collab) {
          final isCompleted = collab.status == 'completed';
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xl,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            children: [
              Text(
                '${collab.brandCategory} Campaign Collab',
                style: AppTypography.displayMD,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Status: ${collab.status}',
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              BCCard(
                shadow: AppShadows.blue,
                child: const _PartyCard(
                  title: 'Brand',
                  name: 'Brand Partner',
                  handle: '@brand',
                  icon: Icons.apartment_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BCCard(
                shadow: AppShadows.pink,
                child: const _PartyCard(
                  title: 'Creator',
                  name: 'Creator Partner',
                  handle: '@creator',
                  icon: Icons.palette_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BCCard(
                shadow: AppShadows.neon,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Agreed Amount',
                            style: AppTypography.labelMD
                                .copyWith(color: AppColors.muted),
                          ),
                        ),
                        Text(
                          Formatters.currency(collab.amount),
                          style: AppTypography.displaySM,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        BCBadge(
                          label: _collabTypeLabel(collab.collabType),
                          variant: BCBadgeVariant.pink,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const BCBadge(
                          label: 'Deliverables: Reel + Story',
                          variant: BCBadgeVariant.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BCPrimaryButton.neon(
                      label: 'Open Chat ->',
                      onPressed: () => openChatDrawer(context, collabId),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    BCPrimaryButton.dark(
                      label: 'Open Milestones ->',
                      onPressed: () => context.push(
                        RouteNames.collabMilestones
                            .replaceFirst(':id', collabId),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BCCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Milestone tracker',
                        style: AppTypography.labelLG),
                    const SizedBox(height: AppSpacing.sm),
                    _MilestoneProgress(currentStep: collab.currentStep),
                  ],
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(height: AppSpacing.lg),
                BCPrimaryButton.pink(
                  label: 'Rate this collab ->',
                  onPressed: () => context.push(
                    RouteNames.collabRating.replaceFirst(':id', collabId),
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.lg),
                const BCEmptyState(
                  emoji: '⭐',
                  message: 'Rating unlocks when this collab is completed.',
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _collabTypeLabel(dynamic type) {
    final raw = type.toString().split('.').last;
    if (raw == 'barter') return 'Barter';
    if (raw == 'hybrid') return 'Hybrid';
    return 'Paid';
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.title,
    required this.name,
    required this.handle,
    required this.icon,
  });

  final String title;
  final String name;
  final String handle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Icon(icon, color: AppColors.ink),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      AppTypography.labelSM.copyWith(color: AppColors.muted)),
              const SizedBox(height: AppSpacing.xs),
              Text(name, style: AppTypography.labelLG),
              Text(handle, style: AppTypography.bodyXS),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneProgress extends StatelessWidget {
  const _MilestoneProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        final isDone = currentStep >= step;
        final isLast = index == 3;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.neon : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: AppColors.ink)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.neon : AppColors.divider,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
