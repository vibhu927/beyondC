import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      if (!mounted) return;
      await ref.read(brandProvider.notifier).fetchCredits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Credits', style: AppTypography.displaySM),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          BCCard(
            shadow: AppShadows.blue,
            backgroundColor: AppColors.ink,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Credits',
                        style: AppTypography.bodySM.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${state.creditBalance}',
                        style: AppTypography.displayXL
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const Text('⚡', style: TextStyle(fontSize: 38)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          BCCard(
            shadow: AppShadows.neon,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How credits work 💡',
                    style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.md),
                _infoRow('Send direct request', '1 credit'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Creator accepts your campaign bid', '1 credit'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Send event invite', '2 credits'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Creator accepts event invite', '1 credit'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Credit Packs', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 760) {
                return Row(
                  children: [
                    Expanded(
                      child: _CreditPackCard(
                        name: 'Starter',
                        credits: 3,
                        price: 149,
                        shadow: AppShadows.neon,
                        badge: null,
                        buttonColor: AppColors.neon,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CreditPackCard(
                        name: 'Growth',
                        credits: 7,
                        price: 299,
                        shadow: AppShadows.pink,
                        badge: 'Most Popular',
                        buttonColor: AppColors.pink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CreditPackCard(
                        name: 'Pro',
                        credits: 12,
                        price: 499,
                        shadow: AppShadows.blue,
                        badge: null,
                        buttonColor: AppColors.blue,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _CreditPackCard(
                    name: 'Starter',
                    credits: 3,
                    price: 149,
                    shadow: AppShadows.neon,
                    badge: null,
                    buttonColor: AppColors.neon,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CreditPackCard(
                    name: 'Growth',
                    credits: 7,
                    price: 299,
                    shadow: AppShadows.pink,
                    badge: 'Most Popular',
                    buttonColor: AppColors.pink,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CreditPackCard(
                    name: 'Pro',
                    credits: 12,
                    price: 499,
                    shadow: AppShadows.blue,
                    badge: null,
                    buttonColor: AppColors.blue,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Transaction History', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.md),
          if (state.isCreditsLoading)
            const _TransactionsShimmer()
          else if (state.creditTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
              child: Text(
                'No credit transactions yet.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
              ),
            )
          else
            BCCard(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.creditTransactions.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 20,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final txn = state.creditTransactions[index];
                  final isPositive = txn.creditDelta > 0;
                  final sign = isPositive ? '+' : '';

                  return Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$sign${txn.creditDelta} credits',
                              style: AppTypography.labelMD.copyWith(
                                color: isPositive
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(txn.description, style: AppTypography.bodySM),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.labelMD)),
        Text(value, style: AppTypography.labelMD),
      ],
    );
  }
}

class _CreditPackCard extends StatelessWidget {
  const _CreditPackCard({
    required this.name,
    required this.credits,
    required this.price,
    required this.shadow,
    required this.badge,
    required this.buttonColor,
  });

  final String name;
  final int credits;
  final int price;
  final List<BoxShadow> shadow;
  final String? badge;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: shadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: AppTypography.labelLG),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style:
                        AppTypography.labelXS.copyWith(color: AppColors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('$credits credits', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.xs),
          Text('₹$price', style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.md),
          BCPrimaryButton(
            label: 'Buy Now →',
            isFullWidth: true,
            backgroundColor: buttonColor,
            textColor:
                buttonColor == AppColors.neon ? AppColors.ink : AppColors.white,
            shadow: AppShadows.ink,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Coming Soon: Razorpay integration.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionsShimmer extends StatelessWidget {
  const _TransactionsShimmer();

  @override
  Widget build(BuildContext context) {
    return BCCard(
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : AppSpacing.md),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightDivider,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceAlt
                  : AppColors.lightSurfaceAlt,
              child: Row(
                children: [
                  Container(width: 20, height: 20, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 100, height: 14, color: AppColors.white),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                            width: 180, height: 12, color: AppColors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
