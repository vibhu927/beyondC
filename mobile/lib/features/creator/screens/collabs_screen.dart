import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../shared/widgets/creator_design_system.dart';

class CreatorCollabsScreen extends ConsumerWidget {
  const CreatorCollabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(creatorHomeProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightBg,
                    const Color(0xFFD8E6C6),
                    const Color(0xFFC4D4AE),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: -54,
            child: AmbientGlow(
              size: 164,
              color: AppColors.neon.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 164,
            left: -42,
            child: AmbientGlow(
              size: 126,
              color: AppColors.pink.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.creatorDark.withValues(alpha: 0.14),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.creatorDark,
                      size: 22,
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.creatorDark.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Icon(
                    Symbols.group_rounded,
                    color: AppColors.creatorDark,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 84),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    child: Text(
                      'Your Active Collabs',
                      style: AppTypography.displaySM.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: homeAsync.when(
                      loading: () => const Center(child: BCAppLoader()),
                      error: (error, _) => BCErrorState(
                        message: error.toString(),
                        onRetry: () => ref.read(creatorHomeProvider.notifier).refresh(),
                      ),
                      data: (home) {
                        final activeCollabs = home.activeCollabs
                            .where((c) => c.status != 'completed' && c.status != 'cancelled')
                            .toList();
                        if (activeCollabs.isEmpty) {
                          return const BCEmptyState(
                            message: 'No Active Collabs\nYour brand collaborations will appear here',
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                          itemCount: activeCollabs.length,
                          itemBuilder: (context, index) {
                            final collab = activeCollabs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _CollabCard(collab: collab),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollabCard extends StatelessWidget {
  const _CollabCard({required this.collab});

  final Collab collab;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        RouteNames.collabDetail.replaceFirst(':id', collab.id),
      ),
      child: GlassPanel(
        accentColor: AppColors.creatorDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neon.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.creatorDark,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    collab.brandCategory.isNotEmpty ? collab.brandCategory[0].toUpperCase() : 'B',
                    style: AppTypography.labelLG.copyWith(
                      color: AppColors.creatorDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${collab.brandCategory} Campaign',
                        style: AppTypography.labelLG.copyWith(
                          color: AppColors.creatorDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          BCBadge(
                            label: _collabTypeLabel(collab.collabType),
                            variant: BCBadgeVariant.neon,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          BCBadge(
                            label: _statusLabel(collab.status),
                            variant: _statusVariant(collab.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.creatorDark,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MilestoneStep(
                    step: 1,
                    label: 'Brief',
                    isCompleted: collab.currentStep > 1,
                    isActive: collab.currentStep == 1,
                  ),
                  Container(
                    width: 20,
                    height: 2,
                    color: AppColors.creatorDark.withValues(alpha: 0.3),
                  ),
                  _MilestoneStep(
                    step: 2,
                    label: 'Draft',
                    isCompleted: collab.currentStep > 2,
                    isActive: collab.currentStep == 2,
                  ),
                  Container(
                    width: 20,
                    height: 2,
                    color: AppColors.creatorDark.withValues(alpha: 0.3),
                  ),
                  _MilestoneStep(
                    step: 3,
                    label: 'Post',
                    isCompleted: collab.currentStep > 3,
                    isActive: collab.currentStep == 3,
                  ),
                  Container(
                    width: 20,
                    height: 2,
                    color: AppColors.creatorDark.withValues(alpha: 0.3),
                  ),
                  _MilestoneStep(
                    step: 4,
                    label: 'Done',
                    isCompleted: collab.status == 'completed',
                    isActive: collab.currentStep == 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${Formatters.currencyFromINR(collab.agreedAmountPaise ~/ 100)}',
                  style: AppTypography.displaySM.copyWith(
                    color: AppColors.creatorDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creatorDark,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'View Details',
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  BCBadgeVariant _statusVariant(String status) {
    switch (status) {
      case 'in_progress':
        return BCBadgeVariant.neon;
      case 'completed':
        return BCBadgeVariant.success;
      case 'cancelled':
        return BCBadgeVariant.error;
      case 'pending':
        return BCBadgeVariant.warning;
      default:
        return BCBadgeVariant.outline;
    }
  }
}

class _MilestoneStep extends StatelessWidget {
  const _MilestoneStep({
    required this.step,
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  final int step;
  final String label;
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? AppColors.creatorDark : AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.creatorDark,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(
                  Icons.check,
                  color: isActive ? AppColors.neon : AppColors.white,
                  size: 14,
                )
              : Text(
                  '$step',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.creatorDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodyXS.copyWith(
            color: isActive ? AppColors.creatorDark : AppColors.muted,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    super.key,
    required this.size,
    required this.color,
  });

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
              blurRadius: size * 0.52,
              spreadRadius: size * 0.18,
            ),
          ],
        ),
      ),
    );
  }
}
