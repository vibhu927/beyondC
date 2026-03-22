import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Tickets 🎟️', style: AppTypography.displaySM),
      ),
      body: ticketsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
        error: (error, _) => BCErrorState(
          message: error.toString(),
          onRetry: () => ref.read(ticketsProvider.notifier).refresh(),
        ),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const BCEmptyState(
              emoji: '🎟️',
              message:
                  'No tickets yet.\nAccept an event invite to get your first ticket!',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final eventDate = ticket.eventDate;

              return BCCard(
                shadow: AppShadows.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.eventTitle, style: AppTypography.labelLG),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ticket.brandName ?? 'Brand event',
                      style:
                          AppTypography.bodySM.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      eventDate == null
                          ? 'Date TBD'
                          : '${Formatters.date(eventDate)} • ${ticket.location ?? 'City TBD'}',
                      style: AppTypography.bodyXS,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BCPrimaryButton.dark(
                        label: 'View Ticket ->',
                        isFullWidth: false,
                        onPressed: () => context.push(
                          RouteNames.ticketDetail
                              .replaceFirst(':id', ticket.id),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
