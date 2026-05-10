import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class AgencyPitchBrandScreen extends ConsumerStatefulWidget {
  const AgencyPitchBrandScreen({super.key});

  @override
  ConsumerState<AgencyPitchBrandScreen> createState() => _AgencyPitchBrandScreenState();
}

class _AgencyPitchBrandScreenState extends ConsumerState<AgencyPitchBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _deliverablesController = TextEditingController();

  Map<String, dynamic>? _selectedCreator;
  String _collabType = 'paid';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(agencyRosterProvider);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _deliverablesController.dispose();
    super.dispose();
  }

  Future<void> _submitPitch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCreator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a creator from your roster')),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(agencyRepositoryProvider);
      final brandId = GoRouterState.of(context).extra is Map<String, dynamic>
          ? (GoRouterState.of(context).extra as Map<String, dynamic>)['id']?.toString()
          : null;
      final creatorId = _selectedCreator!['id']?.toString();
      if (brandId == null || creatorId == null) throw Exception('Invalid data');

      await repo.createPitch({
        'pitch_type': 'brand',
        'target_id': {'brand_id': brandId, 'creator_id': creatorId},
        'pitch_title': _titleController.text.trim(),
        'pitch_message': _descriptionController.text.trim(),
        'collab_type': _collabType,
        'proposed_amount': int.tryParse(_amountController.text.trim()),
        'deliverables': _deliverablesController.text.trim().isNotEmpty ? _deliverablesController.text.trim() : null,
      });

      await ref.read(agencyProfileProvider.notifier).refresh();
      await ref.read(agencyPitchesProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pitch sent successfully!')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      final msg = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.isNotEmpty ? msg : 'Failed to send pitch')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rosterState = ref.watch(agencyRosterProvider);
    final roster = rosterState.valueOrNull ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;
    final creditBalance = ref.watch(agencyProfileProvider).valueOrNull?['credit_balance'] ?? 0;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.agencyDark),
          onPressed: () => context.pop(),
        ),
        title: Text('Pitch Brand', style: AppTypography.displaySM.copyWith(
          color: AppColors.agencyDark, fontWeight: FontWeight.w900,
        )),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + 80,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.agencyPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.agencyPrimary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.credit_card_rounded, color: AppColors.agencyDark, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pitch Cost: 1 Credit', style: AppTypography.labelMD.copyWith(color: AppColors.agencyDark)),
                          Text('Balance: $creditBalance credits', style: AppTypography.bodyXS.copyWith(color: muted)),
                        ],
                      ),
                    ),
                    BCBadge(
                      label: creditBalance > 0 ? 'Ready' : 'Low',
                      variant: creditBalance > 0 ? BCBadgeVariant.success : BCBadgeVariant.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Select Creator from Roster', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              if (roster.isEmpty)
                BCCard(
                  backgroundColor: surface,
                  borderColor: outline,
                  child: Row(
                    children: [
                      const Icon(Symbols.info_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'No creators in your roster yet. Partner with creators first.',
                          style: AppTypography.bodyXS.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: roster.map<Widget>((creator) => _CreatorSelectChip(
                    creator: creator,
                    isSelected: _selectedCreator?['id'] == creator['id'],
                    onTap: () => setState(() => _selectedCreator = creator),
                  )).toList(),
                ),
              const SizedBox(height: AppSpacing.xl),
              Text('Pitch Title', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _titleController,
                hint: 'e.g., Exclusive Reel Package for Your Brand',
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Pitch Description', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _descriptionController,
                hint: 'Describe the collaboration opportunity...',
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Collaboration Type', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _TypeChip(label: 'Paid', icon: Icons.currency_rupee, isSelected: _collabType == 'paid',
                    onTap: () => setState(() => _collabType = 'paid')),
                  _TypeChip(label: 'Barter', icon: Icons.swap_horiz, isSelected: _collabType == 'barter',
                    onTap: () => setState(() => _collabType = 'barter')),
                  _TypeChip(label: 'Hybrid', icon: Icons.balance, isSelected: _collabType == 'hybrid',
                    onTap: () => setState(() => _collabType = 'hybrid')),
                  _TypeChip(label: 'Event', icon: Icons.event, isSelected: _collabType == 'event',
                    onTap: () => setState(() => _collabType = 'event')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Proposed Amount (INR)', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _amountController,
                hint: 'e.g., 25000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Deliverables (Optional)', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _deliverablesController,
                hint: 'e.g., 4 reels, 1 story, 2 posts/month',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),
              BCPrimaryButton.dark(
                label: 'Send Pitch',
                isFullWidth: true,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting || _selectedCreator == null ? null : _submitPitch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatorSelectChip extends StatelessWidget {
  const _CreatorSelectChip({required this.creator, required this.isSelected, required this.onTap});

  final Map<String, dynamic> creator;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstName = creator['first_name'] ?? creator['profile']?['first_name'] ?? 'Creator';
    final avatarUrl = creator['avatar_url'] ?? creator['profile']?['avatar_url'];
    final niche = creator['niche'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agencyPrimary.withValues(alpha: 0.15) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.agencyPrimary : AppColors.agencyDark.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.agencyDark.withValues(alpha: 0.15),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? const Icon(Icons.person, color: AppColors.agencyDark, size: 16) : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(firstName, style: AppTypography.labelSM.copyWith(color: AppColors.agencyDark, fontWeight: FontWeight.w700)),
                if (niche != null)
                  Text(
                    niche is List ? (niche as List).join(', ') : niche.toString(),
                    style: AppTypography.labelXS.copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Symbols.check_circle_rounded, color: AppColors.agencyPrimary, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTypography.bodySM.copyWith(color: text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodySM.copyWith(color: muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agencyPrimary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.agencyPrimary : AppColors.agencyDark.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.agencyDark : muted, size: 16),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSM.copyWith(
              color: isSelected ? AppColors.agencyDark : muted,
              fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ),
    );
  }

  Color get muted => AppColors.muted;
}
