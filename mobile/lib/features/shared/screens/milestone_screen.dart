import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  String? _submittingStep;

  static const List<_MilestoneStep> _steps = <_MilestoneStep>[
    _MilestoneStep(
      key: 'brief_shared',
      title: 'Brief Shared',
      description: 'Brand shares the final campaign brief and expectations.',
      responsibleRole: 'brand',
      actionLabel: 'Mark Brief as Shared ✓',
    ),
    _MilestoneStep(
      key: 'draft_submitted',
      title: 'Draft Submitted',
      description: 'Creator submits first draft for review.',
      responsibleRole: 'creator',
      actionLabel: 'Submit Draft ✓',
    ),
    _MilestoneStep(
      key: 'draft_approved',
      title: 'Draft Approved',
      description: 'Brand approves the draft and asks to post.',
      responsibleRole: 'brand',
      actionLabel: 'Approve Draft ✓',
    ),
    _MilestoneStep(
      key: 'content_posted',
      title: 'Content Posted',
      description: 'Creator publishes the final content.',
      responsibleRole: 'creator',
      actionLabel: 'Mark as Posted ✓',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role =
        ref.watch(authProvider.select((state) => state.role)) ?? 'creator';
    final collabAsync = ref.watch(collabProvider(widget.collabId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Milestones', style: AppTypography.displaySM),
      ),
      body: collabAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
        error: (error, _) => BCErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.read(collabProvider(widget.collabId).notifier).refresh(),
        ),
        data: (collab) {
          final currentStep =
              _currentStep(collab.milestoneStatus, collab.status);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              final stepNumber = index + 1;

              final isCompleted = stepNumber < currentStep ||
                  (stepNumber == 4 && collab.status == 'completed');
              final isCurrent =
                  stepNumber == currentStep && collab.status != 'completed';
              final isFuture = stepNumber > currentStep;

              final canAct = isCurrent && step.responsibleRole == role;
              final isSubmitting = _submittingStep == step.key;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Column(
                      children: [
                        _StepIndicator(
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          isFuture: isFuture,
                          pulse: _pulseController,
                        ),
                        if (index != _steps.length - 1)
                          Container(
                            width: 2,
                            height: 86,
                            color: isCompleted
                                ? AppColors.neon
                                : AppColors.divider,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _steps.length - 1 ? 0 : AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: AppTypography.labelLG),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            step.description,
                            style: AppTypography.bodySM
                                .copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BCBadge(
                            label: step.responsibleRole == 'creator'
                                ? 'Creator action'
                                : 'Brand action',
                            variant: step.responsibleRole == 'creator'
                                ? BCBadgeVariant.neon
                                : BCBadgeVariant.pink,
                          ),
                          if (isCompleted) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _completedLabel(collab, stepNumber),
                              style: AppTypography.bodyXS,
                            ),
                          ],
                          if (canAct) ...[
                            const SizedBox(height: AppSpacing.md),
                            BCPrimaryButton.neon(
                              label: step.actionLabel,
                              isLoading: isSubmitting,
                              onPressed: isSubmitting
                                  ? null
                                  : () => _markMilestone(step.key),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  int _currentStep(String? milestoneStatus, String status) {
    if (status == 'completed') return 4;

    switch (milestoneStatus) {
      case 'draft_submitted':
        return 2;
      case 'draft_approved':
        return 3;
      case 'content_posted':
        return 4;
      default:
        return 1;
    }
  }

  String _completedLabel(dynamic collab, int stepNumber) {
    final base = stepNumber == 4 && collab.completedAt != null
        ? collab.completedAt as DateTime
        : (collab.createdAt as DateTime?);

    if (base == null) return 'Completed';
    return 'Completed on ${Formatters.dateTime(base)}';
  }

  Future<void> _markMilestone(String milestone) async {
    setState(() => _submittingStep = milestone);

    try {
      await ref
          .read(collabProvider(widget.collabId).notifier)
          .updateMilestone(milestone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Milestone updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingStep = null);
      }
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.pulse,
  });

  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.neon : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isFuture ? AppColors.divider : AppColors.ink,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 14, color: AppColors.ink)
          : null,
    );

    if (!isCurrent) return child;

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.08).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }
}

class _MilestoneStep {
  const _MilestoneStep({
    required this.key,
    required this.title,
    required this.description,
    required this.responsibleRole,
    required this.actionLabel,
  });

  final String key;
  final String title;
  final String description;
  final String responsibleRole;
  final String actionLabel;
}
