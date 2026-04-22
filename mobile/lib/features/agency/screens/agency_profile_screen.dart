import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/agency_provider.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/badges/bc_badge.dart';

class AgencyProfileScreen extends ConsumerWidget {
  const AgencyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agency = ref.watch(agencyProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agency')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: agency.when(
          data: (data) => ListView(
            children: [
              BCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data['agency_name'] ?? 'Agency', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  BCBadge(label: data['is_agency_verified'] == true ? 'Verified' : 'Unverified', variant: data['is_agency_verified'] == true ? BCBadgeVariant.blue : BCBadgeVariant.outline),
                ]),
              ])),
              const SizedBox(height: AppSpacing.md),
              BCCard(child: Text(data['description'] ?? 'No description')),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
        ),
      ),
    );
  }
}
