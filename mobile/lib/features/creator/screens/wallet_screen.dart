import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/cards/bc_card.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await Future.wait([
        ref.read(creatorProvider.notifier).fetchCreatorHome(),
        ref.read(creatorProvider.notifier).fetchWallet(),
      ]);
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorProvider.notifier).refreshCreatorHome(),
      ref.read(creatorProvider.notifier).refreshWallet(),
    ]);
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
    ref.read(creatorProvider.notifier).topUpWallet(amount);
  }

  @override
  Widget build(BuildContext context) {
    final creatorState = ref.watch(creatorProvider);

    return Scaffold(
      appBar: const BCAppBar(title: 'My Wallet'),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: _refresh,
        child: ListView(
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
                    Formatters.currency(creatorState.walletBalancePaise),
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
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: _QuickTopUpButton(
                                amount: amount,
                                onTap: () =>
                                    ref.read(creatorProvider.notifier).topUpWallet(amount),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _topUpCustomAmount,
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
                  const Text('How fees work 💡', style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.md),
                  _feeRow('Micro Brand', '₹10–₹30'),
                  const SizedBox(height: AppSpacing.xs),
                  _feeRow('Mid Brand', '₹50–₹100'),
                  const SizedBox(height: AppSpacing.xs),
                  _feeRow('Big Brand', '₹150–₹300'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Fee deducted only when you accept a collab',
                    style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Transaction History', style: AppTypography.displaySM),
            const SizedBox(height: AppSpacing.md),
            if (creatorState.isWalletLoading)
              const _TransactionShimmerList()
            else if (creatorState.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
                child: Text(
                  'No transactions yet',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
                ),
              )
            else
              BCCard(
                child: ListView.separated(
                  itemCount: creatorState.transactions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(
                    color: AppColors.divider,
                    height: 20,
                  ),
                  itemBuilder: (context, index) {
                    final txn = creatorState.transactions[index];
                    final isTopUp = txn.type == WalletTransactionType.topUp;
                    final sign = isTopUp ? '+' : '-';

                    return Row(
                      children: [
                        Icon(
                          isTopUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: isTopUp ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$sign${Formatters.currency(txn.amountPaise)}',
                                style: AppTypography.labelMD.copyWith(
                                  color:
                                      isTopUp ? AppColors.success : AppColors.error,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                isTopUp
                                    ? 'Wallet Top-up'
                                    : 'Collab fee — ${txn.brandCategory ?? 'Campaign'}',
                                style: AppTypography.bodySM,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.date(txn.createdAt),
                          style: AppTypography.bodyXS,
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
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
  final VoidCallback onTap;

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

class _TransactionShimmerList extends StatelessWidget {
  const _TransactionShimmerList();

  @override
  Widget build(BuildContext context) {
    return BCCard(
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : AppSpacing.md),
            child: Shimmer.fromColors(
              baseColor: AppColors.divider,
              highlightColor: AppColors.surfaceAlt,
              child: Row(
                children: [
                  Container(width: 18, height: 18, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 140,
                          height: 12,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 70, height: 12, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
