import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class ContractScreen extends ConsumerStatefulWidget {
  const ContractScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen> {
  bool _isAccepting = false;
  Map<String, dynamic>? _contract;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collab = await ref.read(collabProvider(widget.collabId).future);
      setState(() {
        _contract = collab.contractTerms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptContract() async {
    setState(() => _isAccepting = true);

    try {
      await ref.read(collabProvider(widget.collabId).notifier).acceptContract();
      ref.invalidate(collabProvider(widget.collabId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract accepted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider.select((s) => s.role)) ?? 'creator';
    final collabAsync = ref.watch(collabProvider(widget.collabId));

    if (_isLoading) {
      return const Scaffold(body: Center(child: BCAppLoader()));
    }

    if (_error != null) {
      return Scaffold(
        body: BCErrorState(
          message: _error!,
          onRetry: _loadContract,
        ),
      );
    }

    final collab = collabAsync.valueOrNull;
    final contract = _contract ?? collab?.contractTerms;

    if (contract == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Contract'),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text('No contract terms found for this collab.'),
        ),
      );
    }

    final isCreator = role == 'creator';
    final alreadyAccepted =
        isCreator ? collab?.creatorContractAccepted == true : collab?.brandContractAccepted == true;
    final otherAccepted =
        isCreator ? collab?.brandContractAccepted == true : collab?.creatorContractAccepted == true;
    final bothAccepted = alreadyAccepted && otherAccepted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                // Status header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: bothAccepted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : alreadyAccepted
                            ? AppColors.neon.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bothAccepted
                          ? AppColors.success
                          : alreadyAccepted
                              ? AppColors.neon
                              : AppColors.warning,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        bothAccepted
                            ? Icons.check_circle_rounded
                            : alreadyAccepted
                                ? Icons.hourglass_top_rounded
                                : Icons.info_outline_rounded,
                        color: bothAccepted
                            ? AppColors.success
                            : alreadyAccepted
                                ? AppColors.darkGreen
                                : AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bothAccepted
                                  ? 'Contract Fully Accepted'
                                  : alreadyAccepted
                                      ? 'You accepted. Waiting for other party.'
                                      : 'Contract pending your acceptance',
                              style: AppTypography.labelMD.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            if (!bothAccepted && otherAccepted)
                              Text(
                                'Other party has accepted',
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Contract sections
                _ContractSection(
                  title: 'Deliverables',
                  content: contract['deliverables']?.toString() ?? 'Not specified',
                ),
                const SizedBox(height: AppSpacing.lg),
                _ContractSection(
                  title: 'Timeline',
                  content: contract['timeline']?.toString() ?? 'Not specified',
                ),
                const SizedBox(height: AppSpacing.lg),
                _ContractSection(
                  title: 'Payment Terms',
                  content: contract['payment_terms']?.toString() ?? 'Not specified',
                ),
                if (contract['milestones']?.toString().isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ContractSection(
                    title: 'Milestones',
                    content: contract['milestones']?.toString() ?? '',
                  ),
                ],
                if (contract['special_conditions']?.toString().isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ContractSection(
                    title: 'Special Conditions',
                    content: contract['special_conditions']?.toString() ?? '',
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // Acceptance status
                _AcceptanceRow(
                  label: isCreator ? 'You (Creator)' : 'You (Brand)',
                  accepted: alreadyAccepted,
                  acceptedAt: isCreator
                      ? collab?.creatorContractAcceptedAt
                      : collab?.brandContractAcceptedAt,
                ),
                const SizedBox(height: AppSpacing.sm),
                _AcceptanceRow(
                  label: isCreator ? 'Brand' : 'Creator',
                  accepted: otherAccepted,
                  acceptedAt: isCreator
                      ? collab?.brandContractAcceptedAt
                      : collab?.creatorContractAcceptedAt,
                ),
              ],
            ),
          ),

          // Accept button
          if (!alreadyAccepted)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                MediaQuery.of(context).padding.bottom + AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.lightDivider,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: BCPrimaryButton(
                  label: _isAccepting ? 'Accepting...' : 'Accept Contract',
                  onPressed: _isAccepting ? null : _acceptContract,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContractSection extends StatelessWidget {
  const _ContractSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMD.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightDivider,
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: AppTypography.bodySM.copyWith(
              color: AppColors.ink,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AcceptanceRow extends StatelessWidget {
  const _AcceptanceRow({
    required this.label,
    required this.accepted,
    this.acceptedAt,
  });

  final String label;
  final bool accepted;
  final DateTime? acceptedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          accepted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 18,
          color: accepted ? AppColors.success : AppColors.muted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySM.copyWith(
            color: accepted ? AppColors.ink : AppColors.muted,
            fontWeight: accepted ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (accepted && acceptedAt != null) ...[
          const Spacer(),
          Text(
            'Accepted',
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
