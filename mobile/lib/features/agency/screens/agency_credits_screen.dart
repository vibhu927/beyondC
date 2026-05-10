import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/api_constants.dart';
import '../../../providers/agency_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/razorpay_checkout_service.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencyCreditsScreen extends ConsumerStatefulWidget {
  const AgencyCreditsScreen({super.key});

  @override
  ConsumerState<AgencyCreditsScreen> createState() => _AgencyCreditsScreenState();
}

class _AgencyCreditsScreenState extends ConsumerState<AgencyCreditsScreen> {
  bool _isPurchaseInProgress = false;

  Future<void> _buyCredits({
    required String pack,
    required String packName,
    required int priceInr,
  }) async {
    if (_isPurchaseInProgress) return;

    setState(() => _isPurchaseInProgress = true);

    try {
      final order = await ref.read(agencyCreditsProvider.notifier).initiateCreditPurchase(pack);
      final auth = ref.read(authProvider);
      final user = auth.user;
      final keyId = ApiConstants.razorpayKeyId;

      if (keyId == 'YOUR_RAZORPAY_KEY_ID') {
        throw Exception('Missing Razorpay key. Add RAZORPAY_KEY_ID in env.');
      }

      final result = await RazorpayCheckoutService().openCheckout(
        keyId: keyId,
        orderId: order.orderId,
        amountPaise: order.amount,
        currency: order.currency,
        name: 'BeyondC',
        description: '$packName credit pack (INR $priceInr)',
        prefillEmail: user?.email,
        prefillContact: user?.phone,
      );

      await ref.read(agencyCreditsProvider.notifier).verifyCreditPurchase({
        'razorpay_order_id': result.orderId,
        'razorpay_payment_id': result.paymentId,
        'razorpay_signature': result.signature,
      });

      await ref.read(agencyProfileProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$packName credits added successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isNotEmpty ? message : 'Unable to complete payment.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchaseInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agencyState = ref.watch(agencyProfileProvider);
    final credits = agencyState.valueOrNull?['credit_balance'] ?? 0;

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
                        '$credits',
                        style: AppTypography.displayXL.copyWith(color: AppColors.white),
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
                const Text('How credits work 💡', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.md),
                _infoRow('Pitch creator (they accept)', '1 credit'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Brand accepts your pitch', '1 credit'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Brand pitches you (you accept)', '1 credit'),
                const SizedBox(height: AppSpacing.xs),
                _infoRow('Creator pitches you (you accept)', '1 credit'),
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
                        buttonColor: AppColors.agencyPrimary,
                        isLoading: _isPurchaseInProgress,
                        onBuy: () => _buyCredits(
                          pack: 'starter',
                          packName: 'Starter',
                          priceInr: 149,
                        ),
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
                        isLoading: _isPurchaseInProgress,
                        onBuy: () => _buyCredits(
                          pack: 'growth',
                          packName: 'Growth',
                          priceInr: 299,
                        ),
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
                        isLoading: _isPurchaseInProgress,
                        onBuy: () => _buyCredits(
                          pack: 'pro',
                          packName: 'Pro',
                          priceInr: 499,
                        ),
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
                    buttonColor: AppColors.agencyPrimary,
                    isLoading: _isPurchaseInProgress,
                    onBuy: () => _buyCredits(
                      pack: 'starter',
                      packName: 'Starter',
                      priceInr: 149,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CreditPackCard(
                    name: 'Growth',
                    credits: 7,
                    price: 299,
                    shadow: AppShadows.pink,
                    badge: 'Most Popular',
                    buttonColor: AppColors.pink,
                    isLoading: _isPurchaseInProgress,
                    onBuy: () => _buyCredits(
                      pack: 'growth',
                      packName: 'Growth',
                      priceInr: 299,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CreditPackCard(
                    name: 'Pro',
                    credits: 12,
                    price: 499,
                    shadow: AppShadows.blue,
                    badge: null,
                    buttonColor: AppColors.blue,
                    isLoading: _isPurchaseInProgress,
                    onBuy: () => _buyCredits(
                      pack: 'pro',
                      packName: 'Pro',
                      priceInr: 499,
                    ),
                  ),
                ],
              );
            },
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
    required this.isLoading,
    required this.onBuy,
  });

  final String name;
  final int credits;
  final int price;
  final List<BoxShadow> shadow;
  final String? badge;
  final Color buttonColor;
  final bool isLoading;
  final VoidCallback onBuy;

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
                    style: AppTypography.labelXS.copyWith(color: AppColors.white),
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
            textColor: buttonColor == AppColors.agencyPrimary ? AppColors.ink : AppColors.white,
            shadow: AppShadows.ink,
            isLoading: isLoading,
            onPressed: isLoading ? null : onBuy,
          ),
        ],
      ),
    );
  }
}