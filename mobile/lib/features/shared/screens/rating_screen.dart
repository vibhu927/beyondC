import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  final TextEditingController _reviewController = TextEditingController();

  int _score = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collabAsync = ref.watch(collabProvider(widget.collabId));
    final role =
        ref.watch(authProvider.select((state) => state.role)) ?? 'creator';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Rate your collab', style: AppTypography.displaySM),
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
          if (collab.rating != null) {
            return const BCEmptyState(
              emoji: '⭐',
              message: 'You\'ve already rated this collab ⭐',
            );
          }

          if (collab.status != 'completed') {
            return const BCEmptyState(
              emoji: '⏳',
              message: 'You can rate this collab after it is marked completed.',
            );
          }

          final ratedUserId =
              role == 'creator' ? collab.brandId : collab.creatorId;
          final otherParty =
              role == 'creator' ? 'Brand partner' : 'Creator partner';

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xl,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            children: [
              BCCard(
                shadow: AppShadows.blue,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Text(
                        otherParty.substring(0, 1),
                        style: AppTypography.labelLG,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(otherParty, style: AppTypography.labelLG),
                          Text(
                            role == 'creator' ? 'Brand' : 'Creator',
                            style: AppTypography.bodyXS,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Your rating', style: AppTypography.labelLG),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(5, (index) {
                  final value = index + 1;
                  final isActive = value <= _score;
                  return IconButton(
                    onPressed: () => setState(() => _score = value),
                    icon: Icon(
                      isActive ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.neon,
                      size: 34,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              BCTextField(
                label: 'Review',
                hint: 'Write a review (optional)',
                controller: _reviewController,
                maxLines: 5,
              ),
              const SizedBox(height: AppSpacing.xl),
              BCPrimaryButton.neon(
                label: 'Submit Rating ->',
                isLoading: _isSubmitting,
                onPressed:
                    _isSubmitting ? null : () => _submitRating(ratedUserId),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitRating(String ratedUserId) async {
    if (_score == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a star rating first.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(collabProvider(widget.collabId).notifier).submitRating(
            ratedUserId,
            _score,
            _reviewController.text.trim().isEmpty
                ? null
                : _reviewController.text.trim(),
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted! ⭐')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
