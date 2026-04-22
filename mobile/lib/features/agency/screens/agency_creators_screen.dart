import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/badges/bc_badge.dart';

class AgencyCreatorsScreen extends ConsumerWidget {
  const AgencyCreatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Creators')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text('Partnered', style: AppTypography.displaySM)),
              TextButton(onPressed: () {}, child: const Text('Invite')),
            ]),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) => BCCard(child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Creator ${i+1}'),
                  subtitle: const Text('Tier · Niche · City'),
                  trailing: ElevatedButton(onPressed: () => context.push(RouteNames.agencyPitches), child: const Text('Pitch for them →')),
                )),
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemCount: 6,
              ),
            )
          ],
        ),
      ),
    );
  }
}
