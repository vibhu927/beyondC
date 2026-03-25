import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/bc_glass_header_bar.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_text_field.dart';

enum _PostStep { campaignInfo, targetCreator }

class PostCampaignScreen extends ConsumerStatefulWidget {
  const PostCampaignScreen({super.key});

  @override
  ConsumerState<PostCampaignScreen> createState() => _PostCampaignScreenState();
}

class _PostCampaignScreenState extends ConsumerState<PostCampaignScreen> {
  final _titleController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _productDetailsController = TextEditingController();
  final _productValueController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _slotsController = TextEditingController();
  final _minFollowersController = TextEditingController();

  _PostStep _step = _PostStep.campaignInfo;
  String? _category;
  CampaignCollabType _collabType = CampaignCollabType.paid;
  DateTime? _deadline;

  final Set<String> _targetTiers = {'Nano', 'Micro', 'Mid', 'Macro'};
  final Set<String> _targetNiches = <String>{};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _productDetailsController.dispose();
    _productValueController.dispose();
    _deliverablesController.dispose();
    _deadlineController.dispose();
    _slotsController.dispose();
    _minFollowersController.dispose();
    super.dispose();
  }

  bool get _showBudgetFields => _collabType != CampaignCollabType.barter;
  bool get _showProductFields => _collabType != CampaignCollabType.paid;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;
    setState(() {
      _deadline = picked;
      _deadlineController.text = DateFormat('d MMM yyyy').format(picked);
    });
  }

  void _goToStepTwo() {
    final error = _validateStepOne();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _step = _PostStep.targetCreator);
  }

  Future<void> _postCampaign() async {
    final error = _validateStepTwo();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final minBudget = int.tryParse(_minBudgetController.text.trim()) ?? 0;
    final maxBudget = int.tryParse(_maxBudgetController.text.trim()) ?? 0;
    final slots = int.tryParse(_slotsController.text.trim()) ?? 1;

    setState(() => _isSubmitting = true);

    final ok = await ref.read(brandProvider.notifier).postCampaign(
          title: _titleController.text.trim(),
          collabType: _collabType,
          minBudget: _showBudgetFields ? minBudget : 0,
          maxBudget: _showBudgetFields ? maxBudget : 0,
          deadline: _deadline ?? DateTime.now().add(const Duration(days: 7)),
          slotsAvailable: slots,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough credits to post campaign.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campaign posted successfully.')),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.brandCampaigns);
    }
  }

  String? _validateStepOne() {
    if (_titleController.text.trim().isEmpty)
      return 'Campaign title is required.';
    if (_category == null || _category!.trim().isEmpty) {
      return 'Please select a niche/category.';
    }

    if (_showBudgetFields) {
      final min = int.tryParse(_minBudgetController.text.trim());
      final max = int.tryParse(_maxBudgetController.text.trim());
      if (min == null || max == null || min <= 0 || max <= 0) {
        return 'Enter valid budget min and max.';
      }
      if (max < min) return 'Budget max must be greater than min.';
    }

    if (_showProductFields) {
      if (_productDetailsController.text.trim().isEmpty) {
        return 'Product details are required for barter/hybrid.';
      }
      final value = int.tryParse(_productValueController.text.trim());
      if (value == null || value <= 0) {
        return 'Enter a valid product value.';
      }
    }

    if (_deliverablesController.text.trim().isEmpty) {
      return 'Deliverables are required.';
    }
    if (_deadline == null) return 'Deadline is required.';

    final slots = int.tryParse(_slotsController.text.trim());
    if (slots == null || slots <= 0)
      return 'Slots available must be at least 1.';

    return null;
  }

  String? _validateStepTwo() {
    if (_targetTiers.isEmpty) return 'Select at least one target tier.';
    if (_targetNiches.isEmpty) return 'Select at least one target niche.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BCGlassHeaderBar(
              title: 'Post Campaign',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.huge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(
                        currentStep: _step == _PostStep.campaignInfo ? 0 : 1),
                    const SizedBox(height: AppSpacing.xl),
                    if (_step == _PostStep.campaignInfo)
                      _buildCampaignInfoStep(),
                    if (_step == _PostStep.targetCreator)
                      _buildTargetCreatorStep(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BCTextField(
          label: 'Campaign Title',
          hint: 'Summer Fitness Campaign',
          controller: _titleController,
        ),
        const SizedBox(height: AppSpacing.lg),
        BCDropdown(
          label: 'Niche/Category',
          hint: 'Select category',
          value: _category,
          items: _niches,
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Collab Type', style: AppTypography.labelMD),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _collabPill(CampaignCollabType.paid, '💵 Paid'),
            _collabPill(CampaignCollabType.barter, '📦 Barter'),
            _collabPill(CampaignCollabType.hybrid, '🤝 Hybrid'),
          ],
        ),
        if (_showBudgetFields) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BCTextField(
                  label: 'Budget Min (₹)',
                  hint: '1500',
                  keyboardType: TextInputType.number,
                  controller: _minBudgetController,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BCTextField(
                  label: 'Budget Max (₹)',
                  hint: '5000',
                  keyboardType: TextInputType.number,
                  controller: _maxBudgetController,
                ),
              ),
            ],
          ),
        ],
        if (_showProductFields) ...[
          const SizedBox(height: AppSpacing.lg),
          BCTextField(
            label: 'Product Details',
            hint: 'Describe what is being shipped to creators',
            maxLines: 4,
            controller: _productDetailsController,
          ),
          const SizedBox(height: AppSpacing.lg),
          BCTextField(
            label: 'Product Value (₹)',
            hint: '2500',
            keyboardType: TextInputType.number,
            controller: _productValueController,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Deliverables',
          hint: '2 Reels, 3 Stories, 1 YouTube Short',
          maxLines: 3,
          controller: _deliverablesController,
        ),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: _pickDeadline,
          child: AbsorbPointer(
            child: BCTextField(
              label: 'Deadline',
              hint: 'Select date',
              controller: _deadlineController,
              suffixIcon: const Icon(Icons.calendar_today_rounded),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Slots Available',
          hint: '3',
          keyboardType: TextInputType.number,
          controller: _slotsController,
        ),
        const SizedBox(height: AppSpacing.xl),
        BCPrimaryButton.pink(
          label: 'Next →',
          onPressed: _goToStepTwo,
        ),
      ],
    );
  }

  Widget _buildTargetCreatorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Tier', style: AppTypography.labelMD),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _tiers
              .map((tier) => _multiSelectPill(
                    label: tier,
                    selected: _targetTiers.contains(tier),
                    onTap: () {
                      setState(() {
                        if (_targetTiers.contains(tier)) {
                          _targetTiers.remove(tier);
                        } else {
                          _targetTiers.add(tier);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Target Niche', style: AppTypography.labelMD),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _niches
              .map((niche) => _multiSelectPill(
                    label: niche,
                    selected: _targetNiches.contains(niche),
                    onTap: () {
                      setState(() {
                        if (_targetNiches.contains(niche)) {
                          _targetNiches.remove(niche);
                        } else {
                          _targetNiches.add(niche);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Min Followers (optional)',
          hint: '10000',
          keyboardType: TextInputType.number,
          controller: _minFollowersController,
        ),
        const SizedBox(height: AppSpacing.lg),
        BCCard(
          shadow: AppShadows.pink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Campaign Recap', style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Text('Title: ${_titleController.text.trim()}',
                  style: AppTypography.bodySM),
              Text('Category: ${_category ?? '-'}',
                  style: AppTypography.bodySM),
              Text('Type: ${_collabText(_collabType)}',
                  style: AppTypography.bodySM),
              Text(
                'Budget: ${_showBudgetFields ? '₹${_minBudgetController.text.trim()} - ₹${_maxBudgetController.text.trim()}' : 'Barter only'}',
                style: AppTypography.bodySM,
              ),
              Text(
                'Deadline: ${_deadlineController.text.trim()}',
                style: AppTypography.bodySM,
              ),
              Text(
                'Tiers: ${_targetTiers.join(', ')}',
                style: AppTypography.bodySM,
              ),
              Text(
                'Niches: ${_targetNiches.isEmpty ? '-' : _targetNiches.join(', ')}',
                style: AppTypography.bodySM,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BCPrimaryButton.pink(
          label: 'Post Campaign →',
          onPressed: _isSubmitting ? null : _postCampaign,
          isLoading: _isSubmitting,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '⚡ 1 credit will be deducted on posting',
          style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _step = _PostStep.campaignInfo),
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('← Back to Campaign Info'),
          ),
        ),
      ],
    );
  }

  Widget _collabPill(CampaignCollabType type, String label) {
    final selected = _collabType == type;
    return GestureDetector(
      onTap: () => setState(() => _collabType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: selected ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _multiSelectPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: selected ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(active: currentStep == 0),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            height: 3,
            color: currentStep == 0 ? AppColors.divider : AppColors.neon,
          ),
        ),
        _dot(active: currentStep == 1),
      ],
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? AppColors.neon : AppColors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

String _collabText(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

const _tiers = ['Nano', 'Micro', 'Mid', 'Macro'];
const _niches = [
  'Fashion',
  'Food',
  'Fitness',
  'Tech',
  'Beauty',
  'Travel',
  'Comedy',
  'Lifestyle',
];
