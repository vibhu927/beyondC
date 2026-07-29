import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/saved_creators_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';

class SavedCreatorsScreen extends ConsumerWidget {
  const SavedCreatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedCreatorsProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.lightBg),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      MediaQuery.of(context).padding.top + 14,
                      AppSpacing.screenPadding,
                      AppSpacing.md,
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
                              color: AppColors.brandDark.withValues(alpha: 0.14),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.brandDark,
                              size: 22,
                            ),
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Saved Creators',
                          style: AppTypography.displaySM.copyWith(
                            color: AppColors.brandDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: savedAsync.when(
                      loading: () => const Center(child: BCAppLoader()),
                      error: (error, _) => BCErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(savedCreatorsProvider),
                      ),
                      data: (saved) {
                        if (saved.isEmpty) {
                          return const BCEmptyState(
                            emoji: '🔖',
                            message: 'No saved creators yet.\nBrowse creators and save the ones you like.',
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding,
                            AppSpacing.md,
                            AppSpacing.screenPadding,
                            AppSpacing.huge,
                          ),
                          itemCount: saved.length,
                          itemBuilder: (context, index) {
                            final creator = saved[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == saved.length - 1 ? 0 : AppSpacing.md,
                              ),
                              child: _SavedCreatorCard(creator: creator),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCreatorCard extends ConsumerWidget {
  const _SavedCreatorCard({required this.creator});

  final dynamic creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor(creator.creatorInitial),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: (creator.avatarUrl ?? '').toString().trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          creator.avatarUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            creator.creatorInitial,
                            style: AppTypography.labelMD.copyWith(color: AppColors.white),
                          ),
                        ),
                      )
                    : Text(
                        creator.creatorInitial,
                        style: AppTypography.labelMD.copyWith(color: AppColors.white),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.firstName ?? 'Creator',
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (creator.tier != null)
                          _Pill(
                            label: creator.tier!,
                            tone: AppColors.brandDark.withValues(alpha: 0.08),
                          ),
                        ...(creator.niche ?? []).take(2).map(
                              (niche) => _Pill(
                                label: niche,
                                tone: AppColors.brandDark.withValues(alpha: 0.08),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(savedCreatorsProvider.notifier).toggleSave(creator.creatorId),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandDark,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Symbols.bookmark_rounded,
                    size: 18,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (creator.followerCount != null) ...[
                Text(
                  '${Formatters.followerCount(creator.followerCount!).toLowerCase()} followers',
                  style: AppTypography.bodySM.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (creator.engagementRate != null)
                Text(
                  '${creator.engagementRate!.toStringAsFixed(1)}% engagement',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      RouteNames.partnerProfile,
                      extra: {
                        'id': creator.creatorId,
                        'first_name': creator.firstName,
                        'full_name': creator.firstName,
                        'name': creator.firstName,
                        'avatar_url': creator.avatarUrl,
                        'role': 'creator',
                        'viewerRole': 'brand',
                        'tier': creator.tier,
                        'bio': (creator.niche ?? []).join(', '),
                        'followers': creator.followerCount,
                        'readOnly': true,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.brandDark,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View Profile',
                      style: AppTypography.labelSM.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String initials) {
    const palette = [
      AppColors.blue,
      AppColors.pink,
      AppColors.purple,
      AppColors.orange,
    ];
    return palette[initials.codeUnitAt(0) % palette.length];
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTypography.labelXS.copyWith(
          color: AppColors.brandDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
