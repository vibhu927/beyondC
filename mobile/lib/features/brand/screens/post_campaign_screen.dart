import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/brand_page_top_header.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_location_picker.dart';
import '../../../widgets/inputs/bc_text_field.dart';

enum _PostStep { campaignInfo, targetCreator }

class PostCampaignScreen extends ConsumerStatefulWidget {
  const PostCampaignScreen({super.key});

  @override
  ConsumerState<PostCampaignScreen> createState() => _PostCampaignScreenState();
}

class _PostCampaignScreenState extends ConsumerState<PostCampaignScreen> {
  static final BorderRadius _pillFieldRadius =
      BorderRadius.circular(AppSpacing.radiusFull);

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _productDetailsController = TextEditingController();
  final _productValueController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _slotsController = TextEditingController();
  final _minFollowersController = TextEditingController();

  _PostStep _step = _PostStep.campaignInfo;
  String? _category;
  CampaignCollabType _collabType = CampaignCollabType.paid;
  DateTime? _deadline;

  final Set<String> _targetTiers = {'Nano', 'Micro', 'Mid', 'Macro'};
  final Set<String> _targetNiches = <String>{};
  bool _panIndia = true;
  String? _targetState;
  String? _targetCity;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _productDetailsController.dispose();
    _productValueController.dispose();
    _deliverablesController.dispose();
    _requirementsController.dispose();
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
      builder: (context, child) {
        final baseTheme = Theme.of(context);
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: AppColors.brandPrimary,
              onPrimary: AppColors.brandDark,
              secondary: AppColors.brandPrimary,
              onSecondary: AppColors.brandDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandDark,
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: AppColors.brandPrimary,
              headerForegroundColor: AppColors.brandDark,
              todayForegroundColor: WidgetStatePropertyAll(AppColors.brandDark),
              dayForegroundColor: WidgetStatePropertyAll(AppColors.brandDark),
            ),
          ),
          child: child!,
        );
      },
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
    final minFollowers = int.tryParse(_minFollowersController.text.trim());

    final deliverables = _deliverablesController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final requirementsParts = <String>[];
    if (_requirementsController.text.trim().isNotEmpty) {
      requirementsParts.add(_requirementsController.text.trim());
    }
    if (minFollowers != null && minFollowers > 0) {
      requirementsParts.add('Min followers: $minFollowers');
    }
    if (_targetTiers.isNotEmpty) {
      requirementsParts.add('Target tiers: ${_targetTiers.join(', ')}');
    }
    if (_targetNiches.isNotEmpty) {
      requirementsParts.add('Target niches: ${_targetNiches.join(', ')}');
    }

    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : (_productDetailsController.text.trim().isNotEmpty
            ? _productDetailsController.text.trim()
            : 'Campaign posted from mobile app');

    setState(() => _isSubmitting = true);

    final ok = await ref.read(brandProvider.notifier).postCampaign(
          title: _titleController.text.trim(),
          description: description,
          category: _category!,
          collabType: _collabType,
          minBudget: _showBudgetFields ? minBudget : 0,
          maxBudget: _showBudgetFields ? maxBudget : 0,
          deliverables: deliverables,
          requirements: requirementsParts.join(' | '),
          deadline: _deadline ?? DateTime.now().add(const Duration(days: 7)),
          slotsAvailable: slots,
          targetState: _panIndia ? null : _targetState,
          targetCity: _panIndia ? null : _targetCity,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post campaign. Please try again.')),
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
    if (_titleController.text.trim().isEmpty) {
      return 'Campaign title is required.';
    }
    if (_category == null || _category!.trim().isEmpty) {
      return 'Please select a niche/category.';
    }

    if (!_panIndia) {
      if ((_targetState ?? '').trim().isEmpty ||
          (_targetCity ?? '').trim().isEmpty) {
        return 'Please select target state and city or choose Pan India.';
      }
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
    if (slots == null || slots <= 0) {
      return 'Slots available must be at least 1.';
    }

    return null;
  }

  String? _validateStepTwo() {
    if (_targetTiers.isEmpty) return 'Select at least one target tier.';
    if (_targetNiches.isEmpty) return 'Select at least one target niche.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + 14;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.lightBg),
            ),
          ),
          Positioned(
            top: -46,
            right: -32,
            child: _GlowOrb(
              size: 136,
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 220,
            left: -44,
            child: _GlowOrb(
              size: 112,
              color: AppColors.brandDark.withValues(alpha: 0.08),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              topInset,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            children: [
              BrandPageTopHeader(
                showBrandIdentity: false,
                showBackButton: true,
                onBack: () => context.pop(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Post Campaign',
                style: AppTypography.displaySM.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Create a high-conversion brief and target the right creators.',
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              _StepIndicator(currentStep: _step == _PostStep.campaignInfo ? 0 : 1),
              const SizedBox(height: AppSpacing.xl),
              if (_step == _PostStep.campaignInfo) _buildCampaignInfoStep(),
              if (_step == _PostStep.targetCreator) _buildTargetCreatorStep(),
            ],
          ),
        ],
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
          borderRadius: _pillFieldRadius,
        ),
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Campaign Description',
          hint: 'Explain campaign objective and tone',
          maxLines: 3,
          controller: _descriptionController,
          borderRadius:  BorderRadius.circular(AppSpacing.radiusLG),
          
        ),
        const SizedBox(height: AppSpacing.lg),
        BCDropdown(
          label: 'Niche/Category',
          hint: 'Select category',
          value: _category,
          items: _niches,
          borderRadius: _pillFieldRadius,
          showShadow: false,
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Target Location', style: AppTypography.labelMD),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Switch(
              value: _panIndia,
              activeTrackColor: AppColors.brandPrimary,
              inactiveTrackColor: AppColors.white,
              thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return AppColors.ink;
              }),
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => AppColors.ink,
              ),
              trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
                (_) => 1.6,
              ),
              onChanged: (value) {
                setState(() {
                  _panIndia = value;
                  if (_panIndia) {
                    _targetState = null;
                    _targetCity = null;
                  }
                });
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Pan India', style: AppTypography.bodyMD),
          ],
        ),
        if (!_panIndia) ...[
          const SizedBox(height: AppSpacing.sm),
          BCLocationPicker(
            required: true,
            initialState: _targetState,
            initialCity: _targetCity,
            inputBorderRadius: _pillFieldRadius,
            onChanged: (state, city) {
              setState(() {
                _targetState = state;
                _targetCity = city;
              });
            },
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Collab Type', style: AppTypography.labelMD),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _collabPill(CampaignCollabType.paid, 'Paid'),
            _collabPill(CampaignCollabType.barter, 'Barter'),
            _collabPill(CampaignCollabType.hybrid, 'Hybrid'),
          ],
        ),
        if (_showBudgetFields) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BCTextField(
                  label: 'Budget Min (INR)',
                  hint: '1500',
                  keyboardType: TextInputType.number,
                  controller: _minBudgetController,
                  borderRadius: _pillFieldRadius,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BCTextField(
                  label: 'Budget Max (INR)',
                  hint: '5000',
                  keyboardType: TextInputType.number,
                  controller: _maxBudgetController,
                  borderRadius: _pillFieldRadius,
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
            borderRadius: _pillFieldRadius,
          ),
          const SizedBox(height: AppSpacing.lg),
          BCTextField(
            label: 'Product Value (INR)',
            hint: '2500',
            keyboardType: TextInputType.number,
            controller: _productValueController,
            borderRadius: _pillFieldRadius,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Deliverables',
          hint: '2 Reels, 3 Stories, 1 YouTube Short',
          maxLines: 3,
          controller: _deliverablesController,
          borderRadius:  BorderRadius.circular(AppSpacing.radiusLG),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Requirements / Demands',
          hint: 'Usage guidelines, hooks, CTA, deadlines, restrictions',
          maxLines: 3,
          controller: _requirementsController,
          borderRadius:  BorderRadius.circular(AppSpacing.radiusLG),
        ),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: _pickDeadline,
          child: AbsorbPointer(
            child: BCTextField(
              label: 'Deadline',
              hint: 'Select date',
              controller: _deadlineController,
              borderRadius: _pillFieldRadius,
              suffixIcon: const Icon(
                Symbols.calendar_today_rounded,
                color: AppColors.brandDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCTextField(
          label: 'Slots Available',
          hint: '3',
          keyboardType: TextInputType.number,
          controller: _slotsController,
          borderRadius: _pillFieldRadius,
        ),
        const SizedBox(height: AppSpacing.xl),
        _BrandPillButton(
          label: 'Next',
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
          borderRadius: _pillFieldRadius,
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
                'Budget: ${_showBudgetFields ? 'INR ${_minBudgetController.text.trim()} - INR ${_maxBudgetController.text.trim()}' : 'Barter only'}',
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
          label: 'Post Campaign ->',
          onPressed: _isSubmitting ? null : _postCampaign,
          isLoading: _isSubmitting,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Campaign posting is free. Credit is deducted only on accepted match.',
          style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _step = _PostStep.campaignInfo),
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('<- Back to Campaign Info'),
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
            color: selected ? AppColors.brandPrimary : AppColors.ink,
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
            color: selected ? AppColors.brandPrimary : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _BrandPillButton extends StatelessWidget {
  const _BrandPillButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
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
            color: currentStep == 0 ? AppColors.divider : AppColors.brandPrimary,
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
        color: active ? AppColors.brandPrimary : AppColors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

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
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
            ),
          ],
        ),
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
