import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class PaymentMilestoneSetupScreen extends ConsumerStatefulWidget {
  const PaymentMilestoneSetupScreen({
    super.key,
    required this.collabId,
    required this.agreedAmountPaise,
  });

  final String collabId;
  final int agreedAmountPaise;

  @override
  ConsumerState<PaymentMilestoneSetupScreen> createState() =>
      _PaymentMilestoneSetupScreenState();
}

class _PaymentMilestoneSetupScreenState
    extends ConsumerState<PaymentMilestoneSetupScreen> {
  bool _isSaving = false;
  String _paymentStructure = 'full_upfront';
  final List<_MilestoneInput> _milestones = [];

  @override
  void initState() {
    super.initState();
    _loadExistingMilestones();
  }

  Future<void> _loadExistingMilestones() async {
    try {
      final collab = await ref.read(collabProvider(widget.collabId).future);
      setState(() {
        _paymentStructure = collab.paymentStructure;
      });
      if (_paymentStructure == 'milestone_based') {
        final milestones =
            await ref.read(collabProvider(widget.collabId).notifier).getPaymentMilestones();
        setState(() {
          _milestones.clear();
          for (final m in milestones) {
            _milestones.add(_MilestoneInput(
              nameController: TextEditingController(text: m['name']?.toString() ?? ''),
              percentageController: TextEditingController(
                  text: m['percentage']?.toString() ?? ''),
            ));
          }
          if (_milestones.isEmpty) _addMilestone();
        });
      }
    } catch (_) {
      _addMilestone();
    }
  }

  void _addMilestone() {
    setState(() {
      _milestones.add(_MilestoneInput(
        nameController: TextEditingController(),
        percentageController: TextEditingController(),
      ));
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones[index].dispose();
      _milestones.removeAt(index);
    });
  }

  double get _totalPercentage {
    double total = 0;
    for (final m in _milestones) {
      total += double.tryParse(m.percentageController.text) ?? 0;
    }
    return total;
  }

  int _amountForMilestone(double percentage) {
    return ((widget.agreedAmountPaise * percentage) / 100).round();
  }

  Future<void> _saveMilestones() async {
    if (_paymentStructure == 'milestone_based') {
      final total = _totalPercentage;
      if ((total - 100).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Milestones must sum to 100% (currently ${total.toStringAsFixed(1)}%)')),
        );
        return;
      }

      for (final m in _milestones) {
        if (m.nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All milestone names are required')),
          );
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(collabProvider(widget.collabId).notifier).setPaymentMilestones(
        paymentStructure: _paymentStructure,
        milestones: _paymentStructure == 'milestone_based'
            ? _milestones
                .map((m) => {
                      'name': m.nameController.text.trim(),
                      'percentage': double.parse(m.percentageController.text),
                    })
                .toList()
            : null,
      );

      ref.invalidate(collabProvider(widget.collabId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment structure saved')),
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
  void dispose() {
    for (final m in _milestones) {
      m.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Structure'),
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
                // Total amount
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neon, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, color: AppColors.darkGreen),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Agreed Amount',
                            style: AppTypography.bodyXS.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            Formatters.currency(widget.agreedAmountPaise),
                            style: AppTypography.displaySM.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Payment structure toggle
                Text(
                  'Payment Structure',
                  style: AppTypography.labelMD.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StructureOption(
                        label: 'Full Upfront',
                        description: 'Pay full amount on completion',
                        isSelected: _paymentStructure == 'full_upfront',
                        onTap: () => setState(() => _paymentStructure = 'full_upfront'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StructureOption(
                        label: 'Milestone Based',
                        description: 'Split payment by milestones',
                        isSelected: _paymentStructure == 'milestone_based',
                        onTap: () {
                          setState(() {
                            _paymentStructure = 'milestone_based';
                            if (_milestones.isEmpty) _addMilestone();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Milestones
                if (_paymentStructure == 'milestone_based') ...[
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text(
                        'Milestones',
                        style: AppTypography.labelMD.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _addMilestone,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.neon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+ Add',
                            style: AppTypography.labelXS.copyWith(
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  ...List.generate(_milestones.length, (index) {
                    final m = _milestones[index];
                    final percentage = double.tryParse(m.percentageController.text) ?? 0;
                    final amount = _amountForMilestone(percentage);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightDivider, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: m.nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Milestone name',
                                      hintStyle: AppTypography.bodySM.copyWith(
                                        color: AppColors.muted,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.lightDivider),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.lightDivider),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.neon, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      isDense: true,
                                    ),
                                    style: AppTypography.bodySM,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: m.percentageController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,1}'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '%',
                                      suffixText: '%',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.lightDivider),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.lightDivider),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.neon, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      isDense: true,
                                    ),
                                    style: AppTypography.bodySM,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                if (_milestones.length > 1) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  GestureDetector(
                                    onTap: () => _removeMilestone(index),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (percentage > 0) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  Formatters.currency(amount),
                                  style: AppTypography.labelXS.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                  // Total validation
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: (_totalPercentage - 100).abs() < 0.01
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          (_totalPercentage - 100).abs() < 0.01
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: (_totalPercentage - 100).abs() < 0.01
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Total: ${_totalPercentage.toStringAsFixed(1)}%',
                          style: AppTypography.labelSM.copyWith(
                            color: (_totalPercentage - 100).abs() < 0.01
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Save button
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
                  label: _isSaving ? 'Saving...' : 'Save Payment Structure',
                  onPressed: _isSaving ? null : _saveMilestones,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneInput {
  final TextEditingController nameController;
  final TextEditingController percentageController;

  _MilestoneInput({
    required this.nameController,
    required this.percentageController,
  });

  void dispose() {
    nameController.dispose();
    percentageController.dispose();
  }
}

class _StructureOption extends StatelessWidget {
  const _StructureOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neon.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.lightDivider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSM.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.darkGreen : AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: AppTypography.bodyXS.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
