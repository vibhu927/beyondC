import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../services/razorpay_checkout_service.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/cards/bc_card.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isTopupInProgress = false;

  Future<void> _refresh() {
    return ref.read(walletProvider.notifier).refresh();
  }

  Future<void> _startTopup(int amountInr) async {
    if (_isTopupInProgress) return;

    setState(() => _isTopupInProgress = true);

    try {
      final order = await ref
          .read(creatorActionsProvider.notifier)
          .topUpWallet(amountInr * 100);
      final auth = ref.read(authProvider);
      final user = auth.user;
      final keyId = (order.keyId?.trim().isNotEmpty ?? false)
          ? order.keyId!.trim()
          : ApiConstants.razorpayKeyId;

      if (keyId == 'YOUR_RAZORPAY_KEY_ID') {
        throw Exception('Missing Razorpay key. Add RAZORPAY_KEY_ID in env.');
      }

      final result = await RazorpayCheckoutService().openCheckout(
        keyId: keyId,
        orderId: order.orderId,
        amountPaise: order.amountPaise,
        currency: order.currency,
        name: 'BeyondC',
        description: 'Wallet top-up (INR $amountInr)',
        prefillEmail: user?.email,
        prefillContact: user?.phone,
      );

      await ref.read(creatorActionsProvider.notifier).verifyWalletTopup(
            orderId: result.orderId,
            paymentId: result.paymentId,
            signature: result.signature,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallet top-up successful.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isNotEmpty ? message : 'Could not complete wallet top-up.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTopupInProgress = false);
      }
    }
  }

  Future<void> _topUpCustomAmount() async {
    final controller = TextEditingController();

    final amount = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom top-up amount'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter INR amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(int.tryParse(controller.text.trim()));
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null || amount <= 0) return;
    await _startTopup(amount);
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: const BCAppBar(title: 'My Wallet'),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: walletAsync.when(
          loading: () => const Center(child: BCAppLoader()),
          error: (error, _) => BCErrorState(
            message: error.toString(),
            onRetry: _refresh,
          ),
          data: (wallet) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              children: [
                BCCard(
                  shadow: AppShadows.neon,
                  backgroundColor: AppColors.ink,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: AppTypography.bodySM.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        Formatters.currency(wallet.balance),
                        style: AppTypography.displayXL.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: AppConstants.walletTopUpOptions
                            .take(3)
                            .map(
                              (amount) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.sm),
                                  child: _QuickTopUpButton(
                                    amount: amount,
                                    onTap: _isTopupInProgress
                                        ? null
                                        : () => _startTopup(amount),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              _isTopupInProgress ? null : _topUpCustomAmount,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Custom Amount →'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BCCard(
                  shadow: AppShadows.blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How fees work 💡',
                          style: AppTypography.displaySM),
                      const SizedBox(height: AppSpacing.md),
                      _feeRow('Micro Brand', '₹10–₹20'),
                      const SizedBox(height: AppSpacing.xs),
                      _feeRow('Mid Brand', '₹50–₹70'),
                      const SizedBox(height: AppSpacing.xs),
                      _feeRow('Big Brand', '₹100–₹150'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Fee deducted only when you accept a collab',
                        style: AppTypography.bodyXS
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('Transaction History',
                    style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.md),
                if (wallet.transactions.isEmpty)
                  const BCEmptyState(message: 'No transactions yet')
                else
                  BCCard(
                    child: ListView.separated(
                      itemCount: wallet.transactions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const Divider(
                        color: AppColors.divider,
                        height: 20,
                      ),
                      itemBuilder: (context, index) {
                        final txn = wallet.transactions[index];
                        final isTopUp = txn.type == 'topup';
                        final sign = isTopUp ? '+' : '-';

                        return Row(
                          children: [
                            Icon(
                              isTopUp
                                  ? Symbols.arrow_upward_rounded
                                  : Symbols.arrow_downward_rounded,
                              color:
                                  isTopUp ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$sign${Formatters.currency(txn.amount)}',
                                    style: AppTypography.labelMD.copyWith(
                                      color: isTopUp
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    isTopUp
                                        ? 'Wallet Top-up'
                                        : 'Collab fee — ${txn.reason}',
                                    style: AppTypography.bodySM,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.date(txn.createdAt ?? DateTime.now()),
                              style: AppTypography.bodyXS,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _feeRow(String tier, String feeRange) {
    return Row(
      children: [
        Expanded(child: Text(tier, style: AppTypography.labelMD)),
        Text(feeRange, style: AppTypography.labelMD),
      ],
    );
  }
}

class _QuickTopUpButton extends StatelessWidget {
  const _QuickTopUpButton({
    required this.amount,
    required this.onTap,
  });

  final int amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.neon,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          '₹$amount',
          style: AppTypography.labelMD.copyWith(color: AppColors.ink),
        ),
      ),
    );
  }
}
