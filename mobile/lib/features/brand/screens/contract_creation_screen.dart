import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class ContractCreationScreen extends ConsumerStatefulWidget {
  const ContractCreationScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ContractCreationScreen> createState() =>
      _ContractCreationScreenState();
}

class _ContractCreationScreenState
    extends ConsumerState<ContractCreationScreen> {
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  final _deliverablesController = TextEditingController();
  final _timelineController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _milestonesController = TextEditingController();
  final _specialConditionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingContract();
  }

  Future<void> _loadExistingContract() async {
    try {
      final collab = await ref.read(collabProvider(widget.collabId).future);
      final terms = collab.contractTerms;
      if (terms != null) {
        _deliverablesController.text = terms['deliverables']?.toString() ?? '';
        _timelineController.text = terms['timeline']?.toString() ?? '';
        _paymentTermsController.text = terms['payment_terms']?.toString() ?? '';
        _milestonesController.text = terms['milestones']?.toString() ?? '';
        _specialConditionsController.text =
            terms['special_conditions']?.toString() ?? '';
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _deliverablesController.dispose();
    _timelineController.dispose();
    _paymentTermsController.dispose();
    _milestonesController.dispose();
    _specialConditionsController.dispose();
    super.dispose();
  }

  Future<void> _createContract() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(collabProvider(widget.collabId).notifier).createContract({
        'deliverables': _deliverablesController.text.trim(),
        'timeline': _timelineController.text.trim(),
        'payment_terms': _paymentTermsController.text.trim(),
        'milestones': _milestonesController.text.trim(),
        'special_conditions': _specialConditionsController.text.trim(),
      });

      ref.invalidate(collabProvider(widget.collabId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract created. Creator has been notified.')),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contract'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  Text(
                    'Define the terms for this collaboration. Both parties must accept before the collab becomes active.',
                    style: AppTypography.bodySM.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BCTextField(
                    label: 'Deliverables *',
                    hint: 'e.g., 2 Instagram Reels, 1 Story',
                    controller: _deliverablesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'Timeline *',
                    hint: 'e.g., Content to be posted within 7 days of brief approval',
                    controller: _timelineController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'Payment Terms *',
                    hint: 'e.g., ₹5000 on brief approval, ₹5000 on content posting',
                    controller: _paymentTermsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'Milestones (Optional)',
                    hint: 'e.g., Brief review, Draft 1, Final content',
                    controller: _milestonesController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'Special Conditions (Optional)',
                    hint: 'e.g., Content must include brand hashtag',
                    controller: _specialConditionsController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
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
                  top: BorderSide(color: AppColors.lightDivider, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: BCPrimaryButton(
                  label: _isSaving ? 'Creating...' : 'Create Contract',
                  onPressed: _isSaving ? null : _createContract,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
