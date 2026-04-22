import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/cards/bc_card.dart';

class AgencyRosterScreen extends ConsumerWidget {
  const AgencyRosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roster')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView.separated(
          itemBuilder: (_, i) => BCCard(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Partnered Creator ${i+1}'),
            subtitle: const Text('accepted • 2 months ago'),
            trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          )),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemCount: 10,
        ),
      ),
    );
  }
}
