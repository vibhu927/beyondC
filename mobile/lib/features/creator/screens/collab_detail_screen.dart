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
import '../../../providers/collab_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../../chat/chat_screen.dart';
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
                        accentColor: AppColors.neon,
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
                        accentColor: AppColors.success,
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
                                    onTap: () => openChatDrawer(context, collabId),
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
                        accentColor: AppColors.blue,
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
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Actions',
                        style: AppTypography.displaySM.copyWith(
                          color: AppColors.creatorDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildActionRow(
                        context: context,
                        icon: Symbols.update_rounded,
                        label: 'Update Status',
                        subtitle: 'Current: ${_statusLabel(collab.collabStatus)}',
                        iconColor: AppColors.neon,
                        onTap: () => _showStatusUpdateModal(
                          context,
                          ref,
                          collab,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildActionRow(
                        context: context,
                        icon: Symbols.description_rounded,
                        label: 'Contract',
                        subtitle: collab.contractTerms != null
                            ? (collab.creatorContractAccepted && collab.brandContractAccepted
                                ? 'Accepted'
                                : 'Pending')
                            : 'Not created',
                        iconColor: AppColors.blue,
                        onTap: collab.contractTerms != null
                            ? () => context.push(
                                RouteNames.collabContract
                                    .replaceAll(':id', collabId),
                              )
                            : () => context.push(
                                RouteNames.collabContractCreate
                                    .replaceAll(':id', collabId),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildActionRow(
                        context: context,
                        icon: Symbols.upload_rounded,
                        label: 'Submit Content',
                        subtitle: 'Upload draft or final content',
                        iconColor: AppColors.purple,
                        onTap: () => context.push(
                          RouteNames.collabContentSubmit
                              .replaceAll(':id', collabId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildActionRow(
                        context: context,
                        icon: Symbols.attach_money_rounded,
                        label: 'Payment',
                        subtitle: collab.paymentStructure == 'full_upfront'
                            ? 'Setup Milestones'
                            : 'View Milestones',
                        iconColor: AppColors.success,
                        onTap: collab.paymentStructure == 'full_upfront'
                            ? () => context.push(
                                RouteNames.collabPaymentSetup
                                    .replaceAll(':id', collabId),
                              )
                            : () => context.push(
                                RouteNames.collabPaymentView
                                    .replaceAll(':id', collabId),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _ContentSubmissionsSection(
                        collabId: collabId,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _PaymentProgressSection(
                        collabId: collabId,
                        paymentStructure: collab.paymentStructure,
                      ),
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
      case 'started':
        return 'Started';
      case 'working_on_draft':
        return 'Working on Draft';
      case 'draft_ready':
        return 'Draft Ready';
      case 'content_posted':
        return 'Content Posted';
      default:
        return status;
    }
  }

  void _showStatusUpdateModal(
    BuildContext context,
    WidgetRef ref,
    Collab collab,
  ) {
    final statuses = [
      'started',
      'working_on_draft',
      'draft_ready',
      'content_posted',
      'completed',
    ];
    String selectedStatus = collab.collabStatus;
    final messageController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXL),
              ),
              border: Border.all(
                color: AppColors.creatorDark,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.creatorDark.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Text(
                    'Update Collab Status',
                    style: AppTypography.displaySM.copyWith(
                      color: AppColors.creatorDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Status',
                          style: AppTypography.labelMD.copyWith(
                            color: AppColors.creatorDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: statuses.map((status) {
                            final isSelected = selectedStatus == status;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() => selectedStatus = status);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.creatorDark
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: AppColors.creatorDark,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: AppTypography.labelSM.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.creatorDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Message (optional)',
                          style: AppTypography.labelMD.copyWith(
                            color: AppColors.creatorDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: messageController,
                          maxLines: 3,
                          style: AppTypography.bodyMD,
                          decoration: InputDecoration(
                            hintText: 'Add a note about this status update...',
                            hintStyle: AppTypography.bodyMD.copyWith(
                              color: AppColors.muted,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.creatorDark.withValues(alpha: 0.14),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.creatorDark.withValues(alpha: 0.14),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.creatorDark,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              border: Border.all(
                                color: AppColors.creatorDark,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: AppTypography.labelMD.copyWith(
                                color: AppColors.creatorDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : () async {
                                  setModalState(() => isLoading = true);
                                  try {
                                    await ref
                                        .read(collabProvider(collabId).notifier)
                                        .updateCollabStatus(
                                          selectedStatus,
                                          message: messageController.text.trim().isEmpty
                                              ? null
                                              : messageController.text.trim(),
                                        );
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Status updated successfully!'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isLoading = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.creatorDark,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.neon,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Update Status',
                                    style: AppTypography.labelMD.copyWith(
                                      color: AppColors.neon,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
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

  Widget _buildActionRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppColors.neon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: AppColors.creatorDark.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.creatorDark.withValues(alpha: 0.14),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: AppColors.creatorDark,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMD.copyWith(
                      color: AppColors.creatorDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.arrow_forward_ios_rounded,
              color: AppColors.creatorDark.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
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

class _ContentSubmissionsSection extends ConsumerStatefulWidget {
  const _ContentSubmissionsSection({required this.collabId});

  final String collabId;

  @override
  ConsumerState<_ContentSubmissionsSection> createState() => _ContentSubmissionsSectionState();
}

class _ContentSubmissionsSectionState extends ConsumerState<_ContentSubmissionsSection> {
  List<Map<String, dynamic>>? _submissions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      final submissions = await ref
          .read(collabProvider(widget.collabId).notifier)
          .getContentSubmissions();
      if (mounted) {
        setState(() {
          _submissions = submissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    final submissions = _submissions ?? [];
    if (submissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Content Submissions',
              style: AppTypography.displaySM.copyWith(
                color: AppColors.creatorDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            BCBadge(
              label: '${submissions.length}',
              variant: BCBadgeVariant.neon,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassPanel(
          accentColor: AppColors.pink,
          child: Column(
            children: submissions.take(3).map((submission) {
              final status = submission['status'] ?? 'pending';
              final createdAt = submission['created_at'];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _submissionStatusColor(status).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.creatorDark.withValues(alpha: 0.14),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _submissionStatusIcon(status),
                        color: _submissionStatusColor(status),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _submissionStatusLabel(status),
                            style: AppTypography.labelSM.copyWith(
                              color: AppColors.creatorDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              Formatters.timeAgo(DateTime.parse(createdAt)),
                              style: AppTypography.bodyXS.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (submissions.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              '+${submissions.length - 3} more submissions',
              style: AppTypography.bodyXS.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }

  Color _submissionStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.orange;
    }
  }

  IconData _submissionStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.schedule_rounded;
    }
  }

  String _submissionStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending Review';
    }
  }
}

class _PaymentProgressSection extends ConsumerStatefulWidget {
  const _PaymentProgressSection({
    required this.collabId,
    required this.paymentStructure,
  });

  final String collabId;
  final String paymentStructure;

  @override
  ConsumerState<_PaymentProgressSection> createState() => _PaymentProgressSectionState();
}

class _PaymentProgressSectionState extends ConsumerState<_PaymentProgressSection> {
  List<Map<String, dynamic>>? _milestones;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    try {
      final milestones = await ref
          .read(collabProvider(widget.collabId).notifier)
          .getPaymentMilestones();
      if (mounted) {
        setState(() {
          _milestones = milestones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paymentStructure == 'full_upfront') return const SizedBox.shrink();
    if (_isLoading) return const SizedBox.shrink();
    
    final milestones = _milestones ?? [];
    if (milestones.isEmpty) return const SizedBox.shrink();

    final releasedCount = milestones.where((m) => m['status'] == 'released').length;
    final totalAmount = milestones.fold<int>(
      0,
      (sum, m) => sum + ((m['amount_paise'] as int?) ?? 0),
    );
    final releasedAmount = milestones
        .where((m) => m['status'] == 'released')
        .fold<int>(0, (sum, m) => sum + ((m['amount_paise'] as int?) ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Progress',
          style: AppTypography.displaySM.copyWith(
            color: AppColors.creatorDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassPanel(
          accentColor: AppColors.success,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Milestones',
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    '$releasedCount/${milestones.length} released',
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.creatorDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: milestones.isNotEmpty ? releasedCount / milestones.length : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.creatorDark.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neon),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTypography.labelSM.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    Formatters.currencyFromINR(totalAmount),
                    style: AppTypography.labelMD.copyWith(
                      color: AppColors.creatorDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (releasedAmount > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Released',
                      style: AppTypography.labelSM.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      Formatters.currencyFromINR(releasedAmount),
                      style: AppTypography.labelMD.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}