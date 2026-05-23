import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../shared/widgets/creator_design_system.dart';

class CreatorCollabDetailScreen extends ConsumerWidget {
  const CreatorCollabDetailScreen({super.key, required this.collabId});

  final String collabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabAsync = ref.watch(collabProvider(collabId));

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightBg,
                    Color(0xFFD8E6C6),
                    Color(0xFFC4D4AE),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: -54,
            child: _AmbientGlow(
              size: 164,
              color: AppColors.neon.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 164,
            left: -42,
            child: _AmbientGlow(
              size: 126,
              color: AppColors.pink.withValues(alpha: 0.22),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: collabAsync.when(
                loading: () => const Center(child: BCAppLoader()),
                error: (error, _) => BCErrorState(
                  message: error.toString(),
                  onRetry: () => ref.read(collabProvider(collabId).notifier).refresh(),
                ),
                data: (collab) {
                  final isCompleted = collab.status == 'completed';
                  return ListView(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.screenPadding,
                      right: AppSpacing.screenPadding,
                      top: 14,
                      bottom: AppSpacing.huge,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
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
                                onPressed: () => context.pop(),
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
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Share link copied.')),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.creatorDark.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: const Icon(
                                  Symbols.share_rounded,
                                  color: AppColors.creatorDark,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      GlassPanel(
                        accentColor: AppColors.creatorDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
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
                                    collab.brandCategory.isNotEmpty 
                                        ? collab.brandCategory[0].toUpperCase() 
                                        : 'B',
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
                                        style: AppTypography.displaySM.copyWith(
                                          color: AppColors.creatorDark,
                                          fontWeight: FontWeight.w900,
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
                              ],
                            ),
                            if (collab.createdAt != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Started ${Formatters.timeAgo(collab.createdAt!)}',
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      GlassPanel(
                        accentColor: AppColors.creatorDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Agreed Amount',
                                  style: AppTypography.labelLG.copyWith(
                                    color: AppColors.creatorDark,
                                  ),
                                ),
                                Text(
                                  Formatters.currencyFromINR(collab.agreedAmountPaise),
                                  style: AppTypography.displayMD.copyWith(
                                    color: AppColors.creatorDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Opening chat...')),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.creatorDark,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Symbols.chat_rounded,
                                            color: AppColors.neon,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'Chat with Brand',
                                            style: AppTypography.labelMD.copyWith(
                                              color: AppColors.neon,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            GestureDetector(
                              onTap: () => context.push('/collabs/$collabId/milestones'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  border: Border.all(
                                    color: AppColors.creatorDark,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Symbols.checklist_rounded,
                                      color: AppColors.creatorDark,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'View Milestones',
                                      style: AppTypography.labelMD.copyWith(
                                        color: AppColors.creatorDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Progress',
                        style: AppTypography.displaySM.copyWith(
                          color: AppColors.creatorDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassPanel(
                        accentColor: AppColors.creatorDark,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _MilestoneStep(
                                  step: 1,
                                  label: 'Brief',
                                  isCompleted: collab.currentStep > 1,
                                  isActive: collab.currentStep == 1,
                                ),
                                _Connector(isCompleted: collab.currentStep > 1),
                                _MilestoneStep(
                                  step: 2,
                                  label: 'Draft',
                                  isCompleted: collab.currentStep > 2,
                                  isActive: collab.currentStep == 2,
                                ),
                                _Connector(isCompleted: collab.currentStep > 2),
                                _MilestoneStep(
                                  step: 3,
                                  label: 'Content',
                                  isCompleted: collab.currentStep > 3,
                                  isActive: collab.currentStep == 3,
                                ),
                                _Connector(isCompleted: collab.currentStep > 3),
                                _MilestoneStep(
                                  step: 4,
                                  label: 'Done',
                                  isCompleted: collab.status == 'completed',
                                  isActive: collab.currentStep == 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted && collab.rating != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        GlassPanel(
                          accentColor: AppColors.neon,
                          child: Row(
                            children: [
                              const Icon(
                                Symbols.star_rounded,
                                color: AppColors.creatorDark,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Rating',
                                    style: AppTypography.labelSM.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (collab.rating ?? 0) 
                                            ? Icons.star_rounded 
                                            : Icons.star_outline_rounded,
                                        color: AppColors.creatorDark,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
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
          width: 28,
          height: 28,
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
                  size: 16,
                )
              : Text(
                  '$step',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.creatorDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        const SizedBox(height: 6),
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

class _Connector extends StatelessWidget {
  const _Connector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      color: isCompleted 
          ? AppColors.creatorDark 
          : AppColors.creatorDark.withValues(alpha: 0.3),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
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