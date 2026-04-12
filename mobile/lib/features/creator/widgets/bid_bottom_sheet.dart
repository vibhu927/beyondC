import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class BidBottomSheet extends ConsumerStatefulWidget {
  const BidBottomSheet({
    super.key,
    required this.campaign,
    this.onSubmitted,
  });

  final Campaign campaign;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<BidBottomSheet> createState() => _BidBottomSheetState();
}

class _BidBottomSheetState extends ConsumerState<BidBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _pitchController = TextEditingController();

  bool _includeBarter = false;
  bool _isSubmitting = false;

  bool get _showPriceField =>
      widget.campaign.collabType != CampaignCollabType.barter;

  bool get _showBarterToggle =>
      widget.campaign.collabType == CampaignCollabType.barter ||
      widget.campaign.collabType == CampaignCollabType.hybrid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _deliverablesController.dispose();
    _pitchController.dispose();
    super.dispose();
  }

  int _estimatedFeePaise() {
    if (widget.campaign.maxBudget <= 3000) return 2000;
    if (widget.campaign.maxBudget <= 7000) return 7000;
    return 20000;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bidAmount =
          _showPriceField ? int.tryParse(_priceController.text.trim()) : null;

      await ref.read(creatorActionsProvider.notifier).submitBid(
            campaignId: widget.campaign.id,
            bidAmount: bidAmount,
            deliverables: _deliverablesController.text.trim(),
            includeBarter: _includeBarter,
            message: _pitchController.text.trim(),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit bid right now.')),
      );
      return;
    }

    if (!mounted) return;

    widget.onSubmitted?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final balancePaise = ref.watch(walletProvider).valueOrNull?.balance ?? 0;
    final feePaise = _estimatedFeePaise();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.huge,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Place Your Bid',
                        style: AppTypography.displaySM),
                    const SizedBox(height: 24),
                    if (_showPriceField)
                      BCTextField(
                        label: 'Your Price (₹)',
                        hint: '2500',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!_showPriceField) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required for paid/hybrid campaigns';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    if (_showPriceField) const SizedBox(height: AppSpacing.lg),
                    BCTextField(
                      label: 'What will you deliver?',
                      hint: '2 Reels, 1 Story, posted within 5 days',
                      controller: _deliverablesController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deliverables are required';
                        }
                        return null;
                      },
                    ),
                    if (_showBarterToggle) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Include product barter?',
                              style: AppTypography.labelMD,
                            ),
                          ),
                          Switch(
                            value: _includeBarter,
                            activeThumbColor: AppColors.neon,
                            onChanged: (value) {
                              setState(() {
                                _includeBarter = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    BCTextField(
                      label: 'Pitch yourself (optional)',
                      hint: 'Why are you the right fit?',
                      controller: _pitchController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BCCard(
                      shadow: AppShadows.neon,
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💰 Collab fee: ${Formatters.currency(feePaise)} will be deducted from your wallet only if accepted',
                            style: AppTypography.bodySM,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Current balance: ${Formatters.currency(balancePaise)}',
                            style: AppTypography.bodyXS
                                .copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BCPrimaryButton.neon(
                      label: 'Submit Bid →',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
