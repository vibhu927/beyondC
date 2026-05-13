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

class AgencyPitchCreatorScreen extends ConsumerStatefulWidget {
  const AgencyPitchCreatorScreen({super.key});

  @override
  ConsumerState<AgencyPitchCreatorScreen> createState() => _AgencyPitchCreatorScreenState();
}

class _AgencyPitchCreatorScreenState extends ConsumerState<AgencyPitchCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _amountController = TextEditingController();
  final _deliverablesController = TextEditingController();

  String _pitchMode = 'monthly_fee';
  String _collabType = 'paid';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _amountController.dispose();
    _deliverablesController.dispose();
    super.dispose();
  }

  Future<void> _submitPitch(Map<String, dynamic> creator) async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(agencyRepositoryProvider);
      final creatorId = creator['id']?.toString();
      if (creatorId == null) throw Exception('Invalid creator');

      await repo.createPitch({
        'pitch_type': 'creator',
        'target_id': creatorId,
        'pitch_title': _titleController.text.trim(),
        'pitch_message': _messageController.text.trim(),
        'collab_type': _collabType,
        'monthly_fee': _pitchMode == 'monthly_fee' ? int.tryParse(_amountController.text.trim()) : null,
        'profit_ratio': _pitchMode == 'profit_share' ? int.tryParse(_amountController.text.trim()) : null,
        'deliverables': _deliverablesController.text.trim().isNotEmpty ? _deliverablesController.text.trim() : null,
      });

      await ref.read(agencyProfileProvider.notifier).refresh();
      await ref.read(agencyPitchesProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pitch sent to ${creator['first_name'] ?? 'creator'}!')),
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
    final creator = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (creator == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())),
        body: const Center(child: Text('No creator selected')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.black;
    final muted = isDark ? AppColors.darkMuted : AppColors.gray;

    final firstName = creator['first_name'] ?? 'Creator';
    final avatarUrl = creator['avatar_url'];
    final niche = creator['niche'];
    final followers = _formatFollowers(creator['followers_count']);
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
        title: Text('Pitch Creator', style: AppTypography.displaySM.copyWith(
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
              BCCard(
                backgroundColor: surface,
                borderColor: outline,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.agencyDark.withValues(alpha: 0.15),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null ? const Icon(Icons.person, color: AppColors.agencyDark) : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(firstName, style: AppTypography.labelLG.copyWith(color: text)),
                          if (niche != null)
                            Text(
                              niche is List ? (niche).join(', ') : niche.toString(),
                              style: AppTypography.bodyXS.copyWith(color: muted),
                            ),
                        ],
                      ),
                    ),
                    if (followers.isNotEmpty)
                      BCBadge(label: followers, variant: BCBadgeVariant.outline),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
              Text('Pitch Title', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _titleController,
                hint: 'e.g., Brand Partnership Opportunity',
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Pitch Message', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _messageController,
                hint: 'Introduce your agency and why this creator is a great fit...',
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Message is required' : null,
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
              Text('Payment Mode', style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ModeSelector(
                      label: 'Monthly Fee',
                      icon: Icons.currency_rupee,
                      isSelected: _pitchMode == 'monthly_fee',
                      onTap: () => setState(() => _pitchMode = 'monthly_fee'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ModeSelector(
                      label: 'Profit Share',
                      icon: Icons.percent,
                      isSelected: _pitchMode == 'profit_share',
                      onTap: () => setState(() => _pitchMode = 'profit_share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(_pitchMode == 'monthly_fee' ? 'Monthly Fee (INR)' : 'Profit Share (%)',
                style: AppTypography.labelMD.copyWith(color: text)),
              const SizedBox(height: AppSpacing.sm),
              _FormField(
                controller: _amountController,
                hint: _pitchMode == 'monthly_fee' ? 'e.g., 15000' : 'e.g., 30',
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
                onPressed: _isSubmitting ? null : () => _submitPitch(creator),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFollowers(dynamic count) {
    if (count == null) return '';
    try {
      final c = count is int ? count : int.parse(count.toString());
      if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
      if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
      return c.toString();
    } catch (_) {
      return '';
    }
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.label, required this.icon, required this.isSelected, required this.onTap});

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final text = isDark ? AppColors.darkText : AppColors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agencyPrimary.withValues(alpha: 0.1) : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.agencyPrimary : AppColors.agencyDark.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.agencyDark : text, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.labelSM.copyWith(
              color: isSelected ? AppColors.agencyDark : text,
              fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ),
    );
  }
}
