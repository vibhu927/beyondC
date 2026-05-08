import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencyDiscoverScreen extends ConsumerWidget {
  const AgencyDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const Text('Find Creators & Brands', style: AppTypography.displaySM),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) => BCCard(child: ListTile(title: Text('Item ${i+1}'))),
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemCount: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
