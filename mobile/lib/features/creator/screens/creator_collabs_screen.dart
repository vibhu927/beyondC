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
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/creator_page_top_header.dart';

class CreatorCollabsScreen extends ConsumerWidget {
  const CreatorCollabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabsAsync = ref.watch(creatorCollabsProvider);
    final navClearance = MediaQuery.of(context).padding.bottom + 84;
    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 2,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
        currentIndex: 2,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightBg,
                      Color(0xFFE1EBCF),
                      Color(0xFFD2DEBF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 28,
              right: -54,
              child: AmbientGlow(
                size: 164,
                color: AppColors.neon.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              top: 164,
              left: -42,
              child: AmbientGlow(
                size: 126,
                color: AppColors.pink.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: topInset,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              child: const CreatorPageTopHeader(),
            ),
            Positioned.fill(
              child: RefreshIndicator(
                color: AppColors.neon,
                onRefresh: () => ref.read(creatorCollabsProvider.notifier).refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    0,
                    sheetTop,
                    0,
                    0,
                  ),
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.lightBg,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.creatorDark,
                            width: 2.2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          AppSpacing.lg,
                          AppSpacing.screenPadding,
                          AppSpacing.xl + navClearance,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Collabs',
                              style: AppTypography.displaySM.copyWith(
                                color: AppColors.creatorDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Track and manage your collaborations.',
                              style: AppTypography.bodySM.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            collabsAsync.when(
                              loading: () => Column(
                                children: List.generate(
                                  3,
                                  (index) => const Padding(
                                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                                    child: SizedBox(
                                      height: 180,
                                      child: _CollabCardSkeleton(),
                                    ),
                                  ),
                                ),
                              ),
                              error: (error, _) => BCErrorState(
                                message: error.toString(),
                                onRetry: () => ref.read(creatorCollabsProvider.notifier).refresh(),
                              ),
                              data: (collabs) {
                                if (collabs.isEmpty) {
                                  return const BCEmptyState(
                                    emoji: '📋',
                                    message:
                                        'No active collabs yet. Start bidding on campaigns.',
                                  );
                                }
                                return Column(
                                  children: collabs.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final collab = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == collabs.length - 1
                                            ? 0
                                            : AppSpacing.md,
                                      ),
                                      child: _CollabCard(collab: collab),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _CollabCardSkeleton extends StatelessWidget {
  const _CollabCardSkeleton();

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
                child: Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.lightBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(4, (index) {
              return Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.sm),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightBorder, width: 2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 36,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.creatorDark,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

