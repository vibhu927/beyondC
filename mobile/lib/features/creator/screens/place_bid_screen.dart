import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_bar.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../widgets/bid_bottom_sheet.dart';

class PlaceBidScreen extends ConsumerWidget {
  const PlaceBidScreen({
    super.key,
    required this.campaignId,
  });

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(creatorCampaignsProvider).valueOrNull?.campaigns ?? const <Campaign>[];
    final campaign = campaigns
        .where((item) => item.id == campaignId)
        .cast<Campaign?>()
        .firstOrNull;

    return Scaffold(
      appBar: const BCAppBar(title: 'Place Bid'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place bids must open as a bottom sheet.',
              style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            BCPrimaryButton.neon(
              label: 'Open Bid Sheet →',
              onPressed: campaign == null
                  ? null
                  : () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BidBottomSheet(campaign: campaign),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
