import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class CreatorEventsScreen extends ConsumerWidget {
  const CreatorEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(eventInvitesProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Event Invites', style: AppTypography.displaySM),
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.myTickets),
            child: const Text('My Tickets'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neon,
        onRefresh: () => ref.read(eventInvitesProvider.notifier).refresh(),
        child: invitesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.ink),
          ),
          error: (error, _) => BCErrorState(
            message: error.toString(),
            onRetry: () => ref.read(eventInvitesProvider.notifier).refresh(),
          ),
          data: (invites) {
            if (invites.isEmpty) {
              return const BCEmptyState(
                emoji: '🎟️',
                message: 'No event invites yet.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.huge,
              ),
              itemCount: invites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) =>
                  _InviteCard(invite: invites[index]),
            );
          },
        ),
      ),
    );
  }
}

class _InviteCard extends ConsumerWidget {
  const _InviteCard({required this.invite});

  final EventInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(creatorActionsProvider).isLoading;

    return BCCard(
      shadow: AppShadows.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(invite.eventTitle, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(
            invite.brandName ?? 'Brand event',
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              BCBadge(
                label: _statusPretty(invite.status),
                variant: _statusVariant(invite.status),
              ),
              if (invite.eventDate != null)
                BCBadge(
                  label: Formatters.date(invite.eventDate!),
                  variant: BCBadgeVariant.outline,
                ),
              if ((invite.location ?? '').trim().isNotEmpty)
                BCBadge(
                  label: invite.location!,
                  variant: BCBadgeVariant.outline,
                ),
            ],
          ),
          if (invite.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                BCPrimaryButton.neon(
                  label: loading ? 'Please wait...' : 'Accept',
                  isFullWidth: false,
                  onPressed: loading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(creatorActionsProvider.notifier)
                                .respondToEventInvite(
                                  inviteId: invite.id,
                                  action: 'accept',
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite accepted.'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                ),
                const SizedBox(width: AppSpacing.sm),
                BCPrimaryButton.dark(
                  label: 'Reject',
                  isFullWidth: false,
                  onPressed: loading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(creatorActionsProvider.notifier)
                                .respondToEventInvite(
                                  inviteId: invite.id,
                                  action: 'reject',
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite rejected.'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _statusPretty(String status) {
  final label = status.toLowerCase().replaceAll('_', ' ');
  if (label.isEmpty) return 'Unknown';
  return '${label[0].toUpperCase()}${label.substring(1)}';
}

BCBadgeVariant _statusVariant(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return BCBadgeVariant.success;
    case 'rejected':
      return BCBadgeVariant.error;
    case 'pending':
      return BCBadgeVariant.warning;
    default:
      return BCBadgeVariant.outline;
  }
}
